FROM quay.io/fedora/fedora-minimal:46@sha256:4bfde17d266b5d013a3d267e481dbaa6ddd611efe9b1235616f2d5017fdca648
#
# empty space for easier rebasing
#
LABEL org.opencontainers.image.source="https://github.com/mscherer/woodpecker-openwrt-builder"

RUN dnf install --nodocs --setopt=install_weak_deps=False -y 'perl(JSON::PP)' util-linux unzip python3 which file gzip bzip2 patch diffutils 'perl(IPC::Cmd)' make wget perl-lib perl-FindBin perl-File-Compare perl-File-Copy "perl(Thread::Queue)" tar zstd perl-Time-Piece openssh-clients lftp gettext-envsubst cowsay banner figlet jq && dnf clean all && rm -Rf /var/log/dnf5.log /var/lib/dnf/ /var/cache/

COPY build.sh /usr/local/bin/build.sh

ENTRYPOINT ["/bin/bash", "/usr/local/bin/build.sh"]

