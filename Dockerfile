FROM ubuntu:focal

# Set non-interactive environment to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update system and install prerequisites
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
    sudo wget gdebi-core curl gnupg2 \
    xorg openbox \
    pulseaudio \
    libnss3 libxss1 libgconf-2-4 \
    dbus-x11 \
    gnome-session gnome-shell \
    gnome-terminal \
    gnome-control-center \
    gnome-icon-theme \
    gnome-backgrounds \
    gvfs-backends \
    gvfs-fuse \
    nautilus \
    x11-xserver-utils

# Download Chrome Remote Desktop package
RUN wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb -O /tmp/chrome-remote-desktop_current_amd64.deb

# Install the Chrome Remote Desktop package
RUN sudo gdebi /tmp/chrome-remote-desktop_current_amd64.deb -n

# Clean up the downloaded package
RUN rm /tmp/chrome-remote-desktop_current_amd64.deb

# Set up Chrome Remote Desktop session to use GNOME
RUN echo "exec /usr/bin/gnome-session" > /etc/chrome-remote-desktop-session

# Add user and configure Chrome Remote Desktop
ARG USER=youruser
ENV PIN=123456
ENV CODE=your-code
ENV HOSTNAME=myvirtualdesktop

RUN adduser --disabled-password --gecos '' $USER
RUN mkdir -p /home/$USER/.config/chrome-remote-desktop
RUN chown $USER:$USER /home/$USER/.config/chrome-remote-desktop
RUN touch /home/$USER/.config/chrome-remote-desktop/host.json

# Expose ports for Chrome Remote Desktop
EXPOSE 3389

# Start the virtual display, Chrome Remote Desktop, and set up the session
CMD \
   Xvfb :0 -screen 0 1024x768x24 & \
   /usr/bin/pulseaudio --start & \
   /opt/google/chrome-remote-desktop/start-host --code=$CODE --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$HOSTNAME --pin=$PIN
