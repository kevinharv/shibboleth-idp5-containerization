FROM debian:12

# Set configuration variables
ENV JETTY_HOME="/opt/jetty"
ENV JETTY_BASE="/var/lib/jetty"
ENV SHIBBOLETH_IDP_HOME="/opt/shibboleth-idp"
ENV SHIBBOLETH_IDP_VERSION="5.1.3"
ENV CORRETTO_VERSION="17.0.7.7.1"

# Install OS dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip

# Install Amazon Coretto 17
RUN wget https://corretto.aws/downloads/resources/${CORRETTO_VERSION}/amazon-corretto-${CORRETTO_VERSION}-linux-x64.tar.gz -O /tmp/corretto.tar.gz \
    && mkdir -p /usr/local/corretto \
    && tar -xzf /tmp/corretto.tar.gz -C /usr/local/corretto --strip-components=1 \
    && rm /tmp/corretto.tar.gz

# Install Jetty 12

# Setup Jetty

# Download IdP 5

# Setup IdP

CMD ["echo", "hi"]