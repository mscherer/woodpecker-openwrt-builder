Woodpecker plugin to build a Openwrt image from a git repo and upload to a server

# Usage

This can be used with the following woodpecker config

```
---
when:
  branch: main
  event: push

steps:
  - name: build-openwrt-image
    image: ghcr.io/mscherer/woodpecker-openwrt-builder:latest
    pull: true
    settings:
      # server where the plugin will upload the file
      host: openwrt.example.org
      # username, default to woodpecker one if unset
      username: uploader
      # only ssh keys are supported
      ssh_key:
        from_secret: ssh_key
      # remote directory
      target: /var/www/openwrt/
```

# Testing the plugin

With `podman`, the code can be tested with:

```
# set TMPDIR if /var/tmp is full/readonly like on silverblue
podman build . -t openwrt
cd $REPO_FOR_OPENWRT_CONFIG
# use -e for the configuration
podman run --rm -w /woodpecker/ -v $PWD:/woodpecker/:Z -ti  localhost/openwrt
```

# Customise the build before make

If a file named `customise.sh` is present in the directory, it will be run before calling make.
This can be used to avoid hardcoding secrets in the config file, using `envsubst` to file the file
from environment variables (for example).
