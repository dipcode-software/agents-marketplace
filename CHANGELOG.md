# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- `rt-triage` skill for triaging RT support tickets against a codebase

## [0.4.0] - 2026-03-21

### Fixed
- Add explicit skills path to Cursor plugin manifest for skill discovery

## [0.3.0] - 2026-03-20

### Added
- Branch protection for commit skill — prevents commits to protected branches (dev, main, master, release/*) by creating a working branch first
- Issue key resolution in commit skill from branch name

## [0.2.0] - 2026-03-19

### Added
- `validate-dependency` skill for auditing third-party packages before adoption (license, security, maintenance)

## [0.1.1] - 2026-03-18

### Changed
- Update installation URLs to use GitHub remote
- Add MIT license and update README with correct Cursor instructions and prerequisites

## [0.1.0] - 2026-03-17

### Added
- Initial release of the agents marketplace with the `devkit` plugin
- `commit` skill with Conventional Commits enforcement
- `gitlab-mr-comments` skill for fetching merge request feedback
