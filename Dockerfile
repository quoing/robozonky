FROM alpine:latest AS builder
ENV SOURCE_DIRECTORY=/usr/src/robozonky \
    BINARY_DIRECTORY=/tmp/robozonky
#COPY assets/* $SOURCE_DIRECTORY
ARG GIT_TAG=robozonky-4.9.0
RUN apk add --no-cache maven xz git openjdk8 \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone https://github.com/RoboZonky/robozonky.git /usr/src/robozonky \
    && cd /usr/src/robozonky \
    && git checkout $GIT_TAG
WORKDIR $SOURCE_DIRECTORY
WORKDIR $SOURCE_DIRECTORY
ENV PATH="${PATH}:/usr/lib/jvm/java-1.8-openjdk/bin"
#RUN mvn clean install -T1C -B -Dgpg.skip -DskipTests -Ddocker
RUN mvn clean install -T1C -B -Dgpg.skip -DskipTests
RUN ROBOZONKY_VERSION=$(mvn -q \
            -Dexec.executable="echo" \
            -Dexec.args='${project.version}' \
            --non-recursive \
            org.codehaus.mojo:exec-maven-plugin:1.6.0:exec \
        ) \
    && ROBOZONKY_TAR_XZ=robozonky-distribution/robozonky-distribution-full/target/robozonky-distribution-full-$ROBOZONKY_VERSION.tar.xz \
    && mkdir -vp $BINARY_DIRECTORY \
    && tar -C $BINARY_DIRECTORY -xvf $ROBOZONKY_TAR_XZ \
    && cp robozonky-distribution/robozonky-distribution-cli/target/robozonky-distribution-cli-$ROBOZONKY_VERSION-full.jar $BINARY_DIRECTORY/bin

FROM alpine:latest
LABEL maintainer="Quoing"
ENV INSTALL_DIRECTORY=/opt/robozonky \
     CONFIG_DIRECTORY=/etc/robozonky
COPY --from=builder /tmp/robozonky $INSTALL_DIRECTORY
WORKDIR /var/robozonky
RUN apk add --no-cache openjdk8-jre-base
COPY assets/tools /opt/robozonky/tools/
COPY assets/start.sh /
ENV PATH="${PATH}:/usr/lib/jvm/java-1.8-openjdk/bin:/opt/robozonky/tools"
EXPOSE 7091
CMD ["/start.sh"]


