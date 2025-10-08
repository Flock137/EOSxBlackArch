# EndeavourOS Post-Installation Setup Script

A post-installation automation script for EndeavourOS, Arch and Arch-based distros that sets up a penetration testing environment with BlackArch repository, security tools, and a customized Zsh shell.

## ⚠️ Warning

**This script modifies your system configuration and installs packages.** Please read through the entire script before running it to understand what changes will be made to your system.

## What This Script Does

1. **Sets up BlackArch Repository**
   - Downloads and verifies the BlackArch strap.sh installer
   - Adds BlackArch repository to your system
   - Enables multilib repository

2. **Installs necessary security tools**

3. **Configures Zsh Shell**
   - Installs Zsh and Oh-My-Zsh framework
   - Installs plugins: zsh-autosuggestions, zsh-syntax-highlighting
   - Installs and configures the [heapbytes](https://github.com/heapbytes/heapbytes-zsh) theme
   - Changes your default shell to Zsh

## Prerequisites

- Fresh or existing EndeavourOS installation
- Internet connection
- Understand (at least vaguely) what the script `setup.sh` will do to your system
- Ideally, some experience with Arch or Arch-based distros

## Installation

1. **Download the script:**
   ```bash
   git clone https://github.com/Flock137/EOSxBlackArch.git
   cd EOSxBlackArch
   ```
   Or just click [here](https://github.com/Flock137/EOSxBlackArch/blob/main/setup.sh) and download it manually.

2. **Make it executable:**
   ```bash
   chmod +x setup.sh
   ```

3. **Please read the script thoroughly, if you haven't**

4. **Run the script:**
   ```bash
   ./setup.sh
   ```

## Important Notes

- **Please don't run this script as root.** It will ask for sudo privileges when needed.
- **Monitor the terminal** during execution - you'll need to enter your sudo password periodically.
- Some tools may fail to install due to some issues, likely due to them not being available to install through pacman. Failed installations will be reported at the end.
- **Log out and log back in** (or reboot) after the script completes for all changes to take effect.

## Post-execution

### Recommended manual configurations

The following are intentionally **not** automated as they vary by desktop environment and personal preference:

- **Terminal Font**: Configure a monospace font (like JetBrains Mono, Nerd fonts, Powerline, Hack, or Fira Code) in your terminal emulator settings for the best visual experience with the heapbytes theme.
- **Inside a VM**: Disable auto lock screen and sleep for your inconvenience when a long script is being run
- **Oh-my-zsh plugins**: It might not be recommended to install too many of them, as it slows down your terminal startup

### Additional BlackArch Tools

The script only installs a list of tools accordingly to my preferences. To explore more:

```bash
# List all available BlackArch tools
sudo pacman -Sgg | grep blackarch | cut -d' ' -f2 | sort -u

# See BlackArch tool categories
sudo pacman -Sg | grep blackarch

# Install an entire category
sudo pacman -S blackarch-<category>
```

### Customizing Zsh

Edit your Zsh configuration:
```bash
vim ~/.zshrc
# Or whichever text editor you like
```

After making changes:
```bash
source ~/.zshrc
```
Or just exit the terminal and open it again.

## Contributing

Please do feel free to:
- Report issues
- Suggest additional tools
- Submit pull requests for improvements

## Disclaimer

This script is provided as-is without any warranties. The author is not responsible for any damage or issues caused by running this script. Always backup your system before making significant changes.

Use the installed security tools ethically and legally. Unauthorized access to computer systems is illegal.

## References

- [BlackArch - Installing on top of Arch Linux](https://blackarch.org/downloads.html#install-repo)
- [Installing Oh-my-zsh](https://ohmyz.sh/#install)
- [How to install zsh-autosuggestions and zsh-syntax-highlighting](https://gist.github.com/n1snt/454b879b8f0b7995740ae04c5fb5b7df)
- [heapbytes zsh-theme](https://github.com/heapbytes/heapbytes-zsh)
