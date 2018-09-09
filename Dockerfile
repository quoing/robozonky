FROM alpine:latest AS builder
MAINTAINER Quoing
WORKDIR /opt
ARG JDK_URL=https://download.java.net/java/early_access/alpine/28/binaries/openjdk-11+28_linux-x64-musl_bin.tar.gz
ARG MAVEN_URL=http://www-eu.apache.org/dist/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
RUN apk add --virtual .build-deps --no-cache wget \
      && wget -q --no-check-certificate $JDK_URL \
      && wget -q --no-check-certificate $MAVEN_URL \
      && tar -zxvf openjdk-*.tar.gz \
      && tar -zxvf apache-maven-*.tar.gz \
      && rm -f *.tar.gz apk \
      && apk del --no-cache .build-deps
ENV JAVA_HOME=/opt/jdk-11
ENV PATH="/opt/jdk-11/bin:/opt/apache-maven-3.5.4/bin:${PATH}"
ARG GIT_TAG=robozonky-4.8.2
ENV SOURCE_DIRECTORY=/usr/src/robozonky \
    BINARY_DIRECTORY=/tmp/robozonky
#COPY assets/* $SOURCE_DIRECTORY
RUN apk add --no-cache xz git \
    && mkdir -p /usr/src && cd /usr/src && git clone https://github.com/RoboZonky/robozonky.git /usr/src/robozonky && cd /usr/src/robozonky && git checkout $GIT_TAG
WORKDIR $SOURCE_DIRECTORY
#ENV PATH="${PATH}:/usr/lib/jvm/java-1.8-openjdk/bin"
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
RUN jlink \
     --module-path /opt/java/jmods \
     --compress=2 \
     --add-modules jdk.jfr,jdk.management.agent,java.base,java.logging,java.xml,jdk.unsupported,java.sql,java.naming,java.desktop,java.management,java.security.jgss,java.instrument \
     --no-header-files \
     --no-man-pages \
     --strip-debug \
     --output /opt/jre


FROM alpine:latest
LABEL maintainer="Quoing"
ENV INSTALL_DIRECTORY=/opt/robozonky \
     CONFIG_DIRECTORY=/etc/robozonky
COPY --from=builder /opt/jre /opt/jre
ENV JAVA_HOME="/opt/jre"
ENV PATH="/opt/jre/bin:${PATH}"
COPY --from=builder /tmp/robozonky $INSTALL_DIRECTORY
WORKDIR /var/robozonky
COPY assets/tools /opt/robozonky/tools/
COPY assets/start.sh /
ENV PATH="${PATH}:/usr/lib/jvm/java-1.8-openjdk/bin:/opt/robozonky/tools"
EXPOSE 7091
CMD ["/start.sh"]


