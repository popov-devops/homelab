# Automation Map

This document describes the ownership boundaries between the automation layers used by the project.

## Current implementation

| Component                   | Terraform | cloud-init | Ansible | Docker Compose | Manual / external |
| --------------------------- | --------: | ---------: | ------: | -------------: | ----------------: |
| Proxmox VM `devops-01`      |       yes |          — |       — |              — |                no |
| VM CPU / RAM / disk         |       yes |          — |       — |              — |                no |
| VM network interface        |       yes |          — |       — |              — |                no |
| Initial Linux user          |         — |        yes |       — |              — |                no |
| SSH public key              |         — |        yes |       — |              — |                no |
| QEMU Guest Agent bootstrap  |         — |        yes |     yes |              — |                no |
| Linux packages              |         — |          — |     yes |              — |                no |
| Docker Engine               |         — |          — |     yes |              — |                no |
| Docker Compose plugin       |         — |          — |     yes |              — |                no |
| Demo application directory  |         — |          — |     yes |              — |                no |
| Application configuration   |         — |          — |     yes |            yes |                no |
| Docker containers           |         — |          — |       — |            yes |                no |
| Docker network              |         — |          — |       — |            yes |                no |
| Application startup         |         — |          — |     yes |            yes |                no |
| Persistent application data |         — |          — |       — |            yes |          external |
| Terraform state             |       yes |          — |       — |              — |       local state |
| Secrets                     |         — |          — | planned |        planned |          external |

## Ownership model

### Terraform

Terraform owns infrastructure resources that are part of the Proxmox environment.

Current scope:

```text
Proxmox
└── VM
    ├── CPU
    ├── RAM
    ├── disk
    ├── network
    └── lifecycle
```

Terraform does not own:

* application data;
* Docker containers;
* application configuration;
* secrets.

### cloud-init

cloud-init owns the first bootstrapping stage of the operating system.

Current scope:

```text
VM
 |
 +-- devops user
 +-- SSH public key
 +-- sudo configuration
 +-- QEMU Guest Agent
```

cloud-init is not used as the main configuration-management system.

### Ansible

Ansible owns operating-system configuration and host-level software.

Current scope:

```text
Linux host
 |
 +-- packages
 +-- hostname
 +-- QEMU Guest Agent
 +-- Docker repository
 +-- Docker Engine
 +-- Docker Compose plugin
 +-- application deployment
```

### Docker Compose

Docker Compose owns the runtime definition of the demo application:

```text
demo
 |
 +-- caddy
 |
 +-- whoami
 |
 +-- network
```

## Planned CI/CD ownership

GitHub Actions will eventually validate repository changes before they are merged or deployed.

Target flow:

```text
Git push
   |
   +--> Terraform fmt / validate
   |
   +--> Ansible syntax / lint
   |
   +--> configuration validation
   |
   v
 deployment workflow
```

The CI/CD layer is not yet implemented.

## Physical infrastructure

Physical infrastructure remains outside the current IaC scope:

* Proxmox physical host;
* physical disks;
* network switches;
* MikroTik router;
* UPS;
* storage hardware;
* BIOS / firmware.

These components are documented rather than provisioned by Terraform.

## Design principle

Each layer should have one primary responsibility:

```text
Terraform
    → infrastructure

cloud-init
    → first boot

Ansible
    → operating system

Docker Compose
    → application runtime

GitHub Actions
    → validation and delivery
```

Cross-layer configuration should be introduced only when there is a clear operational reason.

