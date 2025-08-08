Woodpecker plugin to build a Openwrt image from a git repo

# Testing the plugin

With `podman`, the code can be tested with:

```
podman build . -t openwrt
cd $REPO_FOR_OPENWRT_CONFIG
podman run -rm -w /woodpecker/ -v $PWD:/woodpecker/:Z -ti  localhost/openwrt
```
