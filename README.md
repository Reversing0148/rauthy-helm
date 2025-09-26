# Rauthy Helm Chart

[Rauthy](https://github.com/sebadob/rauthy) is an OpenID Connect (OIDC) Provider and Single Sign-On (SSO) solution written in Rust. It provides a secure, fast, and reliable authentication service for your applications.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- Persistent volume provisioner support in the underlying infrastructure (if persistence is enabled)

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
| `podManagementPolicy` | Pod management policy for StatefulSet | `Parallel` |

### Image Parameters

| Name | Description | Value |
|------|-------------|-------|
| `image.repository` | Rauthy image repository | `ghcr.io/sebadob/rauthy` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.tag` | Image tag (overrides the chart appVersion) | `"0.32.3"` |
| `imagePullSecrets` | Docker registry secret names as an array | `[]` |

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
| `ports.http` | HTTP port | `8080` |
| `ports.raft` | Raft consensus port | `8100` |
| `ports.api` | API port | `8200` |
| `ports.metrics` | Metrics port | `9100` |

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

### Pod Disruption Budget Parameters

| Name | Description | Value |
|------|-------------|-------|
| `podDisruptionBudget.enabled` | Enable PodDisruptionBudget | `false` |
| `podDisruptionBudget.minAvailable` | Minimum available pods | `2` |

### Configuration Parameters

| Name | Description | Value |
|------|-------------|-------|
| `externalSecret` | Name of existing secret containing Rauthy configuration | `""` |

## Examples

### Single Instance Deployment

```yaml
replicaCount: 1

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
  storageClassName: longhorn
```

### High Availability Deployment

```yaml
replicaCount: 3

podDisruptionBudget:
  enabled: true
  minAvailable: 2

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
  storageClassName: longhorn

affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - rauthy
        topologyKey: kubernetes.io/hostname
```

## Persistence

The chart mounts a persistent volume at `/app/data` for storing Rauthy's database and configuration.

By default, the chart uses an `emptyDir` volume when persistence is disabled.

## Features

- Automated starter secret generation for getting familiar with rauthy
- Highly available clustered setup support
- Configurable via external secrets
- Pod disruption budget for high availability

## Known Issues

- Cluster setup may take some time during initial deployment
- HTTPRoute configuration is experimental and not fully tested
- Chart notes are minimal (improvement planned)

## License

Like rauthy this helm chart is licensed under the Apache License 2.0.