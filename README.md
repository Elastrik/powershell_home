# 🎣 PowerShell Profile: Custom Gaming & Productivity System

A handcrafted PowerShell profile inspired by **Rust** and **Linux** philosophy, bringing game mechanics and Linux-like commands to Windows. Built with composable classes, persistent state, and beautiful CLI interfaces.

> *"I miss a lot using Linux in a Windows-only workplace."*  
> This profile bridges that gap while adding fun to everyday tasks.

---

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Core Apps](#core-apps)
- [Commands & Aliases](#commands--aliases)
- [Configuration](#configuration)
- [Development Guide](#development-guide)
- [File Structure](#file-structure)

---

## 🚀 Quick Start

### Setup

1. **Clone or download** this repository into your PowerShell profile directory
2. **Edit `config/variable.ps1`** to set your paths:
   ```powershell
   $global:desk          # Desktop directory
   $global:jahbless      # User home (C:\Users\username\)
   $global:docs          # Documents
   $global:down          # Downloads
   ```
3. **Launch PowerShell** - the profile loads automatically

### First Commands

```powershell
mm                    # Open main menu (interactive navigation)
bigfish help          # See Bigfish game commands
wallet                # Check your score/wallet
merchant              # Visit the merchant
```

---

## 🏗️ Architecture

### Core Design Philosophy

This system follows **composable, stateful design**:

```
┌─────────────────────────────────────────┐
│   User Input (CLI / Interactive Menu)   │
└──────────────┬──────────────────────────┘
               │
       ┌───────▼────────┐
       │  Commands      │
       │  (Functions)   │
       └───────┬────────┘
               │
    ┌──────────▼──────────────┐
    │  Application Classes    │
    │  (Fisher, FishNet, etc) │
    └──────────┬───────────────┘
               │
    ┌──────────▼──────────────┐
    │  Persistent State       │
    │  (JSON files)           │
    └─────────────────────────┘
```

### Stateful Components

Every app follows this pattern:

1. **Profile Class** - Manages metadata (JSON-backed)
2. **Renderer Class** - Beautiful ASCII output
3. **Business Logic Class** - Core functionality
4. **Global Instance** - Persisted in `home/persistent/`

**Example: Wallet System**
```
Wallet (state) 
  ├─ value (currency)
  └─ metadata (achievements, fish count, etc)
  
WalletRenderer (display)
  └─ ASCII box with colors
  
FishWallet (domain logic)
  └─ Adds catches to wallet
```

---

## 🎮 Core Apps

### 🐟 Bigfish - File Cleaner Game

**Turn file cleanup into a fishing game!**

```powershell
bigfish fish 5          # Catch 5 largest files
bigfish fish saumon     # Catch all salmon-sized files (>1MB)
bigfish deepfish 10     # Search subdirectories for 10 largest files
bigfish net             # Show what's in your net
bigfish sell            # Delete caught files and earn points
```

**Fish Types** (by size):
| Type | Size | Color |
|------|------|-------|
| krill | < 10 KB | DarkGray |
| maquereau | 10 KB - 1 MB | Gray |
| saumon | 1 MB - 100 MB | White |
| daurade | 100 MB - 500 MB | Green |
| thon | 500 MB - 1 GB | Yellow |
| orque | 1 GB - 10 GB | Red |
| baleine | > 10 GB | Magenta |

**Classes:**
- `FishFile` - Wraps a file with type & value
- `FishType` - Maps file size to fish type/color
- `FishNet` - Container with capacity limit
- `Fisher` - Main business logic (various catch strategies)
- `FishRenderer` - Beautiful ASCII output
- `FishWallet` - Tracks catches and awards points
- `BigFish` - Main command handler

**Data Files:**
- `app/bigfish/persistent/profile.json` - Net capacity, settings
- `home/persistent/wallet.json` - Player score

---

### 💼 Wallet System

**Track your points/currency earned from Bigfish.**

```powershell
wallet                  # Display current balance
```

**Classes:**
- `Wallet` - Stores value + metadata, JSON-persistent
- `WalletRenderer` - Pretty-prints wallet state

**Metadata Tracked:**
- `FishCount` - Total fish caught
- Custom achievements/stats

---

### 🏪 Merchant

**Spend your hard-earned points on items!**

```powershell
merchant                # Browse merchant stock
```

**Classes:**
- `MerchantItem` - Name, description, price, metadata
- `Merchant` - Inventory management, JSON persistence
- `MerchantItemRenderer` - Item display

**State File:**
- `app/merchant/persistent/profile.json` - Inventory

---

### 📋 Menu System

**Interactive CLI menus from JSON configuration.**

```powershell
mm                      # Main menu
```

**Features:**
- JSON-driven (no code needed for new menus)
- Nested submenus
- Custom commands per menu item
- Pretty Unicode borders + colors

**Classes:**
- `MenuItem` - Single menu option
- `Menu` - Menu container with render & show logic

**Menu Files:**
- `home/menus/boulot.json` - Work shortcuts
- `home/menus/maison.json` - Home shortcuts
- `app/bigfish/menu*.json` - Bigfish UI

---

## ⌨️ Commands & Aliases

### Navigation (Linux-like)

```powershell
..              # cd ..
...             # cd ../..
ls              # Get-ChildItem (list files)
ll              # Get-ChildItem with details
la              # Get-ChildItem -Force (show hidden)
pwd             # Print working directory
```

### Files

```powershell
touch file.txt          # Create empty file
mkdir dirname           # Create directory
mkcd dirname            # Create & enter directory
cp source dest          # Copy
mv source dest          # Move
rm path                 # Delete
rmrf path               # Delete recursively
cat file.txt            # Show file contents
head file.txt           # First 10 lines
tail file.txt           # Last 10 lines
tailf file.txt          # Follow file (like tail -f)
grep pattern file       # Search in file
find name               # Find by name (recursive)
wc file                 # Line count
```

### Network

```powershell
myip                    # Your public IP
ports                   # Open ports (LISTENING)
ping server             # Test connection
```

### System

```powershell
df                      # Disk usage
free                    # Memory usage
ps [name]               # List processes
kill [name]             # Terminate process
uptime                  # Time since last boot
clear                   # Clear screen
man [cmd]               # Help for command
diskbar                 # Visual disk usage bars
```

### Utilities

```powershell
meteo [city]            # Weather (default: Chezy-sur-Marne)
extract file            # Unzip/untar files
which cmd               # Show command path
hist [search]           # Command history (optionally search)
ShowColors              # Display all terminal colors
```

### Applications

```powershell
mm                      # Main menu
bf                      # Bigfish (alias)
wallet                  # Check wallet
merchant                # Browse merchant
codeWS SQL|SSH|...      # Open VS Code workspace
a14 / a12               # RDP connections
Mesnil400 / Marly400    # IBM application launchers
```

---

## ⚙️ Configuration

### Main Config Files

#### `config/variable.ps1`
Global path variables used throughout the system:
- `$global:desk` - Desktop path
- `$global:powershell_folder` - Profile root
- `$global:persistent_home_path` - Data storage
- `$global:main_menu` - Default menu on startup

#### `config/alias.ps1`
All command aliases (linux-like shortcuts).

#### `config/functions.ps1`
Helper functions and app launchers.

#### `config/welcome.ps1`
Startup banner and welcome message.

#### `config/variable_maison.ps1`
Personal/home-specific overrides.

#### `config/tradsh.ps1`
External tool aliases (RDP, browsers, applications).

### Menu Configuration (JSON)

Menus are defined in `home/menus/*.json`:

```json
{
  "title": "Main Menu",
  "subtitle": "Welcome!",
  "color": "Blue",
  "options": [
    {
      "key": "1",
      "label": "Bigfish",
      "command": "bigfish",
      "color": "Cyan"
    },
    {
      "key": "q",
      "label": "Quit",
      "command": "exit",
      "color": "Gray"
    }
  ]
}
```

**JSON Structure:**
- `title` - Menu heading
- `subtitle` - Subheading
- `color` - Frame color
- `options[]` - Array of menu items:
  - `key` - Key to press
  - `label` - Display text
  - `command` - PowerShell to execute
  - `submenu` - Path to JSON submenu (alternative to `command`)
  - `color` - Text color

---

## 👨‍💻 Development Guide

### Creating a New App

Follow this pattern to build apps consistent with the architecture:

#### 1. Create App Directory

```
app/
  myapp/
    myapp.ps1           # Classes & main command
    persistent/
      profile.json      # User data
    menu.json           # (Optional) UI config
```

#### 2. Define Classes

```powershell
# State class
class MyProfile {
    [hashtable] $Metadata
    [string] $SavePath
    
    MyProfile([string] $savePath) {
        $this.SavePath = $savePath
        $this.Metadata = @{}
        if (Test-Path $savePath) {
            $data = Get-Content $savePath | ConvertFrom-Json
            # Restore state from JSON...
        }
    }
    
    [void] Save() {
        @{ Metadata = $this.Metadata } | ConvertTo-Json | 
            Set-Content $this.SavePath
    }
}

# Renderer class
class MyRenderer {
    [void] Render([object] $data) {
        Write-Host "═" * 50 -ForegroundColor Cyan
        Write-Host $data.Name -ForegroundColor Yellow
        Write-Host "═" * 50
    }
}

# Business logic class
class MyLogic {
    [MyProfile] $Profile
    [MyRenderer] $Renderer
    
    MyLogic([string] $profilePath) {
        $this.Profile = [MyProfile]::new($profilePath)
        $this.Renderer = [MyRenderer]::new()
    }
    
    [void] DoSomething() {
        # Your logic here
        $this.Profile.Save()
        $this.Renderer.Render($this.Profile)
    }
}

# Main command handler
class MyApp {
    [MyLogic] $Logic
    
    MyApp() {
        $path = Join-Path $global:powershell_folder "app\myapp\persistent\profile.json"
        $this.Logic = [MyLogic]::new($path)
    }
    
    [void] Execute($cmd) {
        switch ($cmd[0]) {
            "action" { $this.Logic.DoSomething() }
            "help" { $this.ShowHelp() }
            default { Write-Host "Unknown command" -ForegroundColor Red }
        }
    }
    
    [void] ShowHelp() {
        Write-Host @"
AVAILABLE COMMANDS
  myapp action        Do something
  myapp help          Show this help
"@
    }
}

# Global instance
$global:myapp = [MyApp]::new()

function myapp {
    $global:myapp.Execute($args)
}

Set-Alias ma myapp
```

#### 3. Load in Profile

Add to `config/functions.ps1`:

```powershell
$myapp_class = Join-Path $global:powershell_folder "app\myapp\myapp.ps1"
. $myapp_class
```

#### 4. Add Menu Item

Edit `home/menus/boulot.json`:

```json
{
  "key": "m",
  "label": "My App",
  "command": "myapp",
  "color": "Green"
}
```

### Architecture Patterns

#### Composition Over Inheritance

Each app uses composition:
```
MyApp 
  ├─ Logic (business)
  ├─ Renderer (display)
  └─ Profile (state)
```

#### JSON-Backed State

Never use global variables for user data. Always persist:

```powershell
# ✅ Good
class MyProfile {
    [hashtable] $Data
    [string] $SavePath
    
    [void] Save() {
        $this.Data | ConvertTo-Json | Set-Content $this.SavePath
    }
}

# ❌ Bad - loses data on restart
$global:mydata = @{}
```

#### Fluent-style Chaining (Optional)

Like in Bigfish:

```powershell
[Fisher] FishByCapacity() {
    # ... logic ...
    return $this
}

# Usage
$fisher.FishByCapacity().Sell($wallet)
```

#### Renderer Pattern

Always separate display logic:

```powershell
class MyRenderer {
    [void] RenderHeader() { /* ... */ }
    [void] RenderBody([object] $data) { /* ... */ }
    [void] RenderFooter() { /* ... */ }
}
```

---

## 📁 File Structure

```
powershell/                              # Profile root
├── README.md                            # This file
├── ARCHITECTURE.md                      # Detailed design docs
├── DEVELOPER_GUIDE.md                   # Developer reference
│
├── config/                              # Configuration layer
│   ├── alias.ps1                        # Command aliases
│   ├── functions.ps1                    # Helper functions & loaders
│   ├── variable.ps1                     # Global paths
│   ├── variable_maison.ps1              # Personal overrides
│   ├── tradsh.ps1                       # External tool aliases
│   └── welcome.ps1                      # Startup banner
│
├── app/                                 # Application layer
│   ├── menu/
│   │   └── menu.ps1                     # Menu system class
│   │
│   ├── bigfish/                         # Game: file cleaner
│   │   ├── bigfish.ps1                  # All classes + main logic
│   │   ├── menu.json                    # Main menu config
│   │   ├── menu_bigfish.json            # Bigfish submenu
│   │   └── persistent/
│   │       └── profile.json             # Game state
│   │
│   ├── wallet/
│   │   └── wallet.ps1                   # Wallet & WalletRenderer
│   │
│   └── merchant/
│       ├── merchant.ps1                 # Merchant classes & logic
│       └── persistent/
│           └── profile.json             # Inventory
│
├── home/                                # User data layer
│   ├── menus/
│   │   ├── boulot.json                  # Work menu
│   │   ├── maison.json                  # Home menu
│   │   ├── outil_boulot.json            # Tools submenu
│   │   ├── machine_boulot.json          # Machines submenu
│   │   └── vscode_boulot.json           # VS Code workspaces
│   │
│   └── persistent/
│       └── wallet.json                  # Player wallet
│
└── .vscode/
    └── settings.json                    # VS Code workspace settings
```

---

## 🎨 Design Highlights

### Influenced by Rust/Linux

✅ **Type Safety** - PowerShell classes with strict typing  
✅ **Ownership Model** - JSON files as single source of truth  
✅ **Composability** - Classes combine like Unix pipes  
✅ **CLI-First** - No GUI, pure terminal interface  
✅ **Zero Runtime Bloat** - Only loads what's needed

### Visual Design

- **Unicode borders** - Professional ASCII UI
- **Color coding** - Semantic color use (errors=Red, success=Green)
- **Consistent spacing** - Aligned columns and padding
- **Fish theme** - Fishing game metaphor for file cleanup

---

## 🔧 Troubleshooting

### Profile Not Loading

1. Check PowerShell profile path:
   ```powershell
   $PROFILE
   ```
2. Ensure `config/variable.ps1` paths are correct
3. Check for syntax errors:
   ```powershell
   Test-Path $PROFILE
   ```

### Bigfish Not Finding Files

- Verify you're in a directory with files
- Check net capacity: `bigfish net`
- Try deeper search: `bigfish deepfish 10`

### Wallet Not Saving

- Check `home/persistent/` directory exists
- Verify write permissions
- Check `wallet.json` format (valid JSON)

### Menu Not Showing

- Verify JSON syntax: `Get-Content home/menus/boulot.json | ConvertFrom-Json`
- Check `$global:main_menu` is set correctly
- Ensure `app/menu/menu.ps1` is loaded

---

## 📚 Further Reading

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Deep dive into system design
- **[DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)** - Build your own apps
- PowerShell Classes: `Get-Help about_Classes`

---

## 🎯 Next Steps

1. **Customize menus** - Edit `home/menus/*.json` for your workflow
2. **Build an app** - Create your own game or tool
3. **Add features** - Extend Bigfish or Wallet
4. **Share** - Show off your creations!

---

**Made with ❤️ by someone who misses Linux on Windows.**
