# StutterFix - CFG Manager for Games

A PowerShell utility to manage Control Flow Guard (CFG) settings for games to fix stuttering and performance issues on Windows.

![CFG Manager Interface](https://i.imgur.com/SlNupqY.png)

## 🎮 What Does This Do?

Control Flow Guard (CFG) is a Windows security feature that can sometimes cause stuttering and performance issues in certain games. This tool provides a simple interface to disable or enable CFG for specific games without manually editing registry settings.

## ✨ Features

- **Interactive Menu** - Easy-to-use interface to manage CFG settings
- **Batch Operations** - Enable or disable CFG for all games at once
- **Real-time Status** - See which games have CFG enabled or disabled
- **Custom Game List** - Add your own games to the list
- **Safe Management** - Handles Windows registry safely with proper error handling

## 🚀 Quick Start

### Prerequisites

- Windows 10/11
- PowerShell (comes pre-installed on Windows)
- Administrator privileges (required to modify system settings)

### Installation

1. Download or clone this repository
2. Extract the files to a folder
3. Add your game executables to `GameList.txt` (one per line)

### Usage

1. Right-click `FixStutter.ps1` and select **Run with PowerShell**
   - Or run from PowerShell: `.\FixStutter.ps1`
2. The script will automatically request Administrator privileges
3. Use the interactive menu to:
   - Toggle CFG for individual games (press the game's number)
   - Disable CFG for all games (press `D`)
   - Enable CFG for all games (press `A`)
   - Refresh the status (press `R`)
   - Exit (press `Q`)

## 📝 Adding Games

Edit `GameList.txt` and add the executable name of your game (one per line):

```
PioneerGame.exe                      # ARC Raiders
Discovery.exe                        # THE FINALS
Marvel-Win64-Shipping.exe            # Marvel Rivals
YourGame.exe                         # Your Game Name
```

**Note:** Only include the executable name (e.g., `game.exe`), not the full path.

## 📋 Included Games

The default `GameList.txt` includes:
- ARC Raiders
- THE FINALS
- Firefighting Simulator: Ignite
- Marvel Rivals
- Ready or Not
- Genshin Impact
- Dead by Daylight

## 🎯 How It Works

When CFG is disabled for a game:
- The script uses PowerShell's `Set-ProcessMitigation` cmdlet to modify Windows security settings
- CFG is disabled only for specific game executables, not system-wide
- Changes persist across reboots

When CFG is enabled (re-enabled):
- The script removes the registry entries that disable CFG
- The game returns to Windows default security settings

## ⚠️ Important Notes

- **Administrator privileges are required** - The script modifies system-level security settings
- **Backup recommended** - Consider creating a system restore point before using
- **Security implications** - Disabling CFG reduces security protections for those specific executables
- **Results may vary** - CFG isn't the cause of stuttering for all games; effectiveness depends on the specific game

## 🔧 Troubleshooting

### Script won't run
- Right-click `FixStutter.ps1` → **Properties** → Check **Unblock** if present
- Run PowerShell as Administrator and execute: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### Changes don't take effect
- Make sure you're using the exact executable name from Task Manager
- Restart the game after making changes
- Verify the script ran with Administrator privileges (check the window title)

### Game not listed
1. Open Task Manager while the game is running
2. Find the game's process name (e.g., `game.exe`)
3. Add that name to `GameList.txt`
4. Press `R` in the script to refresh

## 🛡️ Security Considerations

Disabling Control Flow Guard reduces security protections for the affected executables. Only disable CFG for:
- Trusted games and applications
- Programs where you're experiencing performance issues
- Software from reputable sources

Re-enable CFG when you're done testing or if you're not experiencing stuttering.

## 📄 License

This project is provided as-is for personal use. Use at your own risk.

## 🤝 Contributing

Feel free to:
- Add more games to the default list
- Report issues or bugs
- Suggest improvements
- Submit pull requests

## 💡 Tips

- Test one game at a time to see if disabling CFG helps
- Monitor performance with tools like MSI Afterburner
- Re-enable CFG if you don't notice improvement
- Keep your game list organized with comments (using `#`)

## ⚡ Performance Impact

Disabling CFG may help with:
- Micro-stuttering
- Frame pacing issues
- Input lag in some games
- FPS drops during intensive scenes

Results vary by game and system configuration.

---

**Made with ❤️ for smoother gaming**
