# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#Builder Image to download Websocketd
FROM debian:stable as builder

RUN apt-get update && apt-get install -y \
    unzip \
    wget

RUN wget -q -O /tmp/websocketd.zip https://github.com/joewalnes/websocketd/releases/download/v0.4.1/websocketd-0.4.1-linux_amd64.zip
RUN unzip /tmp/websocketd.zip -d /tmp/websocketd

#Node Image to execute pulltop & Websocketd
FROM node:14-slim

WORKDIR /project

COPY --from=builder /tmp/websocketd/websocketd /usr/bin

COPY container/exec.sh /project/exec.sh
RUN chmod +x /project/exec.sh
RUN chmod +x /usr/bin/websocketd
RUN npm install -g pulltop

EXPOSE 8080

RUN chmod -R 777 /project/exec.sh
CMD ["sh", "-c", "/project/exec.sh $SYMBOL"]