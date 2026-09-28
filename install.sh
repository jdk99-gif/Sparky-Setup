#!/bin/sh

echo "=========================================="
echo " SparkyLinux Gaming Setup"
echo "=========================================="
echo

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script with sudo:"
    echo "  sudo ./install.sh"
    exit 1
fi

# ------------------------------------------
# Helper: install dragged file
# ------------------------------------------

USER_NAME="${SUDO_USER:-$USER}"

sudo -u "$USER_NAME" xdg-open "https://jdk99-gif.github.io/Sparky-Setup/" >/dev/null 2>&1 &

echo
echo "Please wait until the website loads."
echo
printf "Press Enter to continue..."
read _
echo

install_dragged_file() {
    MESSAGE="$1"

    echo
    echo "------------------------------------------"
    echo "$MESSAGE"
    echo "------------------------------------------"
    printf "File: "

    read FILE

    # Remove quotes added by the terminal
    FILE=$(printf '%s' "$FILE" | sed "s/^['\"]//;s/['\"]\$//")

    if [ ! -f "$FILE" ]; then
        echo
        echo "ERROR: The selected file does not exist."
        exit 1
    fi

    echo
    echo "Installing selected file..."
    apt install -y "$FILE"
}

# ------------------------------------------
# 1. Configure GRUB
# ------------------------------------------

echo "[1/20] Configuring GRUB..."

if grep -q '^GRUB_TIMEOUT=' /etc/default/grub; then
    sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
else
    echo 'GRUB_TIMEOUT=0' >> /etc/default/grub
fi

# ------------------------------------------
# 2. Update repositories
# ------------------------------------------

echo
echo "[2/20] Updating package lists..."

apt update

# ------------------------------------------
# 3. Upgrade system
# ------------------------------------------

echo
echo "[3/20] Upgrading The System..."

apt upgrade

# ------------------------------------------
# 4. Install Mesa Vulkan drivers
# ------------------------------------------

echo
echo "[4/20] Installing Mesa Vulkan drivers..."

if apt-cache show mesa-vulkan-drivers >/dev/null 2>&1; then
    apt install -y mesa-vulkan-drivers
else
    echo "mesa-vulkan-drivers is not available in the configured repositories."
    echo "Continuing without it..."
fi

# ------------------------------------------
# 5. Install Wine
# ------------------------------------------

echo
echo "[5/20] Installing Wine..."

apt install -y wine

# ------------------------------------------
# 6. Install Wine Mono
# ------------------------------------------

echo
echo "[6/20] Installing Wine Mono..."

if apt-cache show wine-mono >/dev/null 2>&1; then
    apt install -y wine-mono
else
    echo "wine-mono is not available in the configured repositories."
    echo "Wine will still be installed."
fi

# ------------------------------------------
# 7. Install compositor
# ------------------------------------------

echo
echo "[7/20] Installing compositor..."

install_dragged_file "Please drag the COMPOSITOR installation file here:"

# ------------------------------------------
# 8. Install LineXinBar
# ------------------------------------------

echo
echo "[8/20] Installing LineXinBar..."

install_dragged_file "Please drag the LINEXINBAR installation file here:"

# ------------------------------------------
# 9. Install Flatpak and Flathub
# ------------------------------------------

echo
echo "[9/20] Installing lxb-retroarch"

install_dragged_file "Please drag the lxb-retroarch installation file here:"


echo
echo "[10/20] Installing Flatpak and Flathub..."

apt install -y flatpak

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo
echo "Updating Flathub AppStream metadata..."

flatpak update --appstream

# ------------------------------------------
# 10. Install DistriBumpy
# ------------------------------------------

echo
echo "[11/20] Installing DistriBumpy..."

install_dragged_file "Please drag the DISTRIBUMPY installation file here:"

# ------------------------------------------
# 11. Install CEDM
# ------------------------------------------

echo
echo "[12/20] Installing CEDM..."

install_dragged_file "Please drag the CEDM installation file here:"

# ------------------------------------------
# 12. Install ImagOnSole
# ------------------------------------------

echo
echo "[13/20] Installing ImagOnSole..."

install_dragged_file "Please drag the IMAGONSOLE installation file here:"

# ------------------------------------------
# 13. Install VideOnSole
# ------------------------------------------

echo
echo "[14/20] Installing VideOnSole..."

install_dragged_file "Please drag the VIDEONSOLE installation file here:"

# ------------------------------------------
# 14. Install SongOnSole
# ------------------------------------------

echo
echo "[15/20] Installing SongOnSole..."

install_dragged_file "Please drag the SONGONSOLE installation file here:"

# ------------------------------------------
# 15. Install greetd
# ------------------------------------------

echo
echo "[16/20] Installing greetd..."

apt install -y greetd

# ------------------------------------------
# 16. Check greetd location
# ------------------------------------------

echo
echo "[17/20] Checking greetd location..."

GREETD_PATH="$(command -v greetd || true)"

if [ -z "$GREETD_PATH" ]; then
    echo "ERROR: greetd was not found."
    exit 1
fi

echo "greetd found at:"
echo "$GREETD_PATH"

if [ "$GREETD_PATH" != "/usr/bin/greetd" ]; then
    echo
    echo "Creating /usr/bin/greetd symlink..."

    if [ -e /usr/bin/greetd ] || [ -L /usr/bin/greetd ]; then
        rm -f /usr/bin/greetd
    fi

    ln -s "$GREETD_PATH" /usr/bin/greetd
fi

echo
echo "greetd is available at:"
ls -l /usr/bin/greetd

# ------------------------------------------
# 17. Configure display manager
# ------------------------------------------

echo
echo "[18/20] Configuring display manager..."

echo "Disabling LightDM..."

systemctl disable lightdm.service 2>/dev/null || true

echo "Enabling CEDM..."

systemctl daemon-reload
systemctl enable cedm.service

# ------------------------------------------
# 18. Update GRUB
# ------------------------------------------

echo
echo "[19/20] Updating GRUB..."

update-grub

# ------------------------------------------
# 19. Remove unwanted package managers
# ------------------------------------------

echo
echo "[20/20] Removing Synaptic, GDebi and APTus AppCenter..."

apt remove -y synaptic gdebi gdebi-core sparky-aptus-appcenter

# ------------------------------------------
# Install KDE Konsole
# ------------------------------------------

echo
echo "Installing KDE Konsole..."

apt install -y konsole

echo
echo "Removing XFCE Terminal..."

apt remove -y xfce4-terminal

# ------------------------------------------
# Finished
# ------------------------------------------

echo
echo "=========================================="
echo " Installation completed successfully!"
echo "=========================================="
echo
echo "The system is ready."
echo
echo "Please reboot the system."
echo
