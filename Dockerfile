FROM eclipse-temurin:21-jre-jammy

# Install dependencies (python3 for health check, curl/jq/git for backups, gpg for playit PPA)
RUN apt-get update && apt-get install -y \
    curl jq git tar gzip coreutils python3 gpg sudo \
    && rm -rf /var/lib/apt/lists/*

# Install playit via official PPA
RUN curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null \
    && echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | tee /etc/apt/sources.list.d/playit-cloud.list \
    && apt-get update \
    && apt-get install -y playit \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /server

# Copy scripts
COPY entrypoint.sh start.sh auto-backup.sh backup.sh restore.sh ./
RUN chmod +x entrypoint.sh start.sh auto-backup.sh backup.sh restore.sh

# Copy Paper server JAR
COPY paper.jar /server/paper.jar

# Accept EULA
RUN echo "eula=true" > /server/eula.txt

# Copy plugin JARs to a staging area (plugins/ folder created after first run)
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
