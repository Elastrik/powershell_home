# File Structure Reference

Complete map of the PowerShell profile directory and what each file does.

---

## Directory Tree

```
powershell/
│
├── 📄 README.md                         [NEW] Main documentation
├── 📄 ARCHITECTURE.md                   [NEW] System design details
├── 📄 DEVELOPER_GUIDE.md                [NEW] How to build apps
├── 📄 QUICKREF.md                       [NEW] Quick reference card
├── 📄 FILE_STRUCTURE.md                 [NEW] This file
│
├── .git/                                Git repository
├── .gitignore                           Git ignore rules
├── .gitattributes                       Git attributes
├── .vscode/
│   └── settings.json                    VS Code workspace settings
│
├── config/
│   ├── alias.ps1                        Command aliases (ls, cd, etc)
│   ├── functions.ps1                    Helper functions & app loaders
│   ├── variable.ps1                     Global path variables
│   ├── variable_maison.ps1              Personal/home overrides
│   ├── tradsh.ps1                       External tool links
│   └── welcome.ps1                      Startup banner
│
├── app/
│   │
│   ├── menu/
│   │   └── menu.ps1                     Interactive menu system
│   │                                    ├─ MenuItem class
│   │                                    └─ Menu class
│   │
│   ├── bigfish/                         Game: File cleaner
│   │   ├── bigfish.ps1                  Main game code
│   │   │                                ├─ FishFile class
│   │   │                                ├─ FishType class
│   │   │                                ├─ FishNet class
│   │   │                                ├─ Fisher class
│   │   │                                ├─ FishRenderer class
│   │   │                                ├─ FishWallet class
│   │   │                                ├─ BigFish class (main)
│   │   │                                ├─ BigFishProfile class
│   │   │                                └─ Function: bigfish()
│   │   ├── menu.json                    Main bigfish menu
│   │   ├── menu_bigfish.json            Bigfish submenu (unused?)
│   │   ├── menu_bigfish_type.json       Fish types menu (unused?)
│   │   └── persistent/
│   │       └── profile.json             Game state (net capacity, etc)
│   │
│   ├── wallet/
│   │   └── wallet.ps1                   Player currency system
│   │                                    ├─ Wallet class
│   │                                    ├─ WalletRenderer class
│   │                                    └─ Function: wallet()
│   │
│   └── merchant/
│       ├── merchant.ps1                 Store/shop system
│       │                                ├─ MerchantItem class
│       │                                ├─ MerchantItemRenderer class
│       │                                ├─ Merchant class
│       │                                └─ Function: merchant()
│       └── persistent/
│           └── profile.json             Inventory (items for sale)
│
├── home/
│   │
│   ├── menus/                           Interactive menu definitions
│   │   ├── boulot.json                  Main work menu
│   │   ├── maison.json                  Home menu
│   │   ├── outil_boulot.json            Work tools submenu
│   │   ├── machine_boulot.json          Remote machines submenu
│   │   └── vscode_boulot.json           VS Code workspaces submenu
│   │
│   └── persistent/                      User data storage
│       └── wallet.json                  Player score & achievements
│
└── (project root)
    .gitignore                           Files to ignore in git
    .gitattributes                       Line ending rules
```

---

## Config Layer

### `config/alias.ps1` (61 lines)
**Purpose:** Linux-like command aliases

**Contains:**
- Navigation: `..`, `...`, `ls`, `ll`, `la`, `pwd`
- Files: `touch`, `mkdir`, `mkcd`, `cp`, `mv`, `rm`, `rmrf`, `cat`, `head`, `tail`, `tailf`, `grep`, `find`, `wc`, `which`
- Network: `myip`, `ports`, `ping`
- System: `df`, `free`, `ps`, `kill`, `uptime`, `clear`, `man`
- Utilities: `hist`, `meteo`, `extract`

**Usage:** Sourced in `functions.ps1` to provide Linux-like shell experience

---

### `config/functions.ps1` (166 lines)
**Purpose:** Core helper functions and app loaders

**Contains:**
- `browser()` - Open URL in default browser
- Shortcuts: `youtube`, `steam`, `musique`, `keep`, `gmail`, `sheet`, `teams`, `outlook`, `gitHubDesktop`
- RDP launchers: `Start-RDP`, `adelia14`, `adelia12`
- IBM app launchers: `Start-IBM`, `Mesnil400`, `Marly400`
- `diskbar()` - Visual disk usage display
- Main menu setup: `mainmenu`
- VS Code workspace launcher: `codeWS`
- Color display: `ShowColors`
- **App loaders** (sourcing other .ps1 files):
  - `menu.ps1`
  - `wallet.ps1`
  - `bigfish.ps1`
  - `merchant.ps1`

**Usage:** Loaded on PowerShell startup

---

### `config/variable.ps1` (22 lines)
**Purpose:** Global path variables

**Key Variables:**
```powershell
$global:desk                    # Desktop
$global:jahbless               # User home
$global:docs                   # Documents
$global:soft                   # Software folder
$global:down                   # Downloads
$global:powershell_folder      # Profile root
$global:powershell_home        # home/
$global:menu_path              # app/menu/
$global:bigfish_path           # app/bigfish/
$global:wallet_class_path      # app/wallet/
$global:persistent_home_path   # home/persistent/
$global:config_path            # config/
$global:main_menu              # home/menus/boulot.json
```

**Usage:** Sourced first, allows all other scripts to use these paths

---

### `config/variable_maison.ps1` (Unknown)
**Purpose:** Personal/home-specific overrides

**Usage:** Not examined, likely overrides defaults for personal machine

---

### `config/tradsh.ps1` (10 lines)
**Purpose:** External tool aliases

**Contains:**
- Alias for `tradsh` (external profile?)
- Link to external disk

**Usage:** Allows sourcing external tools if available

---

### `config/welcome.ps1` (Unknown)
**Purpose:** Startup banner/welcome message

**Usage:** Displays on PowerShell launch

---

## Application Layer

### `app/menu/menu.ps1` (164 lines)
**Classes:**
- `MenuItem` - Single menu option
  - Properties: Key, Label, Command, Submenu, Color
- `Menu` - Menu container
  - Properties: Title, Subtitle, Header, Options[], HeaderBlock, Color
  - Methods: Render(), Show(), ResolvePath()

**Design:** JSON-driven interactive CLI with nested submenus

**Usage:**
```powershell
$menu = [Menu]::new("path/to/menu.json")
$menu.Show()
```

---

### `app/bigfish/bigfish.ps1` (509 lines)
**Classes:**
1. `BigFishProfile` - Metadata storage (net capacity, settings)
2. `FishType` - Maps file size to fish type/color
   - Static tables: fishSize, fishColor
3. `FishFile` - Wraps file with type & value
4. `FishNet` - Container with capacity limit
   - Methods: AddFish(), Sell(), SellByType(), empty()
5. `Fisher` - Business logic (various catch strategies)
   - Methods: FishByCapacity(), FishByCount(), FishByType(), DeepFishByCount(), DeepFishByType(), Sell(), SellByType()
6. `FishRenderer` - ASCII output
   - Methods: RenderNet(), RenderFish(), RenderWallet(), RenderHeader(), RenderFooter(), RenderError(), RenderSuccess(), RenderHelp()
7. `FishWallet` - Tracks catches and awards points
   - Methods: AddCatch(), GetFishCount(), GetValue()
8. `BigFish` - Main command handler
   - Methods: Execute(), Fish(), DeepFish(), Sell(), Net()

**Global Instance:**
```powershell
$global:bigfish_metadata = [BigFishProfile]::new(...)
$global:bigfish = [BigFish]::new()
function bigfish { $global:bigfish.Execute($args) }
Set-Alias bf bigfish
```

**Design:** Composable OOP with fluent chaining and persistent state

---

### `app/bigfish/menu.json` (N/A)
**Purpose:** Main menu configuration for Bigfish

**Structure:** Standard Menu JSON (see menu system)

---

### `app/bigfish/menu_bigfish.json` (N/A)
**Purpose:** Submenu for Bigfish (appears unused)

---

### `app/bigfish/menu_bigfish_type.json` (N/A)
**Purpose:** Fish types menu (appears unused)

---

### `app/bigfish/persistent/profile.json`
**Data Format:**
```json
{
  "Metadata": {
    "NetCapacity": 5,
    ...
  }
}
```

**Content:** Game state (net capacity, total caught, achievements)

---

### `app/wallet/wallet.ps1` (90 lines)
**Classes:**
1. `Wallet` - Player currency
   - Properties: valeur (long), SavePath, Metadata, devise ('¥')
   - Methods: Save(), AddValue(), SetMetadata(), GetMetadata()
2. `WalletRenderer` - Display with ASCII box
   - Methods: RenderWallet()

**Global Instance:**
```powershell
$global:wallet = [Wallet]::new(...)
function Wallet() { $global:wallet rendered }
```

**Design:** Minimal but persistent score tracking

---

### `app/merchant/merchant.ps1` (120 lines)
**Classes:**
1. `MerchantItem` - Single product
   - Properties: name, description, price, Metadata
2. `MerchantItemRenderer` - Display item
3. `Merchant` - Inventory manager
   - Properties: itemsAvailable[], itemsSold[], SavePath
   - Methods: Save(), GetJsonMenu()

**Global Instance:**
```powershell
$global:Merchant_profile = [Merchant]::new(...)
function merchant() { ... }
```

**Design:** Shop system integrated with Menu and Wallet

---

### `app/merchant/persistent/profile.json`
**Data Format:**
```json
{
  "itemsAvailable": [
    { "name": "...", "description": "...", "price": 0, "Metadata": {} }
  ],
  "itemsSold": []
}
```

---

## Home (User Data) Layer

### `home/menus/boulot.json`
**Purpose:** Work context menu (default on startup)

**Includes:**
- Shortcuts to work tools
- Bigfish launcher
- Wallet access
- VS Code workspaces

---

### `home/menus/maison.json`
**Purpose:** Home context menu

**Includes:**
- Home/personal shortcuts
- Entertainment apps
- Personal tools

---

### `home/menus/outil_boulot.json`
**Purpose:** Work tools submenu

**Includes:**
- Database tools (SQL Server, etc)
- Development tools
- System utilities

---

### `home/menus/machine_boulot.json`
**Purpose:** Remote machines submenu

**Includes:**
- RDP connections
- Remote servers
- IBM applications

---

### `home/menus/vscode_boulot.json`
**Purpose:** VS Code workspaces submenu

**Includes:**
- SQL_WORKSPACE
- SSH_WORKSPACE
- VSCODE_EXTENSIONS
- ZPL_WORKSPACE
- htdocs.code-workspace
- Python.code-workspace
- Powershell.code-workspace

---

### `home/persistent/wallet.json`
**Data Format:**
```json
{
  "valeur": 42,
  "Metadata": {
    "FishCount": 5
  }
}
```

**Content:** Player score from Bigfish catches

---

## Documentation Files

### `README.md` [NEW]
Main entry point. Contains:
- Quick start
- Architecture overview
- Core apps explanation
- Commands & aliases
- Configuration guide
- Development quick start

### `ARCHITECTURE.md` [NEW]
Deep technical dive. Contains:
- Layered architecture diagram
- Data flow examples
- Class hierarchies
- Persistence patterns
- Control flow diagrams
- Type systems
- Performance considerations
- Extension points

### `DEVELOPER_GUIDE.md` [NEW]
Build your own apps. Contains:
- Minimal app template
- Interactive menu example
- Persistent state example
- Advanced patterns
- Best practices
- Testing strategy
- Debugging tips
- Common gotchas
- Extending existing apps
- Publishing apps

### `QUICKREF.md` [NEW]
One-page cheat sheet. Contains:
- All commands
- Bigfish game reference
- File paths
- Debugging commands
- Common patterns
- Tips & tricks

### `FILE_STRUCTURE.md` [NEW]
This file. Directory tree and file descriptions.

---

## Load Order

When PowerShell starts:

```
1. config/variable.ps1          ← Global paths set
2. config/welcome.ps1           ← Show banner
3. config/alias.ps1             ← Register aliases
4. config/variable_maison.ps1   ← Personal overrides
5. config/functions.ps1         ← Register functions
   ├─ app/menu/menu.ps1         ← Menu system loaded
   ├─ app/wallet/wallet.ps1     ← Wallet loaded
   ├─ app/bigfish/bigfish.ps1   ← Bigfish loaded
   └─ app/merchant/merchant.ps1 ← Merchant loaded
6. config/tradsh.ps1            ← External tools (if available)
```

**Result:** All classes available, all globals instantiated, profile ready.

---

## Size Reference

| File | Lines | Purpose |
|------|-------|---------|
| bigfish.ps1 | 509 | Main game |
| menu.ps1 | 164 | Menu system |
| merchant.ps1 | 120 | Store |
| functions.ps1 | 166 | Helpers |
| wallet.ps1 | 90 | Currency |
| alias.ps1 | 61 | Aliases |
| variable.ps1 | 22 | Paths |

**Total .ps1 code:** ~1,100 lines (excluding JSON and new docs)

---

## Git Structure

```
.git/                           Full git history
.gitignore                      Ignore patterns
.gitattributes                  Line ending rules

Tracked:
- *.ps1 files
- *.json files
- *.md files

Not tracked:
- Temp files
- IDE files (except .vscode/settings.json)
- Persistent user data (wallet.json, profile.json)
```

---

**Document Version:** 1.0  
**Last Updated:** 2024-05-19
