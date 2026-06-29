FROM quay.io/fedora/fedora-minimal:45@sha256:d56bfd498649e1b582534c5a4d4cb034a82de8b6e2d21a100a7f9ea043f8dc2e
#
# empty space for easier rebasing
#
LABEL org.opencontainers.image.source="https://github.com/mscherer/woodpecker-openwrt-builder"

RUN dnf install --nodocs --setopt=install_weak_deps=False -y 'perl(JSON::PP)' util-linux unzip python3 which file gzip bzip2 patch diffutils 'perl(IPC::Cmd)' make wget perl-lib perl-FindBin perl-File-Compare perl-File-Copy "perl(Thread::Queue)" tar zstd perl-Time-Piece openssh-clients lftp gettext-envsubst cowsay banner figlet jq && dnf clean all && rm -Rf /var/log/dnf5.log /var/lib/dnf/ /var/cache/

COPY build.sh /usr/local/bin/build.sh

ENTRYPOINT ["/bin/bash", "/usr/local/bin/build.sh"]

