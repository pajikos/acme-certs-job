# ACME Certificates Job

This repository provides a Docker-based solution for automatically renewing and managing SSL/TLS certificates using [lego](https://github.com/go-acme/lego) and Kubernetes secrets. The solution is configured to work with the Wedos DNS provider.

## Table of Contents

- [ACME Certificates Job](#acme-certificates-job)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Configuration](#configuration)
    - [`domains.config`](#domainsconfig)
    - [Environment Variables](#environment-variables)
  - [Usage](#usage)
  - [Environment Variables](#environment-variables-1)
  - [License](#license)

## Prerequisites

- Docker installed on your machine.
- Access to a Kubernetes cluster with `kubectl` configured.
- A Wedos account with API access.

## Installation

To get started, pull the Docker image from the GitHub Container Registry:

```sh
docker pull ghcr.io/pajikos/acme-certs-job:latest
```

## Configuration

### `domains.config`

Create a `domains.config` file to specify the domains and corresponding Kubernetes namespaces where the certificates should be applied. The format is:

```plaintext
<domain>=<namespace1>,<namespace2>,...
```

Example:

```plaintext
argocd.k8s.example.com=argocd
```

### Environment Variables

The Docker container uses several environment variables for configuration. These can be overridden when running the container.

- `LEGO_EMAIL`: Email address for ACME registration.
- `WEDOS_USERNAME`: Username for Wedos API.
- `WEDOS_WAPI_PASSWORD`: Password for Wedos API.
- `WEDOS_TTL`: Time-to-live for DNS records.
- `WEDOS_POLLING_INTERVAL`: Polling interval for DNS propagation checks.
- `WEDOS_PROPAGATION_TIMEOUT`: Timeout for DNS propagation.

## Usage

Run the Docker container with the required environment variables and mount a volume for storing the certificate files:

```sh
docker run -e LEGO_EMAIL="your-email@example.com" \
           -e WEDOS_USERNAME="your-wedos-username" \
           -e WEDOS_WAPI_PASSWORD="your-wedos-password" \
           -e WEDOS_TTL=300 \
           -e WEDOS_POLLING_INTERVAL=180 \
           -e WEDOS_PROPAGATION_TIMEOUT=1800 \
           -v $(pwd)/lego-files:/app/lego-files \
           ghcr.io/pajikos/acme-certs-job:latest
```

## Environment Variables

| Variable                   | Default Value             | Description                                    |
|----------------------------|---------------------------|------------------------------------------------|
| `LEGO_EMAIL`               | `your-email@example.com`  | Email address for ACME registration            |
| `WEDOS_USERNAME`           | `your-wedos-username`     | Username for Wedos API                         |
| `WEDOS_WAPI_PASSWORD`      | `your-wedos-password`     | Password for Wedos API                         |
| `WEDOS_TTL`                | `300`                     | Time-to-live for DNS records                   |
| `WEDOS_POLLING_INTERVAL`   | `180`                     | Polling interval for DNS propagation checks    |
| `WEDOS_PROPAGATION_TIMEOUT`| `1800`                    | Timeout for DNS propagation                    |

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.