FROM debian:bookworm-slim

# Install only required dependencies
RUN apt-get update && apt-get install -y \
    unzip curl libssl3 libcurl4 libstdc++6 python3 \
    && rm -rf /var/lib/apt/lists/*


# Set working directory
WORKDIR /server

# Copy scripts into container
COPY start.sh install_playit.sh entrypoint.sh ./
RUN chmod +x start.sh install_playit.sh entrypoint.sh

# Copy Bedrock server zip and unzip it
COPY bedrock-server.zip /server/
RUN unzip -o bedrock-server.zip -d /server && rm bedrock-server.zip

# Optimize server.properties for low-memory
RUN sed -i 's/^view-distance=.*/view-distance=3/' server.properties && \
    sed -i 's/^tick-distance=.*/tick-distance=1/' server.properties && \
    sed -i 's/^max-players=.*/max-players=3/' server.properties && \
    sed -i 's/^server-authoritative-movement=.*/server-authoritative-movement=client-auth/' server.properties && \
    sed -i 's/^player-movement-distance-threshold=.*/player-movement-distance-threshold=1.0/' server.properties || true

# Expose Bedrock port (UDP handled by Playit)
EXPOSE 19132/udp

# Run entrypoint
CMD ["/server/entrypoint.sh"]
