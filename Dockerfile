FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

#timezone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#install commons
RUN apt-get update && apt-get upgrade -y && apt-get install -y wget nano sudo net-tools apt-utils

#locales
ENV LANGUAGE=de_DE.UTF-8

RUN apt-get install -y locales
RUN echo '${LANGUAGE} UTF-8' >> /etc/locale.gen
RUN locale-gen ${LANGUAGE}
ENV LANG=${LANGUAGE}
ENV LC_ALL=${LANGUAGE}

#install desktop
RUN apt-get install -y ubuntu-desktop xfce4 dbus-x11 xrdp
RUN echo 'xfce4-session' > /etc/skel/.xsession

EXPOSE 3389

ENTRYPOINT service xrdp start && /bin/bash
