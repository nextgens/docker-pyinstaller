FROM debian:jessie
MAINTAINER Florent Daigniere <nextgens+git@freenetproject.org>

ENV USER_ID 1000
ENV GROUP_ID 1000

RUN addgroup --system --gid $GROUP_ID wine && adduser --system --uid=$USER_ID --gid=$GROUP_ID --home /wine --shell /bin/sh --gecos "Wine" wine

RUN dpkg --add-architecture i386 &&\
    apt-get update &&\
    apt-get install --no-install-recommends -y \
        ca-certificates \
        wget \
        wine32=1.6.* \
        winbind \
        binutils \
        upx-ucl \
        xauth \
        xvfb \
        &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

WORKDIR /wine
USER wine

ENV WINEPREFIX /wine/.wine32
ENV WINEDLLOVERRIDES "mscoree,mshtml="
ENV WINE /usr/bin/wine32
ENV WINEARCH win32

RUN wine32 wineboot -i && while pgrep wineserver > /dev/null; do sleep 1;done

RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && echo "dd76697a1f89b23ba4b6568d185f9df342b58960798436c9f8dc09bd270653fb  winetricks" | sha256sum --check --strict && xvfb-run sh winetricks --unattended vcrun2008 vcrun2010 && rm winetricks && while pgrep wineserver > /dev/null; do sleep 1;done

RUN wget https://www.python.org/ftp/python/2.7.9/python-2.7.9.msi &&\
    echo "22f8a2b3231f9f671d660f149f7e60215b1908fa09fbb832123bf12a3e20b447  python-2.7.9.msi" | sha256sum --check --strict && xvfb-run wine32 msiexec /i python-2.7.9.msi -quiet -qn -norestart 'TargetDir=c:\Python2.7\'  && rm python-2.7.9.msi && while pgrep wineserver > /dev/null; do sleep 1;done

RUN xvfb-run wine32 "c:\Python2.7\python" -m pip install pypiwin32 pyinstaller cryptography tuf && while pgrep wineserver > /dev/null; do sleep 1;done

ADD build.sh ./

CMD ["./build.sh"]
