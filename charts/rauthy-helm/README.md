# Rauthy Helm Chart
[Rauthy](https://github.com/sebadob/rauthy) is an OpenID Connect (OIDC) Provider and Single Sign-On (SSO) solution written in Rust. It provides a secure, fast, and reliable authentication service for your applications.

This helm chart aims to make your deployment and maintenance of rauthy easier in a kubernetes environment.

## Prerequisites
- Kubernetes 1.19+
- Helm 3.2.0+
- Persistent volume provisioner support in the underlying infrastructure

## Features
- Automated starter secret generation based on the [minimal production configuration](https://sebadob.github.io/rauthy/config/config_minimal.html) for getting familiar with rauthy,
- Bring Your Own configuration via external secret,
- Highly available, clustered setup by default,
- External access via Ingress / httpRoute,
- Metrics and serviceMonitor support.

## Installation
```bash
helm upgrade --install rauthy oci://ghcr.io/reversing0148/rauthy-helm --version 1.0.3 -n rauthy --create-namespace
```

## Upgrading
Please check the [Generating rauthy configuration](#generating-rauthy-configuration) section before upgrading to avoid data loss!
```bash
helm upgrade --install rauthy oci://ghcr.io/reversing0148/rauthy-helm --version 1.0.3 -n rauthy
```

## Uninstallation
```bash
helm uninstall rauthy
```

## Parameters

### Global Parameters
| Name | Description | Value |
|------|-------------|-------|
| `nameOverride` | Override the chart name | `rauthy` |
| `fullnameOverride` | Override the chart name | `` |
| `replicaCount` | Number of Rauthy replicas | `3` |

### Image Parameters
| Name | Description | Value |
|------|-------------|-------|
| `image.repository` | Rauthy image repository | `ghcr.io/sebadob/rauthy` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.tag` | Image tag (overrides the chart appVersion) | `` |
| `imagePullSecrets` | Docker registry secret names | `[]` |

### Statefulset Update Strategy
| Name | Description | Value |
|------|-------------|-------|
| `updateStrategy.type` | Update strategy of the statefulset | `RollingUpdate` |
| `updateStrategy.rollingUpdate.partition` | Define partitions of the rolling update | `0` |

### Pod Labels and Annotations
| Name | Description | Value |
|------|-------------|-------|
| `podAnnotations` | Additional annotations for the pod definition | `{}` |
| `podLabels` | Additional labels for the pod definition | `{}` |


### Service Parameters
| Name | Description | Value |
|------|-------------|-------|
| `service.annotations` | Annotations for the service| `{}` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Rauthy port exposed by the service | `8080` |
| `service.scheme` | Rauthy http and api scheme | `http` |

### Hiqlite Parameters
This is for configuring a headless service for hiqlite.

| Name | Description | Value |
|------|-------------|-------|
| `hiqlite.ports.raft` | Raft port used by Rauthy | `8100` |
| `hiqlite.ports.api` | Api port used by Rauthy | `8200` |

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

### Resource Parameters
| Name | Description | Value |
|------|-------------|-------|
| `resources.requests.cpu` | CPU request of the container | `medium` |
| `resources.requests.memory` | Memory request of the container | `""` |

Setting limits is possible but not recommended. For more details read the comments in  `values.yaml`.

### Memory Allocator Parameters
| Name | Description | Value |
|------|-------------|-------|
| `malloc.preset` | Jemalloc preset (small/medium/big/open/custom) | `medium` |
| `malloc.custom` | Custom malloc configuration when preset is "custom" | `""` |

### Probe configuration
#### Liveness probe
| Name | Description | Value |
|------|-------------|-------|
| `livenessProbe.httpGet.path` | Path for the liveness probe request | `/auth/v1/health` |
| `livenessProbe.httpGet.port` | Port for the liveness probe request | `http` |
| `livenessProbe.initialDelaySeconds` | Seconds to wait before the first liveness probe request is sent | `60` |
| `livenessProbe.periodSeconds` | How often should kubelet check liveness | `30` |
| `livenessProbe.failureThreshold` | How many failed attempts before terminating the pod | `2` |

#### Readiness probe
| Name | Description | Value |
|------|-------------|-------|
| `readinessProbe.httpGet.path` | Path for the readiness probe request | `/ready` |
| `readinessProbe.httpGet.port` | Port for the readiness probe request | `hiqlite-api` |
| `readinessProbe.initialDelaySeconds` | Seconds to wait before the first readiness probe request is sent | `5` |
| `readinessProbe.periodSeconds` | How often should kubelet check readiness | `3` |
| `readinessProbe.failureThreshold` | How many failed attempts before terminating the pod | `2` |

### Volume configuration
| Name | Description | Value |
|------|-------------|-------|
| `volumes` | Additional volumes on the output StatefulSet definition | `[]` |
| `volumeMounts` | Additional volumeMounts on the output StatefulSet definition | `[]` |

### Scheduler fine tuning
| Name | Description | Value |
|------|-------------|-------|
| `nodeSelector` | Node selector for the statefulset definition | `{}` |
| `tolerations` | Tolerations for the statefulset definition | `[]` |
| `affinity` | Affinity rules for the statefulset definition | `{}` |
| `topologySpreadConstraints` | Topology spread constraints for the statefulset definition | `[]` |

### Persistence Parameters
| Name | Description | Value |
|------|-------------|-------|
| `persistence.enabled` | Enable persistent volume claims | `false` |
| `persistence.size` | Persistent Volume size | `256Mi` |
| `persistence.accessMode` | Persistent Volume access mode | `ReadWriteOnce` |
| `persistence.storageClassName` | Persistent Volume storage class | `` |

### Service monitor configuration
| Name | Description | Value |
|------|-------------|-------|
| `serviceMonitor.enabled` | Enable or disable the ServiceMonitor resource | `false` |
| `serviceMonitor.namespaceOverride` | Namespace override for the ServiceMonitor resource | `""` |
| `serviceMonitor.port` | The port exposed by the service to scrape metrics from | `metrics` |
| `serviceMonitor.interval` | The interval at which Prometheus will scrape metrics | `30s` |

### External secret
| Name | Description | Value |
|------|-------------|-------|
| `externalSecret` | Name of the secret with your existing configuration. | `""` |

Either externalSecret or [config](#configuration-parameters) can be used but not both.

### Configuration Parameters
| Name | Description | Value |
|------|-------------|-------|
| `config.generate` | Enable automatic config.toml generation | `true` |
| `config.keep` | Annotate the generated secret, to ensure helm does not remove it during uninstall | `true` |
| `config.trustedProxies` | List of trusted proxy CIDR ranges | `[]` |

Either [externalSecret](#external-secret) or config can be used but not both.

### Environent variable configuration
| Name | Description | Value |
|------|-------------|-------|
| `env` | List of key value pairs. These will be applied as environment variables. | `{}` |

## Generating rauthy configuration
The chart allows you to deploy rauthy by generating a configuration for you based on the [minimal production configuration](https://sebadob.github.io/rauthy/config/config_minimal.html).

To use this feature keep the externalSecret empty.

> ⚠️ Important! The configuration is re-genreated and applied on each upgrade! Make sure to migrate to `externalSecret` after your first install and before an upgrade to avoid data loss!

Migration steps:
- Install the helm chart with `config.generate` `true`
- Modify your `values.yaml` as such: 
  ```yaml
  config:
    generate: false
  ```
  ```yaml
  externalSecret: "rauthy-config"
  ```
  Make sure to use your secret's name!

- You can now safely upgrade

## Bring your own secret
The chart supports configuring rauthy via your own secret.

You can do this by creating a secret in the same namespace as rauthy, then providing the secret name, in the [externalSecret](#external-secret) field. For example:
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
Rauthy is deployed as a statefulset, therefore the use of some form of persistent volume is inevitable.

### Storage
The chart mounts a persistent volume at `/app/data` for storing Rauthy's internal [hiqlite](https://github.com/sebadob/hiqlite) database and configuration.

By default, the chart uses an `emptyDir` volume when persistence is disabled.

### Hiqlite
Currently this helm chart only supports deploying rauthy with its internal [hiqlite](https://github.com/sebadob/hiqlite) database.

### Postgresql
External postgresql database support via the helm chart is planned but is not yet available.

## HTTPRoute considerations
- When `existingSecret` is not set, and `HTTPRoute` is enabled the templates assume you have tls configured on the gateway when generating the secret template.

## License
Like rauthy this helm chart is licensed under the Apache License 2.0.