ARG IMAGE_TAG__MAVEN

# hadolint ignore=DL3006
FROM alpine:3.18.4 as copy
COPY Application-*.jar /home/app/service.jar
RUN apk add --no-cache unzip=6.0-r14 && \
    unzip -d /home/app/ /home/app/service.jar

# hadolint ignore=DL3006
FROM ${IMAGE_TAG__MAVEN} as final
RUN mkdir -p /home/app/start && mkdir -p /home/app/tmp && useradd -ms /bin/bash service \
    && rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime \
    && chown -R service:service /home/app && chown -R service:service /tmp
USER service:service
COPY --from=copy /home/app/ /home/app/start

ENTRYPOINT ["java","-Xms256m","-Xmx512m","-Djava.io.tmpdir=/tmp","-cp","/home/app/start/BOOT-INF/lib/*:/home/app/start/BOOT-INF/classes/:/home/app/start/","by.flameksandr.kubernetes.Application"]

