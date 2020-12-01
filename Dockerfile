FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

#timezone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#install commons
RUN apt-get upate && apt-get upgrade -y && apt-get install -y wget nano sudo net-tools

#install desktop
RUN apt-get install ubuntu-desktop xfce4 dbus-x11 xrdp
RUN echo 'xfce4-session' > /etc/skel/.xsession

EXPOSE 3389

ENTRYPOINT service xrdp start && /bin/bash
