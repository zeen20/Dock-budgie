FROM ubuntu:latest

# Update and install desktop environment and XRDP
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y lubuntu-desktop && \
    apt install -y xrdp && \
    adduser xrdp ssl-cert

# Create a user and add to sudo group
RUN useradd -m baynar && \
    echo "baynar:123456" | chpasswd && \
    usermod -aG sudo testuser

# Expose port 3389
EXPOSE 3389

# Start services

CMD service xrdp start && \
    /bin/bash
