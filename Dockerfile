FROM python:3.8

RUN apt-get update && apt-get -y dist-upgrade \
    && apt-get -y install libffi-dev libsasl2-dev \
        sudo libldap2-dev libssl-dev  \
        default-mysql-client nginx \
    && rm -rf /var/cache/apt/archives/*

RUN mkdir /home/oncall
COPY src /home/oncall/source/src
COPY setup.py /home/oncall/source/setup.py
COPY MANIFEST.in /home/oncall/source/MANIFEST.in

WORKDIR /home/oncall

RUN mkdir -p /home/oncall/var/log/uwsgi /home/oncall/var/log/nginx /home/oncall/var/run /home/oncall/var/relay \
    && cd /home/oncall/source && pip install . && pip install uwsgi

COPY . /home/oncall
COPY ops/config/systemd /etc/systemd/system
COPY ops/daemons /home/oncall/daemons
COPY ops/daemons/uwsgi-docker.yaml /home/oncall/daemons/uwsgi.yaml
COPY db /home/oncall/db
COPY configs /home/oncall/config

EXPOSE 8080

CMD ["python", "/home/oncall/ops/entrypoint.py"]
