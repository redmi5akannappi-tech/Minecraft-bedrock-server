FROM eclipse-temurin:21-jre-alpine

# Install minimal dependencies
RUN apk add --no-cache \
    bash curl jq python3 gcompat

# Install playit
RUN curl -SsL -o /usr/local/bin/playit \
    https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 \
    && chmod +x /usr/local/bin/playit

# Set working directory
WORKDIR /

# Copy FULL pre-initialized server
COPY Mine-Java-Server /Mine-Java-Server

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports
EXPOSE 25565/tcp
EXPOSE 19132/udp
EXPOSE 8080/tcp

CMD ["/entrypoint.sh"]