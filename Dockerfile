FROM alpine:3.15 as builder

RUN apk add alpine-sdk libtool sudo
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/abuild
RUN adduser -s /bin/sh -D -G abuild abuild
RUN addgroup abuild abuild
RUN addgroup abuild wheel
RUN mkdir -p /var/cache/distfiles
RUN chgrp abuild /var/cache/distfiles
RUN chmod g+w /var/cache/distfiles

USER abuild
WORKDIR /home/abuild
RUN wget https://github.com/ralph-irving/squeezelite/archive/master.zip
RUN unzip master.zip

WORKDIR /home/abuild/squeezelite-master/alpine
RUN abuild-keygen -a -n -i

WORKDIR /home/abuild/squeezelite-master/alpine/libalac
RUN abuild checksum
RUN abuild -r

WORKDIR /home/abuild/squeezelite-master/alpine/libtremor
RUN abuild checksum
RUN abuild -r

RUN sudo apk add \
	/home/abuild/packages/alpine/*/libalac-1.0.0-r1.apk \
	/home/abuild/packages/alpine/*/libalac-dev-1.0.0-r1.apk \
	/home/abuild/packages/alpine/*/libtremor-0.19681-r0.apk \
	/home/abuild/packages/alpine/*/libtremor-dev-0.19681-r0.apk

WORKDIR /home/abuild/squeezelite-master/alpine
RUN abuild checksum
RUN abuild -r


FROM alpine:3.15

COPY --from=builder /home/abuild/packages/alpine/*/libalac-1.0.0-r1.apk /home/abuild/packages/alpine/*/libtremor-0.19681-r0.apk /home/abuild/packages/squeezelite-master/*/squeezelite-1.9.9.1401-r0.apk /root/
RUN apk add --allow-untrusted /root/libalac-1.0.0-r1.apk /root/libtremor-0.19681-r0.apk /root/squeezelite-1.9.9.1401-r0.apk && \
	apk add jack alsa-plugins-jack

RUN echo -e 'pcm.rawjack {\n\
    type jack\n\
    playback_ports {\n\
        0 system:playback_1\n\
        1 system:playback_2\n\
    }\n\
    capture_ports {\n\
        0 system:capture_1\n\
        1 system:capture_2\n\
    }\n\
}\n\
\n\
pcm.jack {\n\
    type plug\n\
    slave { pcm "rawjack" }\n\
    hint {\n\
        description "JACK Audio Connection Kit"\n\
    }\n\
}\n\
\n\
pcm.!default {\n\
    type plug\n\
    slave { pcm "rawjack" }\n\
}' > /root/.asoundrc
