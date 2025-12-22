FROM quay.io/fedora/fedora-minimal:44@sha256:3876f273e3e51b88d606427f323e109afa633670cd7a210d45135874a0f39b43
#
# empty space for easier rebasing
#
LABEL org.opencontainers.image.source="https://github.com/mscherer/woodpecker-openwrt-builder"

RUN dnf install --nodocs --setopt=install_weak_deps=False -y 'perl(JSON::PP)' util-linux unzip python3 which file gzip bzip2 patch diffutils 'perl(IPC::Cmd)' make wget perl-lib perl-FindBin perl-File-Compare perl-File-Copy "perl(Thread::Queue)" tar zstd perl-Time-Piece openssh-clients && dnf clean all && rm -Rf /var/log/dnf5.log /var/lib/dnf/ /var/cache/

COPY build.sh /usr/local/bin/build.sh

ENTRYPOINT ["/bin/bash", "/usr/local/bin/build.sh"]

