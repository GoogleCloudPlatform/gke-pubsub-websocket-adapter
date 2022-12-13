FROM debian:bullseye

ARG USERNAME=cron-user
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

RUN apt-get update && apt-get -y install cron \
    && apt-get install -y logrotate \
    && echo "*/5 * * * * cron-user > /data/output.json" >> /etc/cron.d/rotate-output \
    && crontab -u cron-user /etc/cron.d/rotate-output \
    && chmod u+s /usr/sbin/cron

COPY --chown=cron-user:cron-user cron-scripts cron-scripts

RUN chmod +x cron-scripts/script.sh

USER cron-user

CMD ["cron", "-f"]
