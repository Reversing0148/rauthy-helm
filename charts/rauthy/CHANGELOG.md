# Changelog

## [0.33.2]

### BREAKING CHANGES
- chore!: use more obvious port/service names, set the stage for future postgresql support

This change affects how the hiqlite headless service is referenced in high availability deployment configurations. 

To avoid downtime, change the `nodes` section of your secret from `-headless` suffix to `-hiqlite-headless` suffix before the!

For example change:
```toml
nodes = [
    "1 rauthy-0.rauthy-headless:8100 rauthy-0.rauthy-headless:8200",
    "2 rauthy-1.rauthy-headless:8100 rauthy-1.rauthy-headless:8200",
    "3 rauthy-2.rauthy-headless:8100 rauthy-2.rauthy-headless:8200",
]
```
to:
```toml
nodes = [
    "1 rauthy-0.rauthy-hiqlite-headless:8100 rauthy-0.rauthy-hiqlite-headless:8200",
    "2 rauthy-1.rauthy-hiqlite-headless:8100 rauthy-1.rauthy-hiqlite-headless:8200",
    "3 rauthy-2.rauthy-hiqlite-headless:8100 rauthy-2.rauthy-hiqlite-headless:8200",
]
```

### Changes
- chore: update appVersion to 0.33.2
- feat: add changelog
