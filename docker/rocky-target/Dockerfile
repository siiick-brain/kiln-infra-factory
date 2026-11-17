FROM quay.io/rockylinux/rockylinux:10.2@sha256:827d37bc128288ccf160ee318bb3cb92d591164cb217e92f8bc61e3982ae1834

RUN dnf -y install dnf-automatic nginx openssh-server procps-ng python3 rsyslog sudo \
    && dnf clean all \
    && rm -rf /var/cache/dnf

RUN useradd --create-home --shell /bin/bash ansible \
    && install -d -o ansible -g ansible -m 0700 /home/ansible/.ssh \
    && printf '%s\n' 'ansible ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/ansible \
    && chmod 0440 /etc/sudoers.d/ansible \
    && visudo -cf /etc/sudoers.d/ansible \
    && install -d -o root -g root -m 0700 /root/.ansible/tmp

COPY entrypoint.sh /usr/local/sbin/rocky-target-entrypoint
RUN chmod 0755 /usr/local/sbin/rocky-target-entrypoint

EXPOSE 22
ENTRYPOINT ["/usr/local/sbin/rocky-target-entrypoint"]
