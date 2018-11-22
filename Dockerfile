FROM fedora:29

ENV HOME /opt/s2i2reg

RUN mkdir -p /opt/s2i2reg/.docker

RUN dnf -y install skopeo origin-clients

WORKDIR $HOME
COPY move.sh config.json.template $HOME/
RUN chgrp -R 0 /opt/s2i2reg/ &&\
    chmod -R g+rwx /opt/s2i2reg/

USER 1001

CMD ["bash", "./move.sh"]