FROM archlinux/base:latest
ARG input
RUN pacman --noconfirm -Syu ca-certificates openssl wget unzip nodejs npm; yes | pacman -Scc

RUN mkdir /project
RUN mkdir /project/pulltop

COPY pulltop/package*.json /project/pulltop/

COPY container/exec.sh /project/exec.sh
RUN chmod +x /project/exec.sh

RUN cd project/pulltop/ && npm install
ADD pulltop/pulltop.js /project/pulltop/pulltop.js

RUN wget -q -O /tmp/websocketd.zip \
    https://github.com/joewalnes/websocketd/releases/download/v0.2.9/websocketd-0.2.9-linux_amd64.zip \
    && unzip /tmp/websocketd.zip -d /tmp/websocketd && mv /tmp/websocketd/websocketd /usr/bin \
    && chmod +x /usr/bin/websocketd

EXPOSE 8080

WORKDIR /project
RUN chmod -R 777 /project/exec.sh
CMD ["sh", "-c", "/project/exec.sh $SYMBOL"]

