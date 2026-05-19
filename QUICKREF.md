# Quick Reference

Cheat sheet for common tasks.

---

## Commands

### Navigation
```powershell
ls                      List files
ll                      List files with details
..                      Go to parent directory
cd path                 Change directory
pwd                     Print working directory
```

### File Operations
```powershell
touch file.txt          Create file
mkdir dir               Create directory
mkcd dir                Create & enter directory
cat file.txt            Show file contents
rm file                 Delete file
rmrf dir                Delete directory recursively
cp src dst              Copy
mv src dst              Move
```

### System
```powershell
df                      Disk usage
free                    Memory usage
ps                      List processes
uptime                  Time since boot
myip                    Your public IP
ports                   Open listening ports
diskbar                 Show disk usage visually
```

### Applications
```powershell
mm                      Main menu
bf                      Bigfish (alias)
wallet                  Show wallet/score
merchant                Visit merchant
code SQL|SSH|...        Open VS Code workspace
codeWS                  Same as above
```

---

## Bigfish Game

### Fishing
```powershell
bigfish fish            Catch largest file
bigfish fish 5          Catch 5 largest files
bigfish fish saumon     Catch all saumon-sized files (1MB+)
bigfish deepfish 10     Search subdirectories for 10 largest
```

### Management
```powershell
bigfish net             Show what's in your net
bigfish net empty       Empty net without selling
bigfish sell            Delete files & earn points
bigfish sell saumon     Sell only saumon-sized fish
```

### Info
```powershell
bigfish help            Show all commands
bf help                 Alias for above
```

### Fish Types (by size)
```
krill (< 10 KB)        → DarkGray
maquereau (10 KB)      → Gray
saumon (1 MB)          → White
daurade (100 MB)       → Green
thon (500 MB)          → Yellow
orque (1 GB)           → Red
baleine (10 GB)        → Magenta
```

---

## File Paths

```powershell
# View important paths
$global:powershell_folder              # Profile root
$global:persistent_home_path           # Data storage
$global:bigfish_path                   # Bigfish app
$global:menu_path                      # Menu system
$global:wallet_class_path              # Wallet app
```

---

## JSON Locations

```
home/persistent/wallet.json            Player score/coins
app/bigfish/persistent/profile.json    Bigfish settings
app/merchant/persistent/profile.json   Merchant inventory
home/menus/boulot.json                 Work menu
home/menus/maison.json                 Home menu
```

---

## Debugging

### Check Profile Loaded
```powershell
$global:bigfish                 # Should exist
$global:wallet                  # Should exist
$global:powershell_folder       # Should be set
```

### Reload Profile
```powershell
. $PROFILE
```

### Check JSON Syntax
```powershell
Get-Content home/menus/boulot.json | ConvertFrom-Json
```

### View Data
```powershell
# Wallet
cat $global:persistent_home_path\wallet.json

# Bigfish
cat $global:bigfish_path\persistent\profile.json
```

---

## Useful Variables

```powershell
$PSVersionTable             PowerShell version info
$PROFILE                    Path to this profile
$PWD                        Current directory
$HOME                       User home directory
$ENV:APPDATA               AppData folder
$ENV:USERPROFILE           User profile folder
```

---

## Color Names

```powershell
Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray
DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White
```

---

## Common Patterns

### Create Empty File
```powershell
touch file.txt
```

### Count Lines
```powershell
wc file.txt
```

### Search History
```powershell
hist "keyword"
```

### Get Weather
```powershell
meteo Paris
meteo London
```

### Extract Archive
```powershell
extract file.zip
extract file.tar.gz
```

---

## Environment Setup

### First Run
1. Edit `config/variable.ps1`
2. Update path variables
3. Restart PowerShell
4. Type `mm` to test menu

### Custom Menu
Edit `home/menus/boulot.json`:
- `key` = button to press
- `label` = displayed text
- `command` = PowerShell command to run

---

## Tips & Tricks

- **Use aliases** - `bf` instead of `bigfish`, `mm` instead of `mainmenu`
- **Chainable methods** - Fisher methods return `$this` for chaining
- **Keyboard shortcuts** - Use menu keys for quick access
- **Check colors** - Run `ShowColors` to see available colors
- **Test commands** - Add ` -WhatIf` to see what would happen
- **Redirect output** - `command | Out-File result.txt`

---

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| ↑ / ↓ | History navigation (PSReadLine) |
| Tab | Auto-complete |
| Ctrl+A | Select all |
| Ctrl+C | Cancel command |
| Ctrl+L | Clear screen |
| Ctrl+R | Search history (Ctrl+S for prev) |

---

**Last Updated:** 2024-05-19
