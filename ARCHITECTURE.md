# System Architecture

Detailed technical design of the PowerShell profile system.

---

## 1. Layered Architecture

The system is organized in **4 layers**:

```
┌──────────────────────────────────────────┐
│  Layer 4: User Interface                 │
│  - Interactive Menus (JSON)              │
│  - ASCII Renderers (Beautiful output)    │
│  - Command Functions                     │
└────────────────┬─────────────────────────┘
                 │
┌────────────────▼─────────────────────────┐
│  Layer 3: Application Logic              │
│  - Classes (Fisher, Merchant, etc)       │
│  - Business Rules                        │
│  - State Management                      │
└────────────────┬─────────────────────────┘
                 │
┌────────────────▼─────────────────────────┐
│  Layer 2: Data Layer                     │
│  - JSON-backed Profiles                  │
│  - Persistence (hashtables→JSON)         │
│  - Metadata storage                      │
└────────────────┬─────────────────────────┘
                 │
┌────────────────▼─────────────────────────┐
│  Layer 1: Infrastructure                 │
│  - PowerShell paths & variables          │
│  - File system layout                    │
│  - Global configuration                  │
└──────────────────────────────────────────┘
```

---

## 2. Data Flow Example: Catching Fish

Tracing through a real example: `bigfish fish 5`

```
1. INPUT LAYER
   └─ User types: bigfish fish 5
   
2. COMMAND HANDLER
   └─ Function bigfish calls $bigFish.Execute($args)
   
3. LOGIC LAYER
   ├─ BigFish.Execute() routes "fish" command
   ├─ Calls Fisher.FishByCount(5)
   │  ├─ Gets files: Get-ChildItem -File
   │  ├─ Sorts by size descending
   │  ├─ Takes top 5
   │  └─ For each: Creates FishFile object
   │     └─ FishType calculates "baleine" or "thon" etc
   │     └─ Stores in FishNet.net (List<FishFile>)
   └─ Returns self for chaining
   
4. RENDERING LAYER
   └─ FishRenderer.RenderNet() outputs:
      ├─ Header (logo + wallet display)
      ├─ For each fish:
      │  ├─ Fish type [color]
      │  ├─ Filename with padding
      │  └─ Size + value
      └─ Footer
      
5. STATE LAYER
   └─ No persistence yet (fishing, not selling)
   └─ FishNet only held in memory
   
6. OUTPUT
   └─ Beautiful ASCII display with colors
```

When `bigfish sell` is called:

```
7. CONFIRMATION
   └─ User confirms: "y"
   
8. PERSISTENCE LAYER
   ├─ For each FishFile in net:
   │  ├─ FishWallet.AddCatch(fish)
   │  │  └─ Calculates value = file size in MB / 10
   │  │  └─ Wallet.AddValue(value)
   │  │     └─ Increments wallet.valeur
   │  │     └─ Updates metadata (FishCount++)
   │  │     └─ Saves wallet.json
   │  └─ Remove-Item deletes actual file
   └─ FishNet.clear() empties net
   
9. OUTPUT
   └─ RenderSuccess("Fichiers supprimes!")
```

---

## 3. Class Hierarchy

### Bigfish Ecosystem

```
FishFile ────────────┐
                     │
FishType             │
(static tables)      │
                     ├─→ FishNet ─────┐
                     │                │
                     │                ├─→ Fisher ─────┐
                     │                │               │
                     │                │               ├─→ BigFish (main)
FishWallet ──────────┼────────────────┤               │
(tracks catches)     │                │               │
Wallet               │                │               │
                     │                └─────────────┘
                     │
FishRenderer ────────┘
(display)
```

**Ownership:**
- `FishFile` owns file metadata
- `FishNet` owns collection of FishFile
- `Fisher` owns FishNet
- `BigFish` owns Fisher, Renderer, FishWallet
- `BigFish` is the public API

### Wallet Ecosystem

```
Wallet (JSON-backed state)
  ├─ value (long)
  ├─ Metadata (hashtable)
  └─ SavePath (string)

WalletRenderer (display only)
  └─ Renders Wallet with ASCII box

FishWallet (domain logic)
  ├─ Wallet instance
  ├─ AddCatch(FishFile)
  └─ GetFishCount()
```

### Menu Ecosystem

```
Menu (main orchestrator)
  ├─ Title, Subtitle, Color
  ├─ Options[] (array of MenuItem)
  ├─ HeaderBlock (optional custom renderer)
  └─ Methods:
     ├─ Render() - draw UI
     ├─ Show() - event loop
     └─ ResolvePath() - static helper

MenuItem (single option)
  ├─ Key (button pressed)
  ├─ Label (displayed text)
  ├─ Command (PowerShell to execute)
  ├─ Submenu (path to JSON submenu)
  └─ Color (text color)
```

### Merchant Ecosystem

```
Merchant (inventory manager)
  ├─ itemsAvailable[] (array of MerchantItem)
  ├─ itemsSold[] (array of MerchantItem)
  ├─ SavePath (JSON file)
  └─ Methods:
     ├─ GetJsonMenu() - generates Menu JSON
     └─ Save() - persist to JSON

MerchantItem (single sellable)
  ├─ name (string)
  ├─ description (string)
  ├─ price (int)
  └─ Metadata (hashtable)

MerchantItemRenderer (display)
  └─ RenderItem(MerchantItem)
```

---

## 4. Data Persistence

### JSON Format: Wallet

```json
{
  "valeur": 42,
  "Metadata": {
    "FishCount": 5,
    "LastCatch": "2024-05-19T12:34:56Z"
  }
}
```

### JSON Format: BigFish Profile

```json
{
  "Metadata": {
    "NetCapacity": 5,
    "TotalCaught": 42,
    "Achievements": ["First Fish", "Whale Hunter"]
  }
}
```

### JSON Format: Menu

```json
{
  "title": "Main Menu",
  "subtitle": "Choose action",
  "color": "Blue",
  "options": [
    {
      "key": "1",
      "label": "Play Bigfish",
      "command": "bigfish help",
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

### Persistence Pattern

All stateful classes follow this pattern:

```powershell
class Profile {
    [string] $SavePath
    [hashtable] $Data
    
    Profile([string] $path) {
        $this.SavePath = $path
        if (Test-Path $path) {
            $json = Get-Content $path | ConvertFrom-Json
            $this.Data = @{/* restore */}
        } else {
            $this.Data = @{}
        }
    }
    
    [void] Save() {
        $this.Data | ConvertTo-Json | Set-Content $this.SavePath
    }
}
```

**Key Design Points:**
1. JSON as single source of truth
2. Objects rebuild state on instantiation
3. Save() is explicit, not automatic
4. Global instance maintains current state
5. On next load, globals are reinitialize from JSON

---

## 5. Control Flow: Menu System

### Event Loop

```
while (true) {
    ┌─────────────────────┐
    │ Render() - show UI  │
    ├─────────────────────┤
    │ Read-Host "choice"  │
    ├─────────────────────┤
    │ Validate choice     │
    ├─────────────────────┤
    │ Route to handler:   │
    │  - exit → return    │
    │  - back → return    │
    │  - submenu → Show() │
    │  - command → Invoke │
    └─────────────────────┘
         (repeat)
}
```

### Submenu Nesting

```
Main Menu (boulot.json)
  ├─ "1" → Bigfish
  │   └─ Shows: app/bigfish/menu.json
  │       ├─ "1" → "fish 5" (executes)
  │       ├─ "2" → "deepfish 10"
  │       └─ "q" → Back to Main
  │
  ├─ "2" → Work Tools
  │   └─ Shows: home/menus/outil_boulot.json
  │       └─ (similar nesting)
  │
  └─ "q" → Exit
```

---

## 6. Type System

### Fish Type Classification

```powershell
static [Hashtable] $fishSize = @{
    'krill'     = 0KB          # 0 - 10 KB
    'maquereau' = 10KB         # 10 KB - 1 MB
    'saumon'    = 1MB          # 1 MB - 100 MB
    'daurade'   = 100MB        # 100 MB - 500 MB
    'thon'      = 500MB        # 500 MB - 1 GB
    'orque'     = 1GB          # 1 GB - 10 GB
    'baleine'   = 10GB         # > 10 GB
}
```

**Algorithm:**
```powershell
# For each file, find the largest threshold it meets
Sort thresholds descending
For each threshold:
    if (file.Length >= threshold)
        return fish type

# Result: file_type = most specific match
```

### File Value Calculation

```
valeur = Ceiling(file.Length / 1MB / 10)
if valeur == 0: valeur = 1

Examples:
  500 KB  → 0 → becomes 1 euro
  5 MB    → 1 euro
  50 MB   → 5 euros
  500 MB  → 50 euros
  5 GB    → 500 euros
```

---

## 7. Render System

### Pattern: Three-Phase Rendering

Every renderer follows this pattern:

```powershell
RenderHeader()    # Static top (logo, title)
RenderBody()      # Dynamic content (data-dependent)
RenderFooter()    # Static bottom (footer message)
```

### Color Semantics

```
Cyan      → Positive, primary actions
Yellow    → Attention, items, prices
Green     → Success, complete
Red       → Error, danger, large sizes
Gray      → Secondary, metadata
Blue      → Frames, structure
Magenta   → Metadata, special items
White     → Content, primary text
```

### Unicode Elements

```
═ ║ ╔ ╗ ╚ ╝ ╠ ╣ ╦ ╩ ╬  Boxes
~ ─ * ●                 Decorations
→ < > ↑ ↓              Directions
█ ░                     Bars
```

---

## 8. Performance Considerations

### Memory

- **FishFile objects** created on-demand (not stored)
- **FishNet limited** by capacity (prevents explosion)
- **JSON files small** (KB, not MB)
- **No caching layer** (rebuilds from JSON each session)

### I/O

```
bigfish fish 5
  └─ Get-ChildItem (file system I/O) - SLOW on large dirs
  └─ Sort-Object Length (memory sort) - O(n log n)
  └─ Select-Object -First 5 (early exit) - fast
```

**Optimization opportunity:** Add `-Filter` to Get-ChildItem

### Startup Time

- Each app class instantiated in `config/functions.ps1`
- Big performance hit if many apps loaded
- Consider lazy loading for less-used apps

---

## 9. Global State

### Registered Globals

```powershell
$global:bigfish_metadata         # BigFishProfile instance
$global:bigfish = [BigFish]      # Main game object
$global:wallet = [Wallet]        # Player currency
$global:Merchant_profile         # Merchant inventory

# Paths
$global:PSConfigRoot             # Profile root
$global:powershell_folder        # Same as PSConfigRoot
$global:persistent_home_path     # home/persistent/
$global:bigfish_path             # app/bigfish/
$global:menu_path                # app/menu/
$global:wallet_class_path        # app/wallet/
```

**Principle:** Only globals for instances, never for user data.

---

## 10. Extension Points

### Add New Fish Type

Edit `bigfish.ps1` FishType class:

```powershell
static [Hashtable] $fishSize = @{
    'newtype' = 2GB
    # ...
}

static [Hashtable] $fishColor = @{
    'newtype' = 'Cyan'
    # ...
}
```

### Add New Fish Catching Strategy

Add method to `Fisher` class:

```powershell
[Fisher] FishByPattern([string] $pattern) {
    Get-ChildItem -File -Filter $pattern |
    Sort-Object Length -Descending |
    Select-Object -First $this.net.capacity |
    ForEach-Object {
        $fish = [FishFile]::new($_)
        $this.net.AddFish($fish)
    }
    return $this
}

# Usage:
bigfish fishbypattern *.log
```

### Add New Menu Item

Edit JSON (e.g., `home/menus/boulot.json`):

```json
{
  "key": "n",
  "label": "New App Name",
  "command": "newapp command",
  "color": "Green"
}
```

### Add New App

Follow the 4-step app creation process in README.md.

---

## 11. Testing Strategy

### Manual Testing

```powershell
# Test bigfish catch
cd $env:TEMP
New-Item -ItemType File -Name "test_1MB.bin" -Value (New-Object byte[] 1MB)
bigfish fish 1

# Test merchant
merchant

# Test menu
mm
```

### Validation

```powershell
# Check JSON syntax
Get-Content home/menus/boulot.json | ConvertFrom-Json

# Check class loading
$bigFish | Get-Member
$wallet | Get-Member

# Check globals
$global:powershell_folder
$global:persistent_home_path
```

---

## 12. Common Patterns

### Builder Pattern (Fluent Interface)

```powershell
$fisher
  .FishByCount(5)
  .Sell($wallet)
  
# Behind the scenes:
# FishByCount returns $this (Fisher object)
# Sell also returns $this (chaining)
```

### Factory Pattern (Class instantiation)

```powershell
# Factory hidden in constructor
[FishFile]::new($fileInfo)
  # → calls [FishType]::new($fileInfo)
  # → auto-selects fish type
  # → calculates value
```

### Observer Pattern (Optional custom renderers)

```powershell
$menu = [Menu]::new($jsonPath, {
    # Custom header rendering
    Write-Host "=== CUSTOM HEADER ===" -ForegroundColor Cyan
})

# $headerBlock executed before standard render
```

---

## 13. Known Limitations

1. **No undo for Sell** - Deleted files are gone (by design)
2. **No cross-app transfers** - Wallet doesn't link to merchant
3. **No achievements** - Metadata structure exists but unused
4. **No save/load profiles** - No game save feature in Bigfish
5. **No multiplayer** - Single user only
6. **No network** - All local files only
7. **Limited filtering** - Menu has no search/filter UX
8. **No rollback** - JSON edits not versioned

---

## 14. Future Architecture Improvements

### Planned Enhancements

1. **Plugin System** - Standardized app interface
2. **Event System** - Global event bus for inter-app communication
3. **Achievement Engine** - Track accomplishments
4. **Cloud Sync** - Backup profile to cloud
5. **Dashboard** - Summary view of all apps
6. **Theming** - Customizable color schemes
7. **Logging** - Audit trail of commands
8. **Scripting** - Batch commands file

### Scaling Considerations

- Separate classes into individual .ps1 files per class
- Implement lazy loading for apps
- Cache Get-ChildItem results for deep searches
- Add database layer (SQLite) for larger datasets
- Implement transactional saves (JSON + .bak)

---

**Document Version:** 1.0  
**Last Updated:** 2024-05-19
