FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    unzip curl libcurl4 libstdc++6 python3 jq git tar gzip coreutils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /server

COPY start.sh install_playit.sh entrypoint.sh auto-backup.sh backup.sh restore.sh fake_server.py ./
RUN chmod +x start.sh install_playit.sh entrypoint.sh auto-backup.sh backup.sh restore.sh fake_server.py

COPY bedrock-server.zip .
RUN unzip -o bedrock-server.zip && rm bedrock-server.zip

# Optimize server.properties for low-memory (only if exists)
RUN if [ -f server.properties ]; then \
    sed -i 's/^view-distance=.*/view-distance=3/' server.properties; \
    sed -i 's/^tick-distance=.*/tick-distance=1/' server.properties; \
    sed -i 's/^max-players=.*/max-players=3/' server.properties; \
    sed -i 's/^server-authoritative-movement=.*/server-authoritative-movement=client-auth/' server.properties; \
    sed -i 's/^player-movement-distance-threshold=.*/player-movement-distance-threshold=1.0/' server.properties; \
  fi

# Render requires TCP listener; fake server listens on 8080
EXPOSE 8080/tcp

CMD ["/server/entrypoint.sh"]
