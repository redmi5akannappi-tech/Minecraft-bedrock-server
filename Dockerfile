FROM eclipse-temurin:21-jre-alpine

# Install minimal dependencies
# - gcompat: glibc compatibility for playit binary
# - bash, curl, jq, git, tar, gzip, coreutils: for scripts
# - python3: for health-check HTTP server
RUN apk add --no-cache \
    bash curl jq git tar gzip coreutils python3 gcompat

# Download playit binary directly (no PPA needed on Alpine)
RUN curl -SsL -o /usr/local/bin/playit \
    https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 \
    && chmod +x /usr/local/bin/playit

# Set working directory
WORKDIR /server

# Copy scripts
COPY entrypoint.sh start.sh auto-backup.sh backup.sh restore.sh ./
RUN chmod +x entrypoint.sh start.sh auto-backup.sh backup.sh restore.sh

# Copy Paper server JAR
COPY paper.jar /server/paper.jar

# Accept EULA
RUN echo "eula=true" > /server/eula.txt

# Copy plugin JARs
RUN mkdir -p /server/plugins
COPY Geyser-Spigot.jar /server/plugins/Geyser-Spigot.jar
COPY floodgate-spigot.jar /server/plugins/floodgate-spigot.jar

# Create optimized server.properties
RUN printf '\
server-port=25565\n\
gamemode=survival\n\
difficulty=normal\n\
max-players=3\n\
view-distance=4\n\
simulation-distance=4\n\
online-mode=false\n\
enable-command-block=true\n\
motd=Paper + Geyser Server\n\
' > /server/server.properties

# Expose ports: Java (25565), Bedrock via Geyser (19132), Health check (8080)
EXPOSE 25565/tcp
EXPOSE 19132/udp
EXPOSE 8080/tcp

# Run entrypoint
CMD ["/server/entrypoint.sh"]
