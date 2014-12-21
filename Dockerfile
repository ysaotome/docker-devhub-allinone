FROM ubuntu:14.04

MAINTAINER Yuichi Saotome <y@sotm.jp>


## Install Middleware
ENV DEBIAN_FRONTEND noninteractive
RUN sudo sed -i.bak -e "s%http://us.archive.ubuntu.com/ubuntu/%http://ftp.iij.ad.jp/pub/linux/ubuntu/archive/%g" /etc/apt/sources.list
RUN echo "deb-src http://jp.archive.ubuntu.com/ubuntu trusty main" >> /etc/apt/sources.list
RUN sed "s/main$/main universe/" -i /etc/apt/sources.list
RUN echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" > /etc/apt/sources.list.d/mongodb.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y wget git supervisor mongodb-org
RUN wget -qO- https://deb.nodesource.com/setup | bash -
RUN apt-get update
RUN apt-get install -y nodejs
RUN apt-get clean

RUN echo 'Asia/Tokyo' > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

## Install DevHub
RUN git clone https://github.com/volpe28v/DevHub.git /DevHub
WORKDIR /DevHub
RUN npm install

RUN ( \
  echo "[program:devhub]" && \
  echo "command=/usr/bin/node /DevHub/app.js" && \
  echo "directory=/DevHub" && \
  echo "user=nobody" && \
  echo "autostart=true" && \
  echo "redirect_stderr=true" && \
  echo "stderr_logfile = /DevHub/err.log" && \
  echo "stdout_logfile = /DevHub/out.log" && \
  echo "[program:mongodb]" && \
  echo "command=/usr/bin/mongod --config /etc/mongod.conf" && \
  echo "user=mongodb" && \
  echo "autostart=true" && \
  echo "redirect_stderr=true" \
) > /etc/supervisor/conf.d/devhub.conf

EXPOSE 3000
VOLUME ["/DevHub", "/var/lib/mongodb"]

ENTRYPOINT ["/usr/bin/supervisord", "-n"]

