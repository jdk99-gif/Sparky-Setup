#!/bin/sh

echo "=========================================="
echo " SparkyLinux Gaming Setup"
echo "=========================================="
echo

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script with sudo:"
    echo "  sudo sh install.sh"
    exit 1
fi

# ------------------------------------------
# Helper: install dragged file
# ------------------------------------------

USER_NAME="${SUDO_USER:-$USER}"

sudo -u "$USER_NAME" xdg-open "https://jdk99-gif.github.io/Sparky-Setup/" >/dev/null 2>&1 &

echo
echo "Please Wait To Webside Open"
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

echo "[1/17] Configuring GRUB..."

if grep -q '^GRUB_TIMEOUT=' /etc/default/grub; then
    sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
else
    echo 'GRUB_TIMEOUT=0' >> /etc/default/grub
fi

# ------------------------------------------
# 2. Update repositories
# ------------------------------------------

echo
echo "[2/17] Updating package lists..."

apt update

# ------------------------------------------
# 3. Install Mesa Vulkan drivers
# ------------------------------------------

echo
echo "[3/17] Installing Mesa Vulkan drivers..."

if apt-cache show mesa-vulkan-drivers >/dev/null 2>&1; then
    apt install -y mesa-vulkan-drivers
else
    echo "mesa-vulkan-drivers is not available in the configured repositories."
    echo "Continuing without it..."
fi

# ------------------------------------------
# 4. Install Wine
# ------------------------------------------

echo
echo "[4/17] Installing Wine..."

apt install -y wine

# ------------------------------------------
# 5. Install Wine Mono
# ------------------------------------------

echo
echo "[5/17] Installing Wine Mono..."

if apt-cache show wine-mono >/dev/null 2>&1; then
    apt install -y wine-mono
else
    echo "wine-mono is not available in the configured repositories."
    echo "Wine will still be installed."
fi

# ------------------------------------------
# 6. Install compositor
# ------------------------------------------

echo
echo "[6/17] Installing compositor..."

install_dragged_file "Please drag the COMPOSITOR installation file here:"

# ------------------------------------------
# 7. Install LineXinBar
# ------------------------------------------

echo
echo "[7/17] Installing LineXinBar..."

install_dragged_file "Please drag the LINE XIN BAR installation file here:"

# ------------------------------------------
# 8. Install Flatpak and Flathub
# ------------------------------------------

echo
echo "[8/17] Installing Flatpak and Flathub..."

apt install -y flatpak

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo
echo "Updating Flathub AppStream metadata..."

flatpak update --appstream

# ------------------------------------------
# 9. Install DistriBumpy
# ------------------------------------------

echo
echo "[9/17] Installing DistriBumpy..."

install_dragged_file "Please drag the DISTRIBUMPY installation file here:"

# ------------------------------------------
# 10. Install CEDM
# ------------------------------------------

echo
echo "[10/17] Installing CEDM..."

install_dragged_file "Please drag the CEDM installation file here:"

# ------------------------------------------
# 11. Install ImagOnSole
# ------------------------------------------

echo
echo "[11/17] Installing ImagOnSole..."

install_dragged_file "Please drag the IMAGONSOLE installation file here:"

# ------------------------------------------
# 12. Install VideOnSole
# ------------------------------------------

echo
echo "[12/17] Installing VideOnSole..."

install_dragged_file "Please drag the VIDEONSOLE installation file here:"

# ------------------------------------------
# 13. Install SongOnSole
# ------------------------------------------

echo
echo "[13/17] Installing SongOnSole..."

install_dragged_file "Please drag the SONGONSOLE installation file here:"

# ------------------------------------------
# 14. Install greetd
# ------------------------------------------

echo
echo "[14/17] Installing greetd..."

apt install -y greetd

# ------------------------------------------
# 15. Check greetd location
# ------------------------------------------

echo
echo "[15/17] Checking greetd location..."

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
# 16. Configure display manager
# ------------------------------------------

echo
echo "[16/17] Configuring display manager..."

echo "Disabling LightDM..."

systemctl disable lightdm.service 2>/dev/null || true

echo "Enabling CEDM..."

systemctl daemon-reload
systemctl enable cedm.service

# ------------------------------------------
# 17. Update GRUB
# ------------------------------------------

echo
echo "[17/17] Updating GRUB..."

update-grub

# ------------------------------------------
# Finished
# ------------------------------------------

echo
echo "Installing KDE Konsole..."
apt install -y konsole && echo "" && echo "Removing XFCE Terminal..." && apt remove -y xfce4-terminal

echo
echo "=========================================="
echo " Installation completed successfully!"
echo "=========================================="
echo
echo "The system is ready."
echo
echo "Please reboot the system."
echo ""