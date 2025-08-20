FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    unzip curl libssl3 libcurl4 libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /server

# Copy scripts into container
COPY start.sh install_playit.sh entrypoint.sh ./
RUN chmod +x start.sh install_playit.sh entrypoint.sh

# Copy Bedrock server zip and unzip it
COPY bedrock-server.zip /server/
RUN unzip -o bedrock-server.zip -d /server && rm bedrock-server.zip

# Expose Bedrock port (UDP handled by Playit)
EXPOSE 19132/udp

# Run entrypoint
CMD ["/server/entrypoint.sh"]
