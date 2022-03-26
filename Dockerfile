FROM debian:bullseye-slim

VOLUME /root/app
VOLUME /root/data
VOLUME /root/files

## Install pre-req software
RUN apt-get update && apt-get install -y \
  curl procps tor

## Download and install nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_17.x | bash - \
  && apt-get install -y nodejs

## Install node packages
RUN npm install -g npm yarn

## Configure hidden service in torrc file
RUN printf "\n\nHiddenServiceDir /root/data/tor/\nHiddenServicePort 80 127.0.0.1:3000" \
  >> /etc/tor/torrc

WORKDIR /root/app
ENTRYPOINT [ "yarn" ]
CMD [ "start" ]