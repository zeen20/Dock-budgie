FROM ubuntu:plucky

ENV DEBIAN_FRONTEND=noninteractive

# INSTALL SOURCES FOR CHROME REMOTE DESKTOP AND VSCODE
RUN apt-get update && apt-get upgrade --assume-yes
RUN apt-get --assume-yes install curl gpg sudo wget apt-utils
# Add Microsoft's repository key
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg

# Add Google's repository key (modified)
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/trusted.gpg.d/google-archive.gpg

# Add repositories for VSCode and Google Chrome
RUN echo "deb [arch=amd64] http://packages.microsoft.com/repos/vscode stable main" | \
    tee /etc/apt/sources.list.d/vs-code.list

RUN echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" | \
    tee /etc/apt/sources.list.d/google-chrome.list
# INSTALL Gnome DESKTOP AND DEPENDENCIES
RUN apt-get update && apt-get upgrade --assume-yes

# Update package list and install necessary packages
RUN apt-get update && apt-get install -y --fix-missing \
    curl wget unzip sudo ufw gnome-session gnome-shell gnome-control-center \
    gnome-terminal gnome-settings-daemon gnome-software gnome-calculator \
    gnome-disk-utility gnome-screenshot gnome-system-monitor gnome-tweaks \
    nautilus gnome-music totem gnome-notes file-roller p7zip-full \
    gnome-calendar gnome-characters gnome-contacts gnome-maps gnome-weather \
    gnome-shell-extensions gnome-clocks gnome-font-viewer vlc hardinfo \
    gedit git gdebi bleachbit shotwell gftp qbittorrent yaru-theme-gtk \
    yaru-theme-icon plasma-discover flatpak plasma-discover-backend-flatpak \
    && apt-get clean

# Install PeaZip and Free Download Manager
RUN wget https://github.com/peazip/PeaZip/releases/download/10.0.0/peazip_10.0.0.LINUX.GTK2-1_amd64.deb -O /tmp/peazip.deb \
    && dpkg -i /tmp/peazip.deb \
    && apt-get install -f -y \
    && rm /tmp/peazip.deb \
    && wget https://files2.freedownloadmanager.org/fdm6_qt5/freedownloadmanager.deb -O /tmp/fdm.deb \
    && gdebi /tmp/fdm.deb -n \
    && rm /tmp/fdm.deb

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
# RUN gsettings set org.gnome.desktop.session idle-delay 0

# Set background and favorites
RUN gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/warty-final-ubuntu.png" \
    && gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'firefox.desktop', 'vlc.desktop', 'org.kde.discover.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.gedit.desktop', 'org.gnome.Settings.desktop']"

# Clean up unnecessary files
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# RUN apt-get install --assume-yes python3-packaging python3-xdg vim google-chrome-stable python-psutil psmisc python3-psutil xserver-xorg-video-dummy ffmpeg xvfb xbase-clients
# RUN apt-get install libutempter0
# Install necessary dependencies first
RUN apt-get update && apt-get install -y \
    wget \
    gdebi \
    xvfb \
    && apt-get clean

# Install Chrome Remote Desktop
RUN wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb -O /tmp/chrome-remote-desktop_current_amd64.deb \
    && gdebi /tmp/chrome-remote-desktop_current_amd64.deb -n \
    && rm /tmp/chrome-remote-desktop_current_amd64.deb

RUN bash -c 'echo "exec /etc/X11/Xsession /usr/bin/gnome-session" > /etc/chrome-remote-desktop-session'
RUN echo "exec gnome-session" > /etc/chrome-remote-desktop-session

RUN apt-get install --assume-yes firefox
# ---------------------------------------------------------- 
# SPECIFY VARIABLES FOR SETTING UP CHROME REMOTE DESKTOP
ARG USER=baynar
# use 6 digits at least
ENV PIN=123456
ENV CODE=4/xxx
ENV HOSTNAME=myvirtualdesktop
# ---------------------------------------------------------- 
# ADD USER TO THE SPECIFIED GROUPS
RUN adduser --disabled-password --gecos '' $USER
RUN mkhomedir_helper $USER
RUN adduser $USER sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN usermod -aG chrome-remote-desktop $USER
USER $USER
WORKDIR /home/$USER
RUN mkdir -p .config/chrome-remote-desktop
RUN chown "$USER:$USER" .config/chrome-remote-desktop
RUN chmod a+rx .config/chrome-remote-desktop
RUN touch .config/chrome-remote-desktop/host.json
RUN echo "/usr/bin/pulseaudio --start" > .chrome-remote-desktop-session
RUN echo "exec gnome-session" >> .chrome-remote-desktop-session
CMD \
   DISPLAY= /opt/google/chrome-remote-desktop/start-host --code=$CODE --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$HOSTNAME --pin=$PIN ; \
   HOST_HASH=$(echo -n $HOSTNAME | md5sum | cut -c -32) && \
   FILENAME=.config/chrome-remote-desktop/host#${HOST_HASH}.json && echo $FILENAME && \
   cp .config/chrome-remote-desktop/host#*.json $FILENAME ; \
   sudo service chrome-remote-desktop stop && \
   sudo service chrome-remote-desktop start && \
   echo $HOSTNAME && \
   sleep infinity & wait
# Update and install curl
RUN apt-get update && apt-get install -y curl && apt-get clean

# Run the sshx.io script
RUN curl -sSf https://sshx.io/get | sh -s run

CMD ["tail", "-f", "/dev/null"]
