# Minecraft Server via Docker

This README is meant to give you a quick introduction into important docker commands to create and maintain a docker
image for a Minecraft Java server.

## Setup

Install Docker or another tool like podman on the system which is intended be running the server.

Clone this repository via git or download the packaged zip from the GitHub page top right. Then open a shell or cmd in
this directory and issue the needed commands described below.

## Downloading the server.jar

Start your Minecraft Java launcher and select the installation tab. Click on, or create a new, installation for which you
want to create the Minecraft server. In the new screen click on the "Server Download" button, right above the dropdown
for the version.

Place the downloaded server.jar file into the container-content directory and proceed with the 'Building the server' step. 

## Building the server:

```shell
# You can use any tag but it should correspond to the version you are using 
# `build`
#   Build a new image from a Dockerfile. In this case it builds an image, which can be consumed by an virtualization host
#   like docker
docker build -t minecraft-server-1.17.1 .
```

## Starting the server:

```shell
# `run`
#   Creates a container from the image and pushes it to the docker daemon.
# `-d`
#   Flag starts the container in detached mode, so your stdin and stdout is not attached. 
# `-i` 
#   Starts the container in interactive mode, so the stdin and stdout is internally catched and hold so you can
#   reattach in the future.
# `-t`
#   Using a tty which allows a more interactive way.
# `-p 25565:25565` 
#   Forwards internal host port 25565 (the default minecraft server port) to the internal port 25565.
# `-v mc-world-volume:/server/data`
#   Similar to the port you are creating a docker volume, or using one with this name, which provides container decoupled
#   storage to the internal 'mounting' position /server/data which is the working directory of the host.
#   This results into a config, in which the world and its config will be written and synchronized with this volume,
#   which can be reused by another container. This allows you to restart the container and keep the current world.
#   Drop this option to have a temporary server world.
# `minecraft-server-1.17.1`
#   The image you would like to use for this container. The name is the one you have given by the build command.
docker run -dit -p 25565:25565 -v mc-world-volume:/server/data minecraft-server-1.17.1
```

## Stopping the server

If the server stops by itself, eg. crashed or was stopped by the minecraft `/stop` then the container is stopped as well
since the only thing that holds it running, is the never finishing `java` command. You should always do it in this way
otherwise you might lose world progress!

The following way is only meant to be used if you can not access the server anymore. Event though it will send a SIGTERM
to the minecraft server, which result in a similar behavior as issuing the stop command but might timeout in the meantime
which results in the immediate killing of the server process.

```shell
# `stop`
#   Stops the container, which issues the SIGTERM signal to the java process. This will result in the server starting
#   the stopping procedure.
# `-t [time]`
#   The time you want to give your server to be finished with the graceful stopping procedure. Once this time has run
#   out the docker daemon will forcfully kill the container task.
# `[id]`
#   The id of the container you want to stop see docker logs command below. 
docker stop -t [time] [id]
```

## To check the status of the server

```shell
# `ps`
#   To see currently running container
# `-a`
#   To include all stopped container as well.
docker ps -a
```

## See what logs resulted from the server

```shell
# `logs`
#   To get all text which was written to the stdout.
# `[id]`
#   The id which you can get by using `docker ps -a`, it is enough to just write the first several letters (3 to 4).
#   It just needs to be unique in respect to the other container ids.  
docker logs [id]
```

## Access a running minecraft server

```shell
# `attach`
#   Reattaches to an container which is running and was started with `-i` and `-t`.
#   The reattaching pipes the container stdout and stdin to your terminals stdout and stdin which allows you to issues
#   commands and see the realtime output of your server.
# `[id]`
#   The same id as was used by the `docker logs`.
docker attach [id]
```

## Access the persisted data / world

The persisted data is stored in docker volume, which you should not access directly. There are multiple ways to extract
or inspect the data.

On more straight forward way to do so is to hook the volume in a barebone linux container and then using the internal 
tools to inspect the data.

One way is like this:

```shell
# `run`
#   Run a new container from an image.
# `-it`
#   The same result as used in the 'starting the server' commands. Dropping the `-d` option to attach directly.
# `-v mc-world-volume:/data`
#   Binding the volume to /data to be able to access it.
# `alpine:3.14`
#   The image you want to start, specify another instance you would like to use like a ubuntu image `ubuntu:20.04` which
#   has more utilitys already installed. Use the ubuntu instance if you feel more comfortable with the default tools.
# `/bin/sh`
#   The application to launch on startup, which is the shell in this instance, so you can other commands, to inspect the
#   data.
docker run -it -v mc-world-volume:/data alpine:3.14 /bin/sh
```

## Backuping or pushing a world / data to the server / volume

To copy the saved data or to put data into the server / volume you can do so via a similar approach like it was done for
accessing.

Refer to https://stackoverflow.com/a/37469637 and
https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes to learn more about how to backup a
volume and extract the data.
