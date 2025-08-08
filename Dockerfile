FROM quay.io/fedora/fedora-minimal:latest@sha256:a77e84a742dd6aabfaf0f14a5de300acceda638c66eea777b1f2c6c705f33151
#
# empty space for easier rebasing
#
LABEL org.opencontainers.image.source="https://github.com/mscherer/woodpecker-openwrt-builder"

RUN dnf install --nodocs --setopt=install_weak_deps=False -y make wget perl-FindBin perl-File-Compare perl-File-Copy "perl(Thread::Queue)" tar zstd && dnf clean all && rm -Rf /var/log/dnf5.log /var/lib/dnf/ /var/cache/

COPY build.sh /usr/local/bin/build.sh

ENTRYPOINT ["/bin/bash", "/usr/local/bin/build.sh"]

