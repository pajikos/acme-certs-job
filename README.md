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
- [Kustomize Deployment Documentation](#kustomize-deployment-documentation)
  - [Directory Structure](#directory-structure)
  - [Base Configuration](#base-configuration)
  - [Overlay Configuration](#overlay-configuration)
  - [Steps to Deploy](#steps-to-deploy)
  - [Notes](#notes)
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


# Kustomize Deployment Documentation

This documentation provides instructions on how to set up and deploy a Kubernetes Job using Kustomize. The deployment includes a PersistentVolumeClaim (PVC), a ConfigMap for domain configurations, environment variables, and necessary RBAC resources. The overlay is named `example`.

## Directory Structure

The directory structure for the Kustomize setup is as follows:

```
kustomize/
├── base/
│   ├── kustomization.yaml
│   ├── pvc.yaml
│   ├── cronjob.yaml
│   ├── serviceaccount.yaml
│   ├── role.yaml
│   ├── rolebinding.yaml
│   ├── environment-properties.env
│   └── domains.config
├── overlays/
│   └── example/
│       ├── kustomization.yaml
│       ├── domains.config
│       └── environment-properties.env
```

## Base Configuration

The `base` directory contains the core resources and configurations:
- `kustomization.yaml`: Defines the base resources and ConfigMap generators.
- `pvc.yaml`: Defines the PersistentVolumeClaim.
- `cronjob.yaml`: Defines the CronJob.
- `serviceaccount.yaml`: Defines the ServiceAccount.
- `role.yaml`: Defines the Role for creating secrets.
- `rolebinding.yaml`: Defines the RoleBinding that binds the Role to the ServiceAccount.
- `environment-properties.env`: Contains the default environment variables.

## Overlay Configuration

The `overlays/example` directory contains the overlay-specific configurations:
- `kustomization.yaml`: Defines the overlay and overrides the environment variables.
- `domains.config`: Contains the domain configurations.
- `environment-properties.env`: Contains the overridden environment variables.

## Steps to Deploy

1. **Navigate to the Overlay Directory**:
   Change your working directory to the `example` overlay directory.
   ```sh
   cd kustomize/overlays/example
   ```

2. **Check the Kustomize Configuration**:
   Use the `kubectl kustomize` command to render the Kustomize configuration and output the resulting YAML.
   ```sh
   kubectl kustomize .
   ```

   This command will output the combined YAML of all your resources, including any overrides specified in the `example` overlay. Review the output to ensure that all configurations are correct.

3. **Apply the Kustomize Configuration**:
   If everything looks correct, you can then apply the Kustomize configuration using the `kubectl apply -k` command.
   ```sh
   kubectl apply -k .
   ```
   ```

This command will generate and apply all the necessary Kubernetes resources, including the PVC, ConfigMaps, ServiceAccount, Role, RoleBinding, and CronJob, with the environment variables overridden as specified in the `example` overlay.

## Notes

- Ensure that you have `kubectl` and `kustomize` installed and configured to interact with your Kubernetes cluster.
- The `environment-properties.env` file in the `example` overlay can be used to override specific environment variables defined in the base configuration.
- The `domains.config` file in the `example` overlay should contain the domain configurations required for the Job.

By following these steps, you can deploy the Kubernetes Job with the necessary configurations and environment variables using Kustomize.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.