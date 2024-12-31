FROM ubuntu:24.04

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

# Add VSCode repository and key
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/microsoft.gpg && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list

# Add Google Chrome repository
RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# Install Google Chrome
RUN apt-get update && apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Configure Chrome Remote Desktop
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
