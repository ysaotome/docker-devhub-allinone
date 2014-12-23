
FROM ysaotome/ubuntu

MAINTAINER Yuichi Saotome <y@sotm.jp>

# Install Middleware
ENV DEBIAN_FRONTEND noninteractive
## Add MongoDB Repo
RUN echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" > /etc/apt/sources.list.d/mongodb.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
## Add node Repo
RUN wget -qO- https://deb.nodesource.com/setup | bash -

RUN apt-get update
RUN apt-get install -y supervisor mongodb-org nodejs
RUN apt-get clean

# Install DevHub
RUN git clone https://github.com/volpe28v/DevHub.git /DevHub
WORKDIR /DevHub
RUN npm install

## Add devhub user
RUN useradd -m -d /DevHub -s /bin/bash devhub
RUN echo 'devhub:devhub' | chpasswd
RUN echo 'devhub ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/devhub
RUN chown devhub:devhub static/uploads
RUN chmod 775 static/uploads

ADD supervisord.conf /etc/supervisor/conf.d/devhub.conf

EXPOSE 3000
VOLUME ["/DevHub", "/var/lib/mongodb"]

ENTRYPOINT ["/usr/bin/supervisord", "-n"]

