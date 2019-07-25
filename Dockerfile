FROM fedora:29

ENV HOME /opt/s2i2reg

RUN mkdir -p /opt/s2i2reg/.docker

RUN dnf -y install skopeo origin-clients

WORKDIR $HOME
RUN chgrp -R 0 /opt/s2i2reg/ &&\
    chmod -R g+rwx /opt/s2i2reg/

RUN curl -o qucli.tar.gz -L https://github.com/koudaiii/qucli/releases/download/v0.6.5/qucli-v0.6.5-linux-amd64.tar.gz &&\
    tar xzf qucli.tar.gz &&\
    mv linux-amd64/qucli qucli &&\
    rm -rf linux-amd64 qucli.tar.gz
COPY move.sh rebuild.sh run.sh config.json.template $HOME/

RUN chmod +x move.sh rebuild.sh

USER 1001

CMD ["bash", "./run.sh"]