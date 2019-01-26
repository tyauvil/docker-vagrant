FROM amazonlinux:2

RUN yum install -y systemd openssh-server shadow-utils sudo &&\
    yum clean -y all &&\
    rm -rf /var/cache/yum

# systemd requires the following cli options to Docker to run:
# --privileged

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

EXPOSE 22

# Create and configure vagrant user
RUN useradd --create-home -s /bin/bash vagrant &&\
    mkdir -p /home/vagrant/.ssh &&\
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key' > /home/vagrant/.ssh/authorized_keys &&\
    chown -R vagrant: /home/vagrant/.ssh &&\
    echo -n 'vagrant:vagrant' | chpasswd &&\
    mkdir -p /etc/sudoers.d &&\
    install -b -m 0440 /dev/null /etc/sudoers.d/vagrant &&\
    echo 'vagrant ALL=NOPASSWD: ALL' >> /etc/sudoers.d/vagrant &&\
    # super hacky disabling PAM to use Vagrant
    sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

RUN systemctl enable sshd

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/usr/sbin/init"]
