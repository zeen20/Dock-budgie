FROM ubuntu:rolling

ENV DEBIAN_FRONTEND=noninteractive

# Install essential packages and add Chrome/VSCode repositories
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        curl \
        gpg \
        wget \
        unzip \
        sudo \
        vlc \
        hardinfo \
        gedit \
        git \
        gdebi-core \
        ufw \
        apt-utils \
        vim \
        psmisc \
        python3-psutil \
        ffmpeg \
        xfce4-session \
        xfce4-goodies \
        xserver-xorg-video-dummy && \
    rm -rf /var/lib/apt/lists/*


# Install Chrome Remote Desktop using wget with --no-check-certificate
RUN wget --no-check-certificate https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb && \
    sudo gdebi --non-interactive chrome-remote-desktop_current_amd64.deb && \
    rm chrome-remote-desktop_current_amd64.deb

# Configure Chrome Remote Desktop session to use XFCE
RUN bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'

# Add user and set up Chrome Remote Desktop
ARG USER=baynar
ARG PIN=123456
ARG CODE=4/xxx
ARG HOSTNAME=myvirtualdesktop

RUN adduser --disabled-password --gecos "" $USER && \
    adduser $USER sudo && \
    groupadd chrome-remote-desktop || true && \
    usermod -aG chrome-remote-desktop $USER && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER $USER
WORKDIR /home/$USER

RUN mkdir -p .config/chrome-remote-desktop && \
    chown "$USER:$USER" .config/chrome-remote-desktop && \
    chmod a+rx .config/chrome-remote-desktop && \
    echo "/usr/bin/pulseaudio --start" > ~/.chrome-remote-desktop-session && \
    echo "startxfce4" >> ~/.chrome-remote-desktop-session

# Start Chrome Remote Desktop
CMD DISPLAY= /opt/google/chrome-remote-desktop/start-host \
    --code="$CODE" \
    --redirect-url="https://remotedesktop.google.com/_/oauthredirect" \
    --name="$HOSTNAME" \
    --pin="$PIN" && \
    sleep infinity
