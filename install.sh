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

USER_NAME="${SUDO_USER:-$USER}"

sudo -u "$USER_NAME" xdg-open "https://jdk99-gif.github.io/Sparky-Setup/" >/dev/null 2>&1 &

echo
echo "Please wait until the website loads."
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
# 1. Install Liquorix Kernel and set as 1st in GRUB
# ------------------------------------------

echo "[1/23] Installing Liquorix Kernel and configuring GRUB..."

apt update
apt install -y curl

curl -fsSL https://liquorix.net/install-liquorix.sh | bash

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install Liquorix kernel."
    exit 1
fi

# Ustawienie indeksu 0 (pierwsza pozycja w GRUB) jako domyślnego jądra
sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=0/' /etc/default/grub

if ! grep -q "^GRUB_DEFAULT=" /etc/default/grub; then
    echo 'GRUB_DEFAULT=0' >> /etc/default/grub
fi

# ------------------------------------------
# 2. Configure GRUB Timeout
# ------------------------------------------

echo
echo "[2/23] Configuring GRUB timeout..."

if grep -q '^GRUB_TIMEOUT=' /etc/default/grub; then
    sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
else
    echo 'GRUB_TIMEOUT=0' >> /etc/default/grub
fi

# ------------------------------------------
# 3. Update repositories
# ------------------------------------------

echo
echo "[3/23] Updating package lists..."
apt update

# ------------------------------------------
# 4. Upgrade system
# ------------------------------------------

echo
echo "[4/23] Upgrading the system..."
apt upgrade

# ------------------------------------------
# 5. Install Mesa Vulkan drivers
# ------------------------------------------

echo
echo "[5/23] Installing Mesa Vulkan drivers..."

if apt-cache show mesa-vulkan-drivers >/dev/null 2>&1; then
    apt install -y mesa-vulkan-drivers
else
    echo "mesa-vulkan-drivers is not available in the configured repositories."
    echo "Continuing without it..."
fi

# ------------------------------------------
# 6. Install Wine
# ------------------------------------------

echo
echo "[6/23] Installing Wine..."
apt install -y wine

# ------------------------------------------
# 7. Install Wine Mono
# ------------------------------------------

echo
echo "[7/23] Installing Wine Mono..."

if apt-cache show wine-mono >/dev/null 2>&1; then
    apt install -y wine-mono
else
    echo "wine-mono is not available in the configured repositories."
    echo "Wine will still be installed."
fi

# ------------------------------------------
# 8. Install compositor
# ------------------------------------------

echo
echo "[8/23] Installing compositor..."
install_dragged_file "Please drag the COMPOSITOR installation file here:"

# ------------------------------------------
# 9. Install LineXinBar
# ------------------------------------------

echo
echo "[9/23] Installing LineXinBar..."
install_dragged_file "Please drag the LINEXINBAR installation file here:"

# ------------------------------------------
# 10. Install lxb-retroarch
# ------------------------------------------

echo
echo "[10/23] Installing lxb-retroarch..."
install_dragged_file "Please drag the lxb-retroarch installation file here:"

# ------------------------------------------
# 11. Install lxb-heroic
# ------------------------------------------

echo
echo "[11/23] Installing lxb-heroic..."
install_dragged_file "Please drag the lxb-heroic installation file here:"

# ------------------------------------------
# 12. Install Flatpak and Flathub
# ------------------------------------------

echo
echo "[12/23] Installing Flatpak and Flathub..."

apt install -y flatpak

flatpak remote-add --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo

echo
echo "Updating Flathub AppStream metadata..."
flatpak update --appstream

# ------------------------------------------
# 13. Install RPCS3 through Flatpak
# ------------------------------------------

echo
echo "[13/23] Installing RPCS3 through Flatpak..."

flatpak install -y flathub net.rpcs3.RPCS3

# ------------------------------------------
# 14. Install lxb-rpcs3
# ------------------------------------------

echo
echo "[14/23] Installing lxb-rpcs3..."
install_dragged_file "Please drag the lxb-rpcs3 installation file here:"

# ------------------------------------------
# 15. Install DistriBumpy
# ------------------------------------------

echo
echo "[15/23] Installing DistriBumpy..."
install_dragged_file "Please drag the DISTRIBUMPY installation file here:"

# ------------------------------------------
# 16. Install CEDM
# ------------------------------------------

echo
echo "[16/23] Installing CEDM..."
install_dragged_file "Please drag the CEDM installation file here:"

# ------------------------------------------
# 17. Install ImagOnSole
# ------------------------------------------

echo
echo "[17/23] Installing ImagOnSole..."
install_dragged_file "Please drag the IMAGONSOLE installation file here:"

# ------------------------------------------
# 18. Install VideOnSole
# ------------------------------------------

echo
echo "[18/23] Installing VideOnSole..."
install_dragged_file "Please drag the VIDEONSOLE installation file here:"

# ------------------------------------------
# 19. Install SongOnSole
# ------------------------------------------

echo
echo "[19/23] Installing SongOnSole..."
install_dragged_file "Please drag the SONGONSOLE installation file here:"

# ------------------------------------------
# 20. Install greetd
# ------------------------------------------

echo
echo "[20/23] Installing greetd..."
apt install -y greetd

# ------------------------------------------
# 21. Check greetd location
# ------------------------------------------

echo
echo "[21/23] Checking greetd location..."

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
# 22. Configure display manager
# ------------------------------------------

echo
echo "[22/23] Configuring display manager..."

echo "Disabling LightDM..."
systemctl disable lightdm.service 2>/dev/null || true

echo "Enabling CEDM..."
systemctl daemon-reload
systemctl enable cedm.service

# ------------------------------------------
# 23. Update GRUB and remove unwanted packages
# ------------------------------------------

echo
echo "[23/23] Updating GRUB..."
update-grub

echo
echo "Removing Synaptic, GDebi and APTus AppCenter..."
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