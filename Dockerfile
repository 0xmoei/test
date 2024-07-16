# First stage: build environment
FROM golang:1.22 AS builder

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Build the application
RUN CGO_ENABLED=1 GOOS=linux go build -o /build/station-evm ./cmd/station-evmd/main.go

# Debug: Check the build output
RUN ls -l /build
RUN echo "Binary size: $(du -h /build/station-evm | cut -f1)"

# Second stage: runtime environment
FROM ubuntu:22.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    ca-certificates \
    bash \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Create a directory for the binary and blockchain data
WORKDIR /app
RUN mkdir -p /root/.evmosd1

# Copy the binary from the builder stage
COPY --from=builder /build/station-evm /app/station-evm

# Copy the local setup script into the container
COPY local-setup.sh /usr/local/bin/local-setup.sh

# Make sure the script is executable
RUN chmod +x /usr/local/bin/local-setup.sh

# Expose necessary ports
EXPOSE 8545 8546 26656 26657 1317 30303

# Debug: Check if the binary is correctly copied
RUN ls -l /app
RUN echo "Binary size: $(du -h /app/station-evm | cut -f1)"
RUN /app/station-evm version || echo "Failed to run version command"

# Set environment variables
ENV CHAINID="stationevm_1234-1"
ENV MONIKER="localtestnet1"
ENV KEYRING="test"
ENV KEYALGO="eth_secp256k1"
ENV LOGLEVEL="info"
ENV HOMEDIR="/root/.evmosd1"
ENV TRACE=""
ENV BASEFEE=1000000000
ENV VAL_KEY="mykey1"

# Create a startup script
RUN echo '#!/bin/bash\n\
/usr/local/bin/local-setup.sh -y --no-install\n\
exec /app/station-evm start --home "$HOMEDIR" "$@"' > /app/start.sh && \
    chmod +x /app/start.sh

# Set the entry point to the startup script
ENTRYPOINT ["/app/start.sh"]