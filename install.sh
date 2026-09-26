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

echo "[1/14] Configuring GRUB..."

if grep -q '^GRUB_TIMEOUT=' /etc/default/grub; then
    sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
else
    echo 'GRUB_TIMEOUT=0' >> /etc/default/grub
fi

# ------------------------------------------
# 2. Update repositories
# ------------------------------------------

echo
echo "[2/14] Updating package lists..."

apt update

# ------------------------------------------
# 3. Install Mesa Vulkan drivers
# ------------------------------------------

echo
echo "[3/14] Installing Mesa Vulkan drivers..."

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
echo "[4/14] Installing Wine..."

apt install -y wine

# ------------------------------------------
# 5. Install Wine Mono
# ------------------------------------------

echo
echo "[5/14] Installing Wine Mono..."

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
echo "[6/14] Installing compositor..."

install_dragged_file "Please drag the COMPOSITOR installation file here:"

# ------------------------------------------
# 7. Install LineXinBar
# ------------------------------------------

echo
echo "[7/14] Installing LineXinBar..."

install_dragged_file "Please drag the LINE XIN BAR installation file here:"

# ------------------------------------------
# 8. Install Flatpak and Flathub
# ------------------------------------------

echo
echo "[8/14] Installing Flatpak and Flathub..."

apt install -y flatpak

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo
echo "Updating Flathub AppStream metadata..."

flatpak update --appstream


# ------------------------------------------
# 10. Install DistriBumpy
# ------------------------------------------

echo
echo "[9/14] Installing DistriBumpy..."

install_dragged_file "Please drag the DISTRIBUMPY installation file here:"

# ------------------------------------------
# 11. Install CEDM
# ------------------------------------------

echo
echo "[10/14] Installing CEDM..."

install_dragged_file "Please drag the CEDM installation file here:"

# ------------------------------------------
# 12. Install greetd
# ------------------------------------------

echo
echo "[11/14] Installing greetd..."

apt install -y greetd

# ------------------------------------------
# 13. Check greetd location
# ------------------------------------------

echo
echo "[12/14] Checking greetd location..."

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
# 14. Configure display manager
# ------------------------------------------

echo
echo "[13/14] Configuring display manager..."

echo "Disabling LightDM..."

systemctl disable lightdm.service 2>/dev/null || true

echo "Enabling CEDM..."

systemctl daemon-reload
systemctl enable cedm.service

# ------------------------------------------
# 14. Update GRUB
# ------------------------------------------

echo
echo "[14/14] Updating GRUB..."

update-grub

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