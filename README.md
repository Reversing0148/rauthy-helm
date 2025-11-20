# Rauthy Helm Chart

[Rauthy](https://github.com/sebadob/rauthy) is an OpenID Connect (OIDC) Provider and Single Sign-On (SSO) solution written in Rust. It provides a secure, fast, and reliable authentication service for your applications.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- Persistent volume provisioner support in the underlying infrastructure (if persistence is enabled)

## Features

- Automated starter secret generation based on the [minimal production configuration](https://sebadob.github.io/rauthy/config/config_minimal.html) for getting familiar with rauthy,
- Bring Your Own configuration via external secret,
- Highly available, clustered setup support,
- External access via Ingress / httpRoute,
- Metrics and serviceMonitor support.

## Installation

### Add Helm Repository

```bash
helm repo add rauthy-helm https://reversing0148.github.io/rauthy-helm
helm repo update
```

### Install Chart

```bash
# Install with default values
helm install rauthy rauthy-helm/rauthy

# Install with custom namespace
helm install rauthy rauthy-helm/rauthy --create-namespace --namespace rauthy

# Install with custom values file
helm install rauthy rauthy-helm/rauthy -f values.yaml
```

## Uninstallation

```bash
helm uninstall rauthy
```

## Parameters

### Global Parameters

| Name | Description | Value |
|------|-------------|-------|
| `replicaCount` | Number of Rauthy replicas | `1` |

### Image Parameters

| Name | Description | Value |
|------|-------------|-------|
| `image.repository` | Rauthy image repository | `ghcr.io/sebadob/rauthy` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.tag` | Image tag (overrides the chart appVersion) | `` |
| `imagePullSecrets` | Docker registry secret names | `[]` |

### Security Parameters

| Name | Description | Value |
|------|-------------|-------|
| `podSecurityContext.runAsNonRoot` | Run containers as non-root user | `true` |
| `podSecurityContext.fsGroup` | Group ID for the container | `10001` |
| `securityContext.runAsUser` | User ID for the container | `10001` |
| `securityContext.runAsGroup` | Group ID for the container | `10001` |
| `securityContext.allowPrivilegeEscalation` | Allow privilege escalation | `false` |

### Service Parameters

| Name | Description | Value |
|------|-------------|-------|
| `service.annotations` | Annotations for the service| `{}` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Rauthy port exposed by the service | `8080` |
| `service.scheme` | Rauthy http and api scheme | `http` |

### Headless Service Parameters
This enables pod to pod communication for clustered deployments.

| Name | Description | Value |
|------|-------------|-------|
| `headlessService.ports.raft` | Raft port used by Rauthy | `8100` |
| `headlessService.ports.api` | Api port used by Rauthy | `8200` |

### Metrics configuration
This defines a port for metrics on the service and pod resources. 

| Name | Description | Value |
|------|-------------|-------|
| `metrics.enabled` | Enable metrics port on the service | `false` |
| `metrics.port` | Metrics port to be published via the service | `9090` |

### Ingress Parameters

| Name | Description | Value |
|------|-------------|-------|
| `ingress.enabled` | Enable ingress record generation | `false` |
| `ingress.className` | IngressClass that will be used | `` |
| `ingress.annotations` | Additional annotations for the Ingress resource | `{}` |
| `ingress.hosts` | Array of ingress hosts | See values.yaml |
| `ingress.tls` | TLS configuration for ingress | `[]` |

### Persistence Parameters

| Name | Description | Value |
|------|-------------|-------|
| `persistence.enabled` | Enable persistent volume claims | `false` |
| `persistence.size` | Persistent Volume size | `256Mi` |
| `persistence.accessMode` | Persistent Volume access mode | `ReadWriteOnce` |
| `persistence.storageClassName` | Persistent Volume storage class | `` |


### Memory Allocator Parameters

| Name | Description | Value |
|------|-------------|-------|
| `malloc.preset` | Jemalloc preset (small/medium/big/open/custom) | `medium` |
| `malloc.custom` | Custom malloc configuration when preset is "custom" | `""` |

### Configuration Parameters

| Name | Description | Value |
|------|-------------|-------|
| `config.generate` | Enable automatic config.toml generation | `true` |
| `config.trustedProxies` | List of trusted proxy CIDR ranges | `[]` |
| `externalSecret` | Name of existing secret containing Rauthy configuration | `""` |

## Examples

### Single Instance Deployment

```yaml
replicaCount: 1

config:
  generate: true
  proxyMode: true
  trustedProxies:
    - "10.199.20.0/24"

malloc:
  preset: small

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: auth.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: rauthy-tls
      hosts:
        - auth.example.com

persistence:
  enabled: true
  size: 256Mi
```

### High Availability Deployment

```yaml
replicaCount: 3

config:
  generate: true
  proxyMode: true
  trustedProxies:
    - "10.199.20.0/24"

malloc:
  preset: big

resources:
  requests:
    memory: 512Mi
    cpu: 200m

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: auth.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: rauthy-tls
      hosts:
        - auth.example.com

persistence:
  enabled: true
  size: 256Mi
```

## Generating rauthy configuration
The chart allows you to deploy rauthy by generating a configuration for you based on the [minimal production configuration](https://sebadob.github.io/rauthy/config/config_minimal.html).

To use this feature keep the externalSecret empty.

## Bring your own secret

The chart supports configuring rauthy via your own secret.

You can do this by creating a secret in the same namespace as rauthy, then providing the secret name, in the `externalSecret` field. For example:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: rauthy-config
  namespace: rauthy
type: Opaque
stringData:
  config.toml: |-
    # paste and adjust config from
    # https://sebadob.github.io/rauthy/config/config_minimal.html
    # or
    # https://sebadob.github.io/rauthy/config/config.html
```
Make sure to keep `values.yaml` updated:
```yaml
externalSecret: "rauthy-config"
```

## Persistence

The chart mounts a persistent volume at `/app/data` for storing Rauthy's internal hiqlite database and configuration.

By default, the chart uses an `emptyDir` volume when persistence is disabled.


## HTTPRoute considerations

- When `existingSecret` is not set, and `HTTPRoute` is enabled the templates assume you have tls configured on the gateway when generating the secret template.

## License

Like rauthy this helm chart is licensed under the Apache License 2.0.