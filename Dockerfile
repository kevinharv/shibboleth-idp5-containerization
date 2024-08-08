FROM debian:12

# Set configuration variables
ENV IDP_HOSTNAME="idp.kevharv.com"
ENV IDP_SCOPE="kevharv.com"

ENV SHIBBOLETH_IDP_VERSION="5.1.3"
ENV JETTY_VERSION="12.0.12"
ENV CORRETTO_VERSION="17.0.7.7.1"

ENV JAVA_HOME="/usr/local/corretto"
ENV JETTY_HOME="/opt/jetty"
ENV JETTY_BASE="/var/lib/jetty"
ENV SHIBBOLETH_IDP_HOME="/opt/shibboleth-idp"

# Install OS dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    openssl

# Install Amazon Coretto 17
RUN curl -L https://corretto.aws/downloads/resources/${CORRETTO_VERSION}/amazon-corretto-${CORRETTO_VERSION}-linux-x64.tar.gz -o /tmp/corretto.tar.gz \
    && mkdir -p $JAVA_HOME \
    && tar -xzf /tmp/corretto.tar.gz -C $JAVA_HOME --strip-components=1 \
    && rm /tmp/corretto.tar.gz

# Install Jetty 12
RUN curl -L https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/12.0.12/jetty-home-${JETTY_VERSION}.tar.gz -o /tmp/jetty.tar.gz \
    && mkdir -p $JETTY_HOME \
    && tar -xzf /tmp/jetty.tar.gz -C $JETTY_HOME --strip-components=1 \
    && rm /tmp/jetty.tar.gz

# Setup Jetty
COPY "jetty-base" ${JETTY_BASE}
RUN ${JAVA_HOME}/bin/java -jar ${JETTY_HOME}/start.jar --add-module=logging-logback --approve-all-licenses
RUN wget https://registry.idem.garr.it/idem-conf/shibboleth/IDP5/jetty-conf/start.ini -O /opt/jetty/start.ini

# Generate self-signed SSL certificate
RUN mkdir certs \
    && openssl req -newkey rsa:4096 -x509 -sha512 -days 365 -nodes -out certs/sslcert.pem -keyout certs/sslcert.key -subj "/CN=localhost" \ 
    && openssl pkcs12 -export -out ${JETTY_BASE}/credentials/idp-userfacing.p12 -inkey certs/sslcert.key -in certs/sslcert.pem -passout pass:foobar \
    && rm -r certs

# Download IdP 5
RUN curl -L https://shibboleth.net/downloads/identity-provider/${SHIBBOLETH_IDP_VERSION}/shibboleth-identity-provider-${SHIBBOLETH_IDP_VERSION}.tar.gz -o /tmp/idp.tar.gz \
    && mkdir -p /tmp/idp \
    && tar -xzf /tmp/idp.tar.gz -C /tmp/idp --strip-components=1 \
    && rm /tmp/idp.tar.gz

# Install IdP 5
RUN mkdir -p $SHIBBOLETH_IDP_HOME \
    && sh -C /tmp/idp/bin/install.sh --noPrompt \
        -t $SHIBBOLETH_IDP_HOME \
        -h $IDP_HOSTNAME \
        -e $IDP_HOSTNAME \
        --scope $IDP_SCOPE \
    && rm -r /tmp/idp

# Setup IdP


EXPOSE 80 443
ENTRYPOINT ["/usr/local/corretto/bin/java", "-Djetty.base=/var/lib/jetty", "-Djetty.home=/opt/jetty", "-jar", "/opt/jetty/start.jar"]