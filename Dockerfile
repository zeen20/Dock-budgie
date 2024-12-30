FROM ubuntu:latest

# Update and install desktop environment and XRDP
RUN apt-get update && apt-get install -y \
    software-properties-common \
    lubuntu-desktop \
    xrdp && \
    adduser xrdp ssl-cert && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a user and add to sudo group
RUN useradd -m -s /bin/bash baynar && \
    echo "baynar:123456" | chpasswd && \
    usermod -aG sudo baynar

# Fix XRDP environment issues
RUN echo "startlxqt" > /etc/skel/.xsession && \
    echo "startlxqt" > /home/baynar/.xsession && \
    chown baynar:baynar /home/baynar/.xsession

# Expose port 3389 for RDP
EXPOSE 3389

# Start XRDP service
CMD ["/usr/sbin/xrdp", "--nodaemon"]
