# Developer Guide

Complete reference for building apps on this PowerShell profile platform.

---

## Quick Reference: Building Your First App

### 1. Minimal App (5 minutes)

**Goal:** Create a `weather` command that displays current temperature.

#### Create Structure

```
app/
  weather/
    weather.ps1       # All code here
    persistent/
      profile.json    # Stores last city
```

#### Code Template

Create `app/weather/weather.ps1`:

```powershell
class WeatherProfile {
    [string] $SavePath
    [string] $LastCity
    
    WeatherProfile([string] $path) {
        $this.SavePath = $path
        if (Test-Path $path) {
            $data = Get-Content $path | ConvertFrom-Json
            $this.LastCity = $data.LastCity
        } else {
            $this.LastCity = "Paris"
        }
    }
    
    [void] Save() {
        @{ LastCity = $this.LastCity } | 
            ConvertTo-Json | 
            Set-Content $this.SavePath
    }
}

class WeatherRenderer {
    [void] Render([string] $weather) {
        Write-Host "══════════════════" -ForegroundColor Cyan
        Write-Host $weather -ForegroundColor Yellow
        Write-Host "══════════════════" -ForegroundColor Cyan
    }
}

class WeatherLogic {
    [WeatherProfile] $Profile
    [WeatherRenderer] $Renderer
    
    WeatherLogic([string] $profilePath) {
        $this.Profile = [WeatherProfile]::new($profilePath)
        $this.Renderer = [WeatherRenderer]::new()
    }
    
    [void] GetWeather([string] $city) {
        $data = Invoke-WebRequest "wttr.in/$city/?format=3" -UseBasicParsing
        $this.Renderer.Render($data.Content)
        $this.Profile.LastCity = $city
        $this.Profile.Save()
    }
}

class Weather {
    [WeatherLogic] $Logic
    
    Weather() {
        $path = Join-Path $global:powershell_folder "app\weather\persistent\profile.json"
        $this.Logic = [WeatherLogic]::new($path)
    }
    
    [void] Execute($args) {
        if ($args.Count -eq 0) {
            $city = $this.Logic.Profile.LastCity
        } else {
            $city = $args[0]
        }
        $this.Logic.GetWeather($city)
    }
}

# Global instance
$global:weather_app = [Weather]::new()

function weather {
    $global:weather_app.Execute($args)
}

Set-Alias wt weather
```

#### Load in Profile

Add to `config/functions.ps1`:

```powershell
$weather_app_class = Join-Path $global:powershell_folder "app\weather\weather.ps1"
. $weather_app_class
```

#### Use It

```powershell
weather                    # Show weather for last city (Paris)
weather London            # Show weather for London
wt                        # Alias
```

---

## 2. App with Interactive Menu

### Adding a Menu to Weather App

Create `app/weather/menu.json`:

```json
{
  "title": "Weather",
  "subtitle": "Check conditions",
  "color": "Blue",
  "options": [
    {
      "key": "1",
      "label": "Paris",
      "command": "weather Paris",
      "color": "Yellow"
    },
    {
      "key": "2",
      "label": "London",
      "command": "weather London",
      "color": "Yellow"
    },
    {
      "key": "3",
      "label": "Tokyo",
      "command": "weather Tokyo",
      "color": "Yellow"
    },
    {
      "key": "q",
      "label": "Back",
      "command": "back",
      "color": "Gray"
    }
  ]
}
```

#### Update Main Menu

Edit `home/menus/boulot.json`:

```json
{
  "key": "w",
  "label": "Weather",
  "submenu": "app/weather/menu.json",
  "color": "Blue"
}
```

Now `mm` → select "w" → shows weather menu.

---

## 3. App with Persistent State

### Example: Todo List App

#### Design

```
app/
  todo/
    todo.ps1              # Classes
    persistent/
      todos.json          # Todo items
```

#### Data Model

```json
{
  "items": [
    {
      "id": 1,
      "title": "Buy milk",
      "done": false,
      "created": "2024-05-19T12:00:00Z"
    }
  ]
}
```

#### Code Skeleton

```powershell
class TodoItem {
    [int] $Id
    [string] $Title
    [bool] $Done
    [string] $Created
}

class TodoProfile {
    [string] $SavePath
    [TodoItem[]] $Items
    [int] $NextId
    
    TodoProfile([string] $path) {
        $this.SavePath = $path
        $this.Items = @()
        $this.NextId = 1
        
        if (Test-Path $path) {
            $data = Get-Content $path | ConvertFrom-Json
            $this.Items = $data.items
            $this.NextId = ($this.Items | Measure-Object -Property Id -Maximum).Maximum + 1
        }
    }
    
    [void] AddItem([string] $title) {
        $item = [TodoItem]@{
            Id = $this.NextId
            Title = $title
            Done = $false
            Created = (Get-Date).ToString("o")
        }
        $this.Items += $item
        $this.NextId++
        $this.Save()
    }
    
    [void] CompleteItem([int] $id) {
        ($this.Items | Where-Object Id -eq $id).Done = $true
        $this.Save()
    }
    
    [void] Save() {
        @{ items = $this.Items } | 
            ConvertTo-Json | 
            Set-Content $this.SavePath
    }
}

class TodoRenderer {
    [void] RenderList([TodoItem[]] $items) {
        Write-Host "╔══════════════════════╗" -ForegroundColor Blue
        Write-Host "║  TODO LIST           ║" -ForegroundColor Cyan
        Write-Host "╠══════════════════════╣" -ForegroundColor Blue
        foreach ($item in $items) {
            $status = if ($item.Done) { "✓" } else { "○" }
            $color = if ($item.Done) { "Gray" } else { "Yellow" }
            Write-Host "║ $status $($item.Title.PadRight(18)) ║" -ForegroundColor $color
        }
        Write-Host "╚══════════════════════╝" -ForegroundColor Blue
    }
}

class Todo {
    [TodoProfile] $Profile
    [TodoRenderer] $Renderer
    
    Todo() {
        $path = Join-Path $global:powershell_folder "app\todo\persistent\todos.json"
        $this.Profile = [TodoProfile]::new($path)
        $this.Renderer = [TodoRenderer]::new()
    }
    
    [void] Execute($args) {
        switch ($args[0]) {
            "add" { $this.Profile.AddItem($args[1]); $this.Show() }
            "done" { $this.Profile.CompleteItem($args[1]); $this.Show() }
            "list" { $this.Show() }
            default { $this.Show() }
        }
    }
    
    [void] Show() {
        $this.Renderer.RenderList($this.Profile.Items)
    }
}

$global:todo = [Todo]::new()

function todo {
    $global:todo.Execute($args)
}
```

#### Usage

```powershell
todo add "Buy milk"
todo add "Call mom"
todo list
todo done 1
```

---

## 4. Advanced Patterns

### Pattern: Chainable Methods

Like Bigfish does:

```powershell
class DataProcessor {
    [object[]] $Data
    
    [DataProcessor] Filter([scriptblock] $predicate) {
        $this.Data = $this.Data | Where-Object $predicate
        return $this
    }
    
    [DataProcessor] Sort([string] $property) {
        $this.Data = $this.Data | Sort-Object $property
        return $this
    }
    
    [DataProcessor] Take([int] $count) {
        $this.Data = $this.Data | Select-Object -First $count
        return $this
    }
    
    [void] Display() {
        $this.Data | Format-Table
    }
}

# Usage:
$processor = [DataProcessor]@{ Data = Get-ChildItem }
$processor
    .Filter({ $_.Length -gt 1MB })
    .Sort("LastWriteTime")
    .Take(10)
    .Display()
```

### Pattern: Observable State Changes

```powershell
class Observable {
    [scriptblock[]] $Subscribers
    
    Observable() {
        $this.Subscribers = @()
    }
    
    [void] Subscribe([scriptblock] $callback) {
        $this.Subscribers += $callback
    }
    
    [void] Notify([object] $data) {
        foreach ($callback in $this.Subscribers) {
            & $callback $data
        }
    }
}

# Usage:
$obs = [Observable]::new()

$obs.Subscribe({
    param($data)
    Write-Host "State changed: $data" -ForegroundColor Green
})

$obs.Notify("New fish caught!")
```

### Pattern: Dependency Injection

```powershell
class App {
    [object] $Logger
    [object] $Storage
    
    App([object] $logger, [object] $storage) {
        $this.Logger = $logger
        $this.Storage = $storage
    }
    
    [void] DoWork() {
        $this.Logger.Log("Work started")
        $this.Storage.Save(@{ status = "working" })
        $this.Logger.Log("Work completed")
    }
}

# Mock implementations for testing
class MockLogger {
    [void] Log([string] $msg) {
        Write-Host "[MOCK] $msg" -ForegroundColor Gray
    }
}

class MockStorage {
    [void] Save([hashtable] $data) {
        Write-Host "[MOCK] Saved: $($data | ConvertTo-Json)" -ForegroundColor Gray
    }
}

# Usage:
$app = [App]::new(
    [MockLogger]::new(),
    [MockStorage]::new()
)
$app.DoWork()
```

---

## 5. Best Practices

### ✅ DO

- **Persist user data to JSON** - Never lose state
- **Separate concerns** - Logic, Renderer, Profile classes
- **Use descriptive names** - `FishFile`, not `F`
- **Return $this for chaining** - Fluent interfaces
- **Handle errors gracefully** - Don't crash
- **Use consistent colors** - Cyan=positive, Red=error
- **Comment complex logic** - But not obvious code
- **Test with real data** - Not just unit tests
- **Version your data format** - Add `version` to JSON

### ❌ DON'T

- **Use $global directly for user data** - Rebuilds wrong on restart
- **Hardcode paths** - Use `$global:powershell_folder`
- **Mix display + logic** - Separate Renderer class
- **Ignore errors** - Add try/catch
- **Create huge JSON files** - Keep < 10MB
- **Assume alphabetical order** - Use explicit indexes
- **Forget to Save()** - State only persists after Save()
- **Use Write-Host in libraries** - Let caller control output
- **Trust external data** - Validate JSON on load

### Performance Tips

```powershell
# ❌ Slow - hits disk many times
Get-ChildItem | ForEach-Object { Get-Item $_ }

# ✅ Fast - single disk access
$items = Get-ChildItem
$items | ForEach-Object { $_ }

# ❌ Slow - recreates list every iteration
$list = @()
foreach ($i in 1..1000) { $list += $i }

# ✅ Fast - single allocation
$list = [System.Collections.Generic.List[int]]::new()
foreach ($i in 1..1000) { $list.Add($i) }

# ❌ Slow - joins strings repeatedly
$result = ""
foreach ($item in $items) { $result += $item }

# ✅ Fast - uses StringBuilder
$sb = [System.Text.StringBuilder]::new()
foreach ($item in $items) { $sb.Append($item) | Out-Null }
$result = $sb.ToString()
```

---

## 6. Testing Your App

### Unit Test Example

```powershell
# Save as app/weather/tests.ps1

. "$(Split-Path $MyInvocation.MyCommand.Path)\weather.ps1"

function Test-WeatherProfile {
    Write-Host "Testing WeatherProfile..." -ForegroundColor Cyan
    
    $tempPath = "$env:TEMP\test_weather.json"
    $profile = [WeatherProfile]::new($tempPath)
    
    # Test default
    if ($profile.LastCity -ne "Paris") {
        Write-Host "FAIL: Default city should be Paris" -ForegroundColor Red
        return
    }
    
    # Test save
    $profile.LastCity = "London"
    $profile.Save()
    
    # Test load
    $profile2 = [WeatherProfile]::new($tempPath)
    if ($profile2.LastCity -ne "London") {
        Write-Host "FAIL: City not persisted" -ForegroundColor Red
        return
    }
    
    Remove-Item $tempPath
    Write-Host "PASS" -ForegroundColor Green
}

function Test-WeatherRenderer {
    Write-Host "Testing WeatherRenderer..." -ForegroundColor Cyan
    
    $renderer = [WeatherRenderer]::new()
    $renderer.Render("Sunny, 20°C")  # Just check no error
    
    Write-Host "PASS" -ForegroundColor Green
}

# Run all tests
Test-WeatherProfile
Test-WeatherRenderer
```

Run tests:
```powershell
. app/weather/tests.ps1
```

---

## 7. Debugging Tips

### Inspect Class State

```powershell
# View all properties
$global:bigfish | Get-Member -MemberType Property

# Print object as JSON
$global:wallet | ConvertTo-Json

# Inspect nested objects
$global:bigfish.Fisher.net.net | Select-Object -First 3
```

### Debug Menu Loading

```powershell
# Check JSON syntax
Get-Content home/menus/boulot.json | ConvertFrom-Json -ErrorAction Stop

# Test Menu class directly
$menu = [Menu]::new("home/menus/boulot.json")
$menu.Render()
```

### Profile Loading Issues

```powershell
# Test variable paths
Test-Path $global:powershell_folder
Test-Path $global:persistent_home_path

# Check file contents
Get-Content home/persistent/wallet.json | ConvertFrom-Json

# Reload profile
. $PROFILE
```

### Trace Function Execution

```powershell
# Simple tracing
function traced_function {
    param($arg)
    Write-Host "DEBUG: Called with $arg" -ForegroundColor Gray
    # ... function body
    Write-Host "DEBUG: Returning" -ForegroundColor Gray
}

# Enable all debug output
Set-PSDebug -Trace 1
# ... your commands
Set-PSDebug -Trace 0
```

---

## 8. Common Gotchas

### Gotcha: JSON Serialization Loses Type

```powershell
# ❌ Wrong - becomes string "42"
@{ Value = 42 } | ConvertTo-Json | Get-Content | ConvertFrom-Json

# ✅ Right - cast explicitly
$data = Get-Content file.json | ConvertFrom-Json
$number = [int]$data.Value
```

### Gotcha: Hashtable Key Case-Sensitivity

```powershell
# ❌ Wrong - hashtable keys are case-insensitive in PS
$h = @{ KEY = 1 }
$h.key        # Still works (case-insensitive)

# ✅ Right - JSON is case-sensitive, be consistent
# Always use same casing in code and JSON

# In JSON:
{ "FishCount": 5 }

# In code:
$data.FishCount
```

### Gotcha: Cmdlet Name Conflicts

```powershell
# ❌ You defined both:
function fish { ... }
Get-Command fish           # Which one?

# ✅ Use aliases for short names:
Set-Alias bf bigfish       # Clear that bf is alias
```

### Gotcha: Path Resolution in Nested Scripts

```powershell
# ❌ Wrong - path relative to working directory
$path = "app\bigfish\menu.json"

# ✅ Right - path relative to script location
$path = Join-Path $PSScriptRoot "app\bigfish\menu.json"

# Or use global:
$path = Join-Path $global:powershell_folder "app\bigfish\menu.json"
```

### Gotcha: Global State Across Sessions

```powershell
# ❌ Wrong - doesn't persist to next session
$global:mydata = 42

# ✅ Right - persists via JSON file
class MyProfile {
    [int] $MyData
    [void] Save() { /* save to JSON */ }
}
```

---

## 9. Extending Existing Apps

### Add Command to Bigfish

Edit `app/bigfish/bigfish.ps1`, find `Execute()` method:

```powershell
[void] Execute($cmd) {
    switch ($cmd[0]) {
        "fish" { $this.Fish($cmd[1]) }
        "deepfish" { $this.DeepFish($cmd[1]) }
        "sell" { $this.Sell($cmd[1]) }
        "net" { $this.Net($cmd[1]) }
        "help" { $this.Renderer.RenderHelp($this) }
        
        # NEW COMMAND:
        "stats" { $this.ShowStats() }
        
        default { 
            $menubf_path = Join-Path $global:bigfish_path "menu.json"
            $menuBigfish = [Menu]::new($menubf_path)
            $menuBigfish.show()
        }
    }
}

# Add method:
[void] ShowStats() {
    Write-Host "Total fish caught: $($this.wallet.GetFishCount())"
    Write-Host "Total value: $($this.wallet.GetValue()) €"
}
```

Now:
```powershell
bigfish stats
```

### Add New Merchant Item

Edit `app/merchant/persistent/profile.json`:

```json
{
  "itemsAvailable": [
    {
      "name": "Net Upgrade",
      "description": "Increase fishing net capacity",
      "price": 100,
      "Metadata": {}
    }
  ],
  "itemsSold": []
}
```

### Add Menu Item to Main Menu

Edit `home/menus/boulot.json`:

```json
{
  "key": "x",
  "label": "New Option",
  "command": "newcommand arg1 arg2",
  "color": "Green"
}
```

---

## 10. Publishing Your App

### Share App Structure

```
your-app/
├── README.md            # Usage guide
├── your-app.ps1         # All code
├── menu.json           # Optional menu
├── persistent/
│   └── .gitkeep        # Empty on first clone
└── examples/
    └── sample.json     # Sample data
```

### README Template

```markdown
# MyApp - [Description]

One-liner description.

## Installation

1. Copy folder to `app/myapp/`
2. Add to `config/functions.ps1`:
   ```powershell
   $myapp_class = Join-Path $global:powershell_folder "app\myapp\myapp.ps1"
   . $myapp_class
   ```
3. Restart PowerShell

## Usage

```powershell
myapp command arg
```

## Architecture

Brief explanation of classes and JSON structure.

## Author

Your name & GitHub link
```

---

**Document Version:** 1.0  
**Last Updated:** 2024-05-19
