FROM debian:bullseye

ARG USERNAME=cron-user
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

RUN apt-get update && apt-get -y install cron \
    && echo "*/5 * * * * cron-user > /data/output.json" >> /etc/cron.d/rotate-output \
    && crontab -u cron-user /etc/cron.d/rotate-output \
    && chmod u+s /usr/sbin/cron

USER cron-user

CMD ["cron", "-f"]
