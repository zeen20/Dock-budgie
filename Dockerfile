FROM ubuntu:latest

# Set the DEBIAN_FRONTEND to noninteractive to suppress prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required packages
RUN apt update && \
    apt install -y ubuntu-desktop lightdm xrdp sudo openssl && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Configure LightDM for autologin
RUN echo "\
[Seat:*]\n\
autologin-user=root\n\
autologin-user-timeout=0\n\
" > /etc/lightdm/lightdm.conf.d/50-autologin.conf

# Create a new user and set a password
RUN useradd -m baynar && \
    echo "baynar:123456" | chpasswd && \
    usermod -aG sudo baynar

# Configure XRDP session
RUN echo "\
export XDG_SESSION_DESKTOP=ubuntu\n\
export XDG_SESSION_TYPE=x11\n\
export XDG_CURRENT_DESKTOP=ubuntu:GNOME\n\
export XDG_CONFIG_DIRS=/etc/xdg/xdg-ubuntu:/etc/xdg\n\
" > /root/.xsessionrc

# Expose XRDP port
EXPOSE 3389

# Set the default command to start services
CMD service dbus start && \
    service xrdp start && \
    service lightdm start && \
    tail -f /dev/null
