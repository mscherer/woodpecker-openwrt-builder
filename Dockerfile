FROM quay.io/fedora/fedora-minimal:latest@sha256:5289d829bb23da6694f2402dc04a6c6824216486982f5eb48302b8083e79ce40
#
# empty space for easier rebasing
#
LABEL org.opencontainers.image.source="https://github.com/mscherer/woodpecker-openwrt-builder"

RUN dnf install --nodocs --setopt=install_weak_deps=False -y 'perl(JSON::PP)' util-linux unzip python3 which file gzip bzip2 patch diffutils 'perl(IPC::Cmd)' make wget perl-lib perl-FindBin perl-File-Compare perl-File-Copy "perl(Thread::Queue)" tar zstd perl-Time-Piece && dnf clean all && rm -Rf /var/log/dnf5.log /var/lib/dnf/ /var/cache/

COPY build.sh /usr/local/bin/build.sh

ENTRYPOINT ["/bin/bash", "/usr/local/bin/build.sh"]

