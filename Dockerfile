FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    unzip curl libssl3 libcurl4 libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /tmp/server

# Copy scripts
COPY start.sh install_playit.sh ./
RUN chmod +x start.sh install_playit.sh

# Copy Bedrock server zip and unzip it
COPY bedrock-server-1.21.102.1.zip ./
RUN unzip -o bedrock-server.zip && rm bedrock-server.zip

# Expose Bedrock port (UDP handled by Playit)
EXPOSE 19132/udp

# Run Playit agent in background, then start Bedrock
CMD ./install_playit.sh && ./playit & ./start.sh
