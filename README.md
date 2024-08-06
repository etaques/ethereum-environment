This document provides an overview and configuration details of the Docker Compose setup used for deploying various services, including Ethereum clients, monitoring, and logging tools.

### Summary

This setup provides a comprehensive environment for running an Ethereum node (`geth`), a consensus client (`lodestar`), and a suite of monitoring and logging tools (`prometheus`, `grafana`, `loki`, `promtail`). Additionally, it includes `alertmanager` for handling alerts and `mailhog` for email testing, all interconnected through the `eth-net` network. This configuration is ideal for a development or testing environment, allowing for robust monitoring and logging of blockchain-related activities.

### 1. **geth**

- **Purpose**: Geth (Go Ethereum) is a client for the Ethereum network. It's used to interact with the Ethereum blockchain, handle transactions, deploy and interact with smart contracts, and more.
- **Image**: `ethereum/client-go:v1.14.7` - This is a specific version of the Geth client.
- **Entrypoint**: `/root/bin/geth.sh` - A script that runs upon container start, likely to initialize and start Geth with specific parameters.
- **Ports**: 
  - `8545` (HTTP-RPC)
  - `8546` (WebSocket-RPC)
  - `8551` (Engine API)
  - `30303` (P2P protocol TCP and UDP)
  - `8300` (Discovery)
- **Volumes**:
  - `./geth/data:/root/.ethereum`: Stores Ethereum blockchain data.
  - `./geth/holesky:/root/holesky`: Likely used for a specific network setup (Holensky).
  - `./geth/bin/:/root/bin/`: Custom scripts or binaries.
  - `./geth/jwt:/root/.jwt`: Stores JWT tokens for authentication.
- **Network**: Connected to `eth-net` for internal communication with other services.

### 2. **lodestar**

- **Purpose**: Lodestar is an Ethereum consensus client. It implements the Ethereum Beacon Chain specification and is used for staking and validating transactions on Ethereum's proof-of-stake network.
- **Image**: `chainsafe/lodestar:v1.20.2`
- **Ports**:
  - `9000/tcp` and `9000/udp` (P2P communication)
  - `5054/tcp` (Metrics for monitoring)
- **Volumes**:
  - `./lodestar/data:/data`: Stores Lodestar client data.
  - `./geth/jwt:/root/.jwt`: Shared JWT tokens with Geth for authentication.
  - `/var/log/ethereum-environment:/var/log`: Log storage.
  - `/etc/timezone` and `/etc/localtime`: Timezone and local time configurations.
- **Environment Variables**: `NODE_OPTIONS= --max-old-space-size=8192` to allocate memory for the Node.js runtime.
- **Command**: Configures the Lodestar beacon node with various options like network, data directory, JWT secret, logging, REST API, metrics, and checkpoint synchronization.
- **Network**: Part of the `eth-net` network.

### 3. **prometheus**

- **Purpose**: Prometheus is a monitoring tool used to collect and store metrics from various sources, providing powerful querying and alerting capabilities.
- **Image**: `prom/prometheus:v2.53.1`
- **Command**: Specifies the configuration file and storage path for Prometheus.
- **Volumes**: 
  - `./prometheus/:/prometheus/`: Mounts the Prometheus configuration and data directories.
- **Ports**: `9090` for accessing the Prometheus web UI and querying metrics.
- **Network**: Part of the `eth-net` network.

### 4. **grafana**

- **Purpose**: Grafana is a visualization and analytics tool. It connects to various data sources, like Prometheus, and allows users to create and view dashboards and graphs.
- **Image**: `grafana/grafana:10.0.0`
- **Environment Variables**:
  - `GF_SECURITY_ADMIN_PASSWORD`: Sets the admin password.
  - `GF_PATHS_PROVISIONING`: Path for provisioning configuration files.
- **Volumes**:
  - `./grafana/provisioning:/etc/grafana/provisioning`: Provisioning configuration files for dashboards and data sources.
  - `./grafana/dashboards:/dashboards`: Dashboard files.
  - `grafana-data:/var/lib/grafana`: Persistent storage for Grafana data.
- **Ports**: `3000` for accessing the Grafana web UI.
- **Network**: Part of `eth-net`.
- **Depends On**: Prometheus, ensuring that Grafana starts after Prometheus.

### 5. **loki**

- **Purpose**: Loki is a log aggregation system designed to work with Prometheus. It stores and queries logs, helping to correlate them with metrics.
- **Image**: `grafana/loki:2.9.2`
- **Command**: Uses a configuration file for Loki's settings.
- **Volumes**:
  - `./loki:/loki`: Configuration and data storage for Loki.
- **Ports**: `3100` for the Loki API.
- **Network**: Part of `eth-net`.

### 6. **promtail**

- **Purpose**: Promtail is an agent that collects logs from various sources and forwards them to Loki for aggregation and storage.
- **Image**: `grafana/promtail:2.9.2`
- **Command**: Uses a configuration file to define what logs to collect and where to send them.
- **Volumes**:
  - `./promtail:/promtail`: Configuration and data storage for Promtail.
  - `/var/lib/docker/containers:/var/lib/docker/containers:ro`: Access to Docker container logs.
  - `/var/run/docker.sock:/var/run/docker.sock`: Access to Docker daemon for container discovery.
- **Network**: Part of `eth-net`.

### 7. **alertmanager**

- **Purpose**: Alertmanager handles alerts sent by Prometheus. It manages alerts, routes them to appropriate receivers, and deduplicates them.
- **Image**: `prom/alertmanager:latest`
- **Command**: Specifies the configuration file for Alertmanager.
- **Volumes**:
  - `./alertmanager:/alertmanager`: Configuration and data storage for Alertmanager.
- **Ports**: `9093` for accessing the Alertmanager web UI and API.
- **Network**: Part of `eth-net`.

### 8. **mailhog**

- **Purpose**: Mailhog is an email testing tool. It captures outgoing emails for inspection, useful in testing and development environments.
- **Image**: `mailhog/mailhog:latest`
- **Ports**:
  - `1025` for SMTP server, which captures outgoing emails.
  - `8025` for Mailhog's web UI to view captured emails.
- **Network**: Part of `eth-net`.

### Volumes

- **grafana-data**: A named volume for persistent Grafana data storage, ensuring that dashboards and settings persist across container restarts.

### Networks

- **eth-net**: A custom network defined for this Docker Compose setup, enabling inter-container communication. This isolates the services from the host and other containers unless explicitly exposed.
