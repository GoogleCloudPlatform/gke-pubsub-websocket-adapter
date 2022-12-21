FROM debian:bullseye as build
RUN apt-get -y update \
  && apt-get -y install git \
  && apt-get -y install build-essential \
  && apt-get -y install curl \
  && apt-get install -y dumb-init
WORKDIR /go/src/app
RUN git clone https://github.com/joewalnes/websocketd.git
WORKDIR /go/src/app/websocketd
RUN make

FROM debian:bullseye-slim
COPY --from=build /go/src/app/websocketd/websocketd /app/websocketd
COPY --from=build /usr/bin/dumb-init /app/dumb-init
USER 1000

CMD ["/bin/sh", "-c", "/app/dumb-init /app/websocketd --port=8080 --devconsole tail -F $STREAM -n 10"]
