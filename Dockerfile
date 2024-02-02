# syntax=docker/dockerfile:1
FROM ghcr.io/ublue-os/bluefin-cli:latest

# Install extra packages
COPY wsl-files/extra-packages /
RUN apk update && \
    apk upgrade && \
    apk del brew && \
    grep -v '^#' /extra-packages | xargs apk add
RUN rm /extra-packages

# Add systemd symlink to init
RUN ln -s /usr/lib/systemd/systemd /sbin/init

# Add wsl.conf file
COPY wsl-files/wsl.conf /etc/wsl.conf

# Create user
ARG USERNAME=${username:-user}
ARG PASSWORD=${password:-user}
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN addgroup -g $GROUP_ID $USERNAME && \
    adduser -D -u $USER_ID -G $USERNAME $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy bashrc file to user
RUN cp /root/.bashrc /home/$USERNAME/.bashrc && \
    chown $USERNAME:$USERNAME /home/$USERNAME/.bashrc && \
    ln -s /home/$USERNAME/.bashrc /home/$USERNAME/.profile

# Run brew the first time
USER $USERNAME
RUN sudo chown -R $USERNAME /home/linuxbrew/.linuxbrew && \
    . /etc/profile.d/brew.sh

USER root

# Update wsl.conf file
RUN sed -i "s/root/$USERNAME/g" /etc/wsl.conf

# Fix su-exec permissions
RUN chmod u+s /sbin/su-exec

# Remove the brew firstrun script
RUN rm /etc/profile.d/00-bluefin-cli-brew-firstrun.sh
