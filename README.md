Satisfactory Dedicated Server
=============================

Run your favorite factory automator in a docker container!

# Preface
Satisfactory released dedicated servers in the experimental build `v0.7.0.8`.
This release allows for running dedicated Linux servers. The purpose of this
repository is to build and run a container for a Satisfactory dedicated server.

# Building the container
In order to build the container, the easiest way to get started is to use the
docker compose tool. Leverage the docker compose command to build the dedicated
server container so it is ready to be used. Sometimes you may have to bust the
cache if a new version of the server is released but the Dockerfile is not
changed. This can be accomplished by adding the `--no-cache` flag.

```bash
# Use docker compose and build the container.
> docker compose build

# Check that the image exists.
> docker compose images

Container                              Repository            Tag                 Image Id            Size
satisfactory_server_run_3dbda5535725   satisfactory_server   latest              a14a129080e0        7.68GB
```

# Creating and configuring the data volume(s)
In order for any worlds or save game data to persist, we need a volume. There
are many ways to go about adding a persistent volume to your server but this
document will only go over the docker volume method.

The the built-in [entrypoint.sh](./scripts/entrypoint.sh) takes care of setting
the correct owner and permission of the data files on startup.

If you are using the [docker-compose.yml](./docker-compose.yml) file included
with this repository and not using the built-in data volume or using a
bind-mount, you may need to fix the permissions yourself to ensure the
unprivleged user in the container owns the volume's data files. Otherwise
the server can't write to it.

It is generally sufficient to simply change ownership to the unprivileged
user (UID/GID is in the [Dockerfile](./Dockerfile)) on the mount targets inside
the container.

# Running the dedicated server
Once you've ensured proper ownership of the data volume files, you can then
bring the dedicated server container up. Simply use the docker compose up
command and it will bootstrap.

```bash
# Attached console mode.
docker compose up server

# Detatched console mode.
docker compose up -d server
```

## New data volume: important note
If your data volume contains no data then the server will initialize in a
naked "unclaimed" mode. When you connect to it for the first time it will prompt
you to set some information such as the password, as well as the option to
create a first initial world. Therefore, it may be wise to keep the server
behind a protected firewall before exposing it to the Internet or others. Then,
after it is initialized, it should be safe to expose it.
