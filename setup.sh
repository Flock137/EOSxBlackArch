#!/bin/bash

# EndeavourOS Post-Installation Setup Script
# Automates BlackArch repo setup, security tools installation, and zsh customization

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[*]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

# Check if script is run as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root. It will ask for sudo when needed."
    exit 1
fi

FAILED_TOOLS=()

echo "================================================"
echo "   EndeavourOS Post-Installation Setup Script   "
echo "================================================"
echo ""

print_warning "This script will modify your system configuration and install packages."
print_info "Specifically, it will:"
echo "  - Add the BlackArch repository"
echo "  - Modify /etc/pacman.conf to enable multilib, in order to add the said repo"
echo "  - Install security tools"
echo "  - Set up Zsh with Oh-My-Zsh, its plugins and change default shell to zsh"
echo "  - Change your terminal handle to something like that of BlackArch or Kali Linux"
echo "  - You may also adjust the script manually to add the tools that you wish to have"
echo ""
read -p "Have you read and understood this script? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]([Ee][Ss])?$ ]]; then
    print_message "Okay, have fun! :)"
    print_info "Please take a look at your terminal once in a while to input sudo password"
    echo ""
else
    print_warning "Please read the script first, else you may break your system :("
    print_info "You can view it at: https://github.com/Flock137/EOSxBlackArch"
    exit 0
fi

# Check if curl existed, if no, install it
if ! command -v curl &> /dev/null; then
    print_warning "curl not found. Installing curl..."
    sudo pacman -S --needed --noconfirm curl
    print_message "curl installed!"
else
    print_info "curl is already installed."
fi

# ==========================================
# 1. BLACKARCH REPOSITORY SETUP
# ==========================================

print_message "Setting up BlackArch repository..."

# Download strap.sh
print_info "Downloading strap.sh..."
curl -O https://blackarch.org/strap.sh

# Verify SHA1 sum
print_info "Verifying SHA1 checksum..."
if echo "e26445d34490cc06bd14b51f9924debf569e0ecb strap.sh" | sha1sum -c; then
    print_message "Checksum verified successfully!"
else
    print_error "Checksum verification failed! Exiting for security."
    exit 1
fi

# Set execute bit
chmod +x strap.sh

# Run strap.sh
print_info "Running strap.sh to add BlackArch repository..."
sudo ./strap.sh

# Clean up strap.sh
rm strap.sh

# Enable multilib
print_info "Enabling multilib repository..."
if grep -q "^\[multilib\]" /etc/pacman.conf; then
    print_warning "Multilib already enabled, skipping..."
else
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    print_message "Multilib enabled!"
fi

# Update system
print_message "Updating system packages..."
sudo pacman -Syu --noconfirm

print_message "BlackArch repository setup complete!"
echo ""

# ==========================================
# 2. INSTALL SECURITY TOOLS
# ==========================================

print_message "Installing security tools (and virtualbox-guest-utils)..."

# List of tools to install
TOOLS=(
    "cutter"
    "burpsuite"
    "binaryninja-free"
    "ghidra"
    "impacket"
    "stegsolve"
    "steghide"
    "audacity"
    "bloodhound"
    "python-uncompyle6"
    "villain"
    "rekall"
    "autopsy"
    "vim"
    "virtualbox-guest-utils"
    "bat"
    "frida"
    "kitty"
    # add more tools here if you want
)

# Install each tool
for tool in "${TOOLS[@]}"; do
    print_info "Installing $tool..."
    if sudo pacman -S --needed --noconfirm "$tool" 2>/dev/null; then
        print_message "$tool installed successfully!"
    else
        print_error "Failed to install $tool. You may need to install it manually."
        FAILED_TOOLS+=("$tool")
    fi
done

print_message "Security tools installation complete!"
echo ""

# ==========================================
# 3. ZSH SETUP
# ==========================================

print_message "Setting up Zsh shell..."

# Install zsh
print_info "Installing zsh..."
sudo pacman -S --needed --noconfirm zsh

# Install oh-my-zsh
print_info "Installing Oh-My-Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_warning "Oh-My-Zsh already installed, skipping..."
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_message "Oh-My-Zsh installed!"
fi

# Set ZSH_CUSTOM path
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install zsh-autosuggestions
print_info "Installing zsh-autosuggestions plugin..."
if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_warning "zsh-autosuggestions already installed, skipping..."
else
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    print_message "zsh-autosuggestions installed!"
fi

# Install zsh-syntax-highlighting
print_info "Installing zsh-syntax-highlighting plugin..."
if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    print_warning "zsh-syntax-highlighting already installed, skipping..."
else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    print_message "zsh-syntax-highlighting installed!"
fi

# Update .zshrc with plugins
print_info "Configuring plugins in .zshrc..."
if grep -q "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)" "$HOME/.zshrc"; then
    print_warning "Plugins already configured, skipping..."
else
    sed -i 's/^plugins=(git)$/plugins=(git\n    zsh-autosuggestions\n    zsh-syntax-highlighting)/' "$HOME/.zshrc"
    print_message "Plugins configured!"
fi

# ==========================================
# 4. HEAPBYTES THEME SETUP
# ==========================================

print_message "Installing heapbytes zsh theme..."

# Create themes directory if it doesn't exist
mkdir -p "$ZSH_CUSTOM/themes"

# Download heapbytes theme
print_info "Downloading heapbytes theme..."
curl -fsSL https://github.com/heapbytes/heapbytes-zsh/raw/refs/heads/main/heapbytes.zsh-theme -o "$ZSH_CUSTOM/themes/heapbytes.zsh-theme"

# Set theme in .zshrc
print_info "Setting heapbytes as default theme..."
sed -i 's/^ZSH_THEME=".*"$/ZSH_THEME="heapbytes"/' "$HOME/.zshrc"

print_message "Heapbytes theme installed and configured!"
print_info "You need to install and configure manually a Nerd-font, or Powerline font for icons rendering"

echo ""

# ==========================================
# 5. CHANGE DEFAULT SHELL
# ==========================================

print_message "Changing default shell to zsh..."

# Check current shell
if [ "$SHELL" = "$(which zsh)" ]; then
    print_warning "Zsh is already your default shell!"
else
    chsh -s "$(which zsh)"
    print_message "Default shell changed to zsh!"
fi

echo ""
echo "================================================"
echo "           Setup Complete!                      "
echo "================================================"
echo ""
print_info "Summary of what was installed:"
echo "  - BlackArch repository"
echo "  - Your security tools, aside from the necessary ones"
echo "  - Zsh and Oh-My-Zsh"
echo "  - zsh-autosuggestions and zsh-syntax-highlighting plugins"
echo "  - heapbytes theme for hackers:)"
echo ""

# Add this section for failed tools
if [ ${#FAILED_TOOLS[@]} -gt 0 ]; then
    print_warning "The following tools failed to install:"
    for tool in "${FAILED_TOOLS[@]}"; do
        echo "  - $tool"
    done
    echo ""
    print_info "You can try installing them manually with the AUR (use yay, paru, etc.) or make your own PKGBUILD if it doesn't exist yet"
    echo ""
fi

print_warning "IMPORTANT: Please log out and log back in (or reboot, if the former doesn't work) for all changes to take effect!"
echo ""
print_info "You can customize your setup further by editing ~/.zshrc"
print_info "To list all BlackArch tools: sudo pacman -Sgg | grep blackarch | cut -d' ' -f2 | sort -u"
print_info "To see BlackArch categories: sudo pacman -Sg | grep blackarch"
print_info "To install a category of tools: sudo pacman -S blackarch-<category>"
echo ""
print_info "Additional tips:"
echo "In a VM, you may like to toggle your sleep off, so it doesn't interrupt your running script:D"
