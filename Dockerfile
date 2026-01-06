FROM quay.io/fedora/fedora-minimal:44@sha256:f14605ff8e5d0f28b10d9315da96607463f26153d32f68800d3678d0a31e7330
#
# empty space for easier rebasing
#
LABEL org.opencontainers.image.source="https://github.com/mscherer/woodpecker-openwrt-builder"

RUN dnf install --nodocs --setopt=install_weak_deps=False -y 'perl(JSON::PP)' util-linux unzip python3 which file gzip bzip2 patch diffutils 'perl(IPC::Cmd)' make wget perl-lib perl-FindBin perl-File-Compare perl-File-Copy "perl(Thread::Queue)" tar zstd perl-Time-Piece openssh-clients gettext-envsubst cowsay banner figlet && dnf clean all && rm -Rf /var/log/dnf5.log /var/lib/dnf/ /var/cache/

COPY build.sh /usr/local/bin/build.sh

ENTRYPOINT ["/bin/bash", "/usr/local/bin/build.sh"]

