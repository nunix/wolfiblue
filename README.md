# wolfiblue

[Bluefin-cli](https://github.com/castrojo/bluefin-cli) for WSL

## Build

The `Dockerfile` contains the following options:

1. Variable `USERNAME` is the username to use for the image. Default is `user`.
1. Variable `PASSWORD` is the password to use for the image. Default is `user`.
1. Variable `USER_UID` is the user id to use for the image. Default is `1000`.
1. Variable `USER_GID` is the group id to use for the image. Default is `1000`.
1. Copy the `wsl.conf` file to `/etc/wsl.conf` to set the default user and enables `systemd`.
1. Copy the `extra-packages` file to `/extra-packages` to install extra packages.

To build the image with all defaults, run the following command:

```shell
docker build --output type=tar,dest=wolfiblue.tar .
```

## Import

The file generated from the `docker build` command can be imported into WSL using the following command:

```shell
wsl --import wolfiblue $env:USERPROFILE/wolfiblue wolfiblue.tar --version 2
```

> Note: The path used in the `--import` command must be a Windows path.
> Note: The `--version 2` is required to enable `systemd`.
