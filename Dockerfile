FROM debian:bookworm-slim

# Install required dependencies
RUN apt-get update && apt-get install -y \
    unzip curl libssl3 libcurl4 libstdc++6 python3 python3-pip jq git tar gzip coreutils base64 \
    && rm -rf /var/lib/apt/lists/*

# Make sure pip packages are available if needed (we use only stdlib)
WORKDIR /server

# Copy scripts into container
COPY start.sh install_playit.sh entrypoint.sh auto-backup.sh backup.sh restore.sh fake_server.py ./
RUN chmod +x start.sh install_playit.sh entrypoint.sh auto-backup.sh backup.sh restore.sh

# Copy Bedrock server zip and unzip it
COPY bedrock-server.zip /server/
RUN unzip -o bedrock-server.zip -d /server && rm bedrock-server.zip || true

# Optimize server.properties for low-memory (if exists)
RUN if [ -f server.properties ]; then \
      sed -i 's/^view-distance=.*/view-distance=3/' server.properties && \
      sed -i 's/^tick-distance=.*/tick-distance=1/' server.properties && \
      sed -i 's/^max-players=.*/max-players=3/' server.properties && \
      sed -i 's/^server-authoritative-movement=.*/server-authoritative-movement=client-auth/' server.properties && \
      sed -i 's/^player-movement-distance-threshold=.*/player-movement-distance-threshold=1.0/' server.properties || true ;\
    fi

# Expose the fake HTTP/TCP port Render will hit (also Bedrock UDP)
ARG FAKE_PORT=8080
EXPOSE ${FAKE_PORT}/tcp
EXPOSE 19132/udp

# Run entrypoint
CMD ["/server/entrypoint.sh"]
