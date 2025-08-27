FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y \
    unzip curl libssl3 libcurl4 libstdc++6 python3 git cron jq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /server

# Copy scripts
COPY start.sh install_playit.sh entrypoint.sh backup.sh restore.sh setup_playit.sh auto-backup.sh ./
RUN chmod +x start.sh install_playit.sh entrypoint.sh backup.sh restore.sh setup_playit.sh auto-backup.sh

# Copy and extract server
COPY bedrock-server.zip /server/
RUN unzip -o bedrock-server.zip -d /server && rm bedrock-server.zip

# Create directory for worlds
RUN mkdir -p /server/worlds

# Set up scheduled backups with cron
RUN echo "0 */6 * * * /server/backup.sh > /proc/1/fd/1 2>/proc/1/fd/2" | crontab -

# Optimize Bedrock config for free tier
RUN sed -i 's/^view-distance=.*/view-distance=3/' server.properties && \
    sed -i 's/^tick-distance=.*/tick-distance=1/' server.properties && \
    sed -i 's/^max-players=.*/max-players=3/' server.properties && \
    sed -i 's/^server-authoritative-movement=.*/server-authoritative-movement=client-auth/' server.properties && \
    sed -i 's/^player-movement-distance-threshold=.*/player-movement-distance-threshold=1.0/' server.properties || true

EXPOSE 19132/udp

# Start cron service and server
CMD ["/server/entrypoint.sh"]
