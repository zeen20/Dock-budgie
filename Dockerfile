# Use an Ubuntu base image
FROM ubuntu:22.04

# Set environment variables to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    sudo \
    ufw \
    gnome-session \
    gnome-shell \
    gnome-control-center \
    gnome-terminal \
    gnome-settings-daemon \
    gnome-software \
    gnome-calculator \
    gnome-disk-utility \
    gnome-screenshot \
    gnome-system-monitor \
    gnome-tweaks \
    nautilus \
    gnome-music \
    totem \
    gnome-notes \
    file-roller \
    p7zip-full \
    gnome-calendar \
    gnome-characters \
    gnome-contacts \
    gnome-maps \
    gnome-weather \
    gnome-shell-extensions \
    gnome-clocks \
    gnome-font-viewer \
    vlc \
    hardinfo \
    gedit \
    git \
    gdebi \
    bleachbit \
    shotwell \
    xpdf \
    gftp \
    qbittorrent \
    yaru-theme-gtk \
    yaru-theme-icon \
    plasma-discover \
    flatpak \
    plasma-discover-backend-flatpak \
    && apt-get clean

# Install PeaZip and Free Download Manager
RUN wget https://github.com/peazip/PeaZip/releases/download/10.0.0/peazip_10.0.0.LINUX.GTK2-1_amd64.deb -O /tmp/peazip.deb \
    && dpkg -i /tmp/peazip.deb \
    && apt-get install -f -y \
    && rm /tmp/peazip.deb \
    && wget https://files2.freedownloadmanager.org/fdm6_qt5/freedownloadmanager.deb -O /tmp/fdm.deb \
    && gdebi /tmp/fdm.deb -n \
    && rm /tmp/fdm.deb

# Install Chrome Remote Desktop
RUN wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb -O /tmp/chrome-remote-desktop_current_amd64.deb \
    && gdebi /tmp/chrome-remote-desktop_current_amd64.deb -n \
    && rm /tmp/chrome-remote-desktop_current_amd64.deb

# Set up Chrome Remote Desktop
RUN echo "exec gnome-session" > /root/.chrome-remote-desktop-session

# Install GNOME Shell extensions and configure GNOME settings
RUN apt-get install -y gnome-shell-extension-manager gnome-shell-extension-prefs gnome-shell-extensions chrome-gnome-shell dconf-editor \
    && gnome-extensions enable ubuntu-dock@ubuntu.com \
    && gnome-extensions enable ding@rastersoft.com \
    && gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com \
    && gnome-extensions enable apps-menu@gnome-shell-extensions.gcampax.github.com \
    && gnome-extensions enable places-menu@gnome-shell-extensions.gcampax.github.com \
    && gnome-extensions enable screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com

# Set GNOME theme
RUN gsettings set org.gnome.desktop.interface gtk-theme "Yaru" \
    && gsettings set org.gnome.desktop.interface icon-theme "Yaru" \
    && gsettings set org.gnome.desktop.interface cursor-theme "Yaru"

# Set GNOME session to never sleep
RUN gsettings set org.gnome.desktop.session idle-delay 0

# Set background and favorites
RUN gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/warty-final-ubuntu.png" \
    && gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'firefox.desktop', 'vlc.desktop', 'org.kde.discover.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.gedit.desktop', 'org.gnome.Settings.desktop']"

# Clean up unnecessary files
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set environment for Chrome Remote Desktop to run
CMD ["/opt/google/chrome-remote-desktop/start-host", "--code", "4/0AanRRrt9T5uDMb8xL6PKMkPSyCD94L9EBAc5QhlUHhmzfMj8TOC0FOgPHViT_RhBoOrQfQ", "--redirect-url", "https://remotedesktop.google.com/_/oauthredirect", "--name", "$(hostname)", "--pin", "123456"]
