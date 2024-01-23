# syntax=docker/dockerfile:1
FROM ghcr.io/ublue-os/bluefin-cli:latest

# Install extra packages
COPY wsl-files/extra-packages /
RUN apk update && \
    apk upgrade && \
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
    mkdir -p /etc/sudoers.d && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Copy bashrc file to user
RUN cp /root/.bashrc /home/$USERNAME/.bashrc && \
    chown $USERNAME:$USERNAME /home/$USERNAME/.bashrc && \
    ln -s /home/$USERNAME/.bashrc /home/$USERNAME/.profile

# Update wsl.conf file
RUN sed -i "s/root/$USERNAME/g" /etc/wsl.conf

# Fix su-exec permissions
RUN chmod u+s /sbin/su-exec

# Change bash-completion mount
RUN sed -i "s/\/run\/host//g" /etc/profile.d/00-bluefin-cli-brew-firstrun.sh
