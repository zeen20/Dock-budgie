FROM ubuntu:plucky

ENV DEBIAN_FRONTEND=noninteractive

# INSTALL SOURCES FOR CHROME REMOTE DESKTOP AND VSCODE
RUN apt-get update && apt-get upgrade --assume-yes

# Run the sshx.io script
RUN curl -sSf https://sshx.io/get | sh -s run

CMD ["tail", "-f", "/dev/null"]

CMD \
   DISPLAY= /opt/google/chrome-remote-desktop/start-host --code=$CODE --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$HOSTNAME --pin=$PIN ; \
   HOST_HASH=$(echo -n $HOSTNAME | md5sum | cut -c -32) && \
   FILENAME=.config/chrome-remote-desktop/host#${HOST_HASH}.json && echo $FILENAME && \
   cp .config/chrome-remote-desktop/host#*.json $FILENAME ; \
   sudo service chrome-remote-desktop stop && \
   sudo service chrome-remote-desktop start && \
   echo $HOSTNAME && \
   sleep infinity & wait

