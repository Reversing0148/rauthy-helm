# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0-beta-3] - 2025-12-28

### Changed
- fix: update chart name in release workflow

## [1.0.0-beta-2] - 2025-12-28

### Changed
- feat: update chart name from rauthy to rauthy-helm

### Added
- feat: Release in OCI format to github packages

## [1.0.0-beta-1] - 2025-12-28

### Added
- feat: add changelog
- feat: add test workflow using helm/chart-testing-action
- fix: fix test connection

### Changed
- chore: update appVersion, add helm keywords
- feat: divert from rauthy version to ensure semver compliance with breaking chart changes

## [0.33.2] - 2025-12-23

### Added
- feat: add changelog
- feat: add test workflow using helm/chart-testing-action
- fix: fix test connection

### Changed
- chore: update appVersion to 0.33.2
- chore!: use more obvious port/service names, set the stage for future postgresql support

    This **BREAKING CHANGE** affects how the hiqlite headless service is referenced in high availability deployment configurations.

    If you run rauthy with 1 replica, or use an external postgresql database you are not affected.

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
