# Vega TV Lab

A small, reproducible runtime check for Amazon's official Vega Virtual Device on an Ubuntu GitHub Actions runner.

The manual workflow installs the official SDK, builds its Hello World template, starts the virtual TV, sends remote-control keyboard input, and records the resulting screen. Logs and recordings are uploaded as a short-lived Actions artifact.

**Status:** first runtime check in progress. Successful build, device boot, visible app, and remote input are separate checks.

## Run

Open **Actions → Official Vega runtime → Run workflow**. The job uses an Ubuntu runner with KVM and a software-rendered X display. SDK `0.24.12112` installation and generated sample files stay in `temp/`; artifacts contain logs and screen recordings.

Choose a published SDK version with `vega sdk list-remote`. The CI documentation example `0.24.9311` returned “Version not found” on October 14, 2026; the registry listed `0.24.12112` as the latest release.

- [Official SDK installation](https://developer.amazon.com/docs/vega/0.24/install-vega-sdk.html)
- [Official CI installation](https://developer.amazon.com/docs/vega/0.24/continuous-integration.html)
- [Official sample build](https://developer.amazon.com/docs/vega/0.24/build-an-app)
- [Virtual-device and remote-control reference](https://developer.amazon.com/docs/vega/0.24/run-apps.html)

Amazon SDK and generated template materials retain their upstream license. This repository contains the runner workflow and runtime-check instructions.
