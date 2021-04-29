FROM ubuntu:20.04

#set TRUE or FALSE
ENV ENABLE_SOUND=TRUE

ENV DEBIAN_FRONTEND=noninteractive

#timezone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#install commons
RUN apt-get update && apt-get upgrade -y && apt-get install -y wget nano sudo net-tools apt-utils software-properties-common zip

#locales
ENV LANGUAGE=en_US.UTF-8

RUN apt-get install -y locales
RUN echo '${LANGUAGE} UTF-8' >> /etc/locale.gen
RUN locale-gen ${LANGUAGE}
ENV LANG=${LANGUAGE}
ENV LC_ALL=${LANGUAGE}

#install desktop
RUN apt-get install -y xfce4 dbus-x11 xrdp
RUN echo 'xfce4-session' > /etc/skel/.xsession

#setting terminal
RUN apt-get purge -y gnome-terminal xterm && apt-get install -y tilix
#remove unnecessary software
RUN apt-get purge -y xscreensaver
#install necessary software
RUN apt-get install -y gedit firefox gnome-calculator

#disable suspend/hibernate-Buttons
RUN echo "xfconf-query -c xfce4-session -np '/shutdown/ShowSuspend' -t 'bool' -s 'false'" >> /etc/skel/.bashrc
RUN echo "xfconf-query -c xfce4-session -np '/shutdown/ShowHibernate' -t 'bool' -s 'false'" >> /etc/skel/.bashrc

#disable action menu and add preconfigured desktop
WORKDIR /etc/skel
RUN mkdir .config
WORKDIR /etc/skel/.config
COPY xfce4.zip .
RUN unzip xfce4.zip
RUN rm xfce4.zip

#make thinclient-folder unvisible for user
RUN sed -i 's#FuseMountName=thinclient_drives#FuseMountName=Public/thinclient_drives#g' /etc/xrdp/sesman.ini

#change first IDs
RUN sed -i 's/FIRST_UID=1000/FIRST_UID=2000/g' /etc/adduser.conf
RUN sed -i 's/FIRST_GID=1000/FIRST_GID=2000/g' /etc/adduser.conf

#enable xrdp sound redirection
WORKDIR /root
RUN if [ "$ENABLE_SOUND" = "TRUE" ]; then \
        apt-get install -y build-essential dpkg-dev libpulse-dev git && \
        apt-get install -y pulseaudio && \
        sed -i '/deb-src/s/^# //' /etc/apt/sources.list && apt-get update && \
        apt-get -y build-dep pulseaudio && \
        apt-get -y source pulseaudio && \
        export PULSE_VER=$(pulseaudio --version | grep -Eo '[0-9,.]{1,10}') && \
        cd pulseaudio-$PULSE_VER && ./configure && \
        cd ../ && git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git && \
        cd pulseaudio-module-xrdp && ./bootstrap && ./configure PULSE_DIR=/root/pulseaudio-$PULSE_VER && make && \
        sudo make install && \
        echo "" && \
        echo "" && \
        echo "you should see some xrdp modules now:" && \
        echo "" && \
        ls $(pkg-config --variable=modlibexecdir libpulse) | grep -Eo '.*-xrdp-.*' && \
        echo "" && \
        echo "" && \
        mv /etc/skel/.xsession /etc/skel/.xsession_b && echo 'pulseaudio -D' > /etc/skel/.xsession && cat /etc/skel/.xsession_b >> /etc/skel/.xsession && rm /etc/skel/.xsession_b && \
        rm -rf /root/pulseaudio*; \
    else apt-get purge -y pulseaudio pavucontrol; fi

RUN apt-get -y autoremove

EXPOSE 3389

WORKDIR /root

ENTRYPOINT rm /var/run/xrdp/xrdp.pid & sleep 2 && service xrdp start && service dbus start && /bin/bash
