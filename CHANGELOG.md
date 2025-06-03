# Changelog

All notable changes to this Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-06-04

### Added
- Initial release of Rauthy Helm chart
- StatefulSet deployment for Rauthy authentication server
- Service configuration with configurable ports
- Ingress support with TLS configuration
- ServiceAccount with configurable RBAC
- ServiceMonitor for Prometheus integration
- Persistent volume claims for data storage
- Comprehensive values.yaml with sensible defaults
- Example configurations for standalone and HA deployments
- Connection tests for chart validation

### Features
- Support for Rauthy v0.29.4
- Configurable resource limits and requests
- Pod security context configuration
- Environment variable management
- Custom labels and annotations support
- Readiness and liveness probes
- Multi-replica support for high availability
