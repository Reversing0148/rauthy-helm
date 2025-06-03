# Rauthy Helm Chart 🔐

A Helm chart to deploy [Rauthy](https://github.com/sebadob/rauthy) - a blazingly fast and secure OpenID Connect Provider built in Rust.

## Quick Start

### 1. Add the Helm Repository

```bash
helm repo add rauthy https://reversing0148.github.io/rauthy-helm/
```

### 2. Install Rauthy

```bash
# Basic installation
helm install my-auth-server rauthy/rauthy

# With custom values
helm install my-auth-server rauthy/rauthy -f examples/values-standalone.yaml
```

### 3. Access Your SSO Server

```bash
# Port forward to access locally
kubectl port-forward svc/my-auth-server-rauthy 8080:8080

# Open http://localhost:8080 in your browser
```

## Configuration

The chart comes with sensible defaults, but you'll want to customize it for production use. For example:

```yaml
# values.yaml
ingress:
  enabled: true
  hosts:
    - host: auth.example.com
      paths:
        - path: /

persistence:
  size: 1Gi

# Don't forget to set up environment variables for production!
env:
  - name: PUB_URL
    value: "https://auth.example.com"
```

and so on ...

Check out the [examples/](examples/) directory for more configuration samples.

## Requirements

- Kubernetes 1.19+
- Helm 3.2.0+
- Persistent storage support

## Documentation

- 📖 **Rauthy Docs**: https://sebadob.github.io/rauthy/
- ⚙️ **Configuration Guide**: https://sebadob.github.io/rauthy/config/config.html
- 🐳 **Container Images**: https://github.com/sebadob/rauthy/pkgs/container/rauthy

## Contributing

I am clearly a novice at this. Contributions are always welcome! Please check the [original Rauthy project](https://github.com/sebadob/rauthy) for application-specific issues.

## License

This Helm chart is licensed under Apache 2.0. Rauthy itself is licensed under Apache 2.0 as well.
