# Current DevOps Architecture

This document describes the infrastructure currently managed by the DevOps project.

## End-to-end architecture

```text
                         Git / GitHub
                              |
                              v
                         Terraform
                              |
                              v
                         Proxmox VE
                              |
                    +---------+---------+
                    |                   |
              VM lifecycle        VM resources
                    |                   |
                    +---------+---------+
                              |
                              v
                         cloud-init
                              |
                  +-----------+-----------+
                  |                       |
             Linux user               SSH key
                  |
                  v
              Ansible
                  |
        +---------+----------+
        |                    |
       base                docker
        |                    |
        |              Docker Engine
        |                    |
        +---------+----------+
                  |
                demo
                  |
                  v
            Docker Compose
              /       \
             v         v
          Caddy      whoami
             |
             v
         HTTP :8080
```

## Proxmox environment

The current training environment runs on a Proxmox VE host.

The DevOps VM is:

| Property       | Value                     |
| -------------- | ------------------------- |
| Name           | `devops-01`               |
| VM ID          | `110`                     |
| OS             | Ubuntu Server 24.04.5 LTS |
| CPU            | 2 vCPU                    |
| RAM            | 2 GiB                     |
| Disk           | 20 GiB                    |
| Network bridge | `vmbr0`                   |
| Addressing     | DHCP                      |
| Guest Agent    | QEMU Guest Agent          |

The VM is intentionally disposable.

The goal is to verify that the environment can be recreated from source-controlled configuration rather than preserving a manually configured server.

## Terraform layer

Terraform manages the Proxmox VM.

Current responsibilities:

```text
VM
├── identity
├── CPU
├── memory
├── storage
├── network
├── cloud-init configuration
└── lifecycle
```

Terraform does not configure Docker or application services.

## cloud-init layer

cloud-init performs first-boot initialization.

Current responsibilities:

```text
cloud-init
├── create devops user
├── configure sudo
├── install SSH public key
└── enable QEMU Guest Agent
```

## Ansible layer

Ansible is responsible for host configuration.

The current playbook:

```text
ansible/playbooks/site.yml
        |
        +-- base
        |
        +-- docker
        |
        +-- demo
```

### Base role

Configures:

* hostname;
* common packages;
* QEMU Guest Agent.

### Docker role

Configures:

* Docker repository;
* Docker Engine;
* Docker CLI;
* containerd;
* Buildx;
* Docker Compose plugin;
* `devops` membership in the `docker` group.

### Demo role

Deploys:

```text
/opt/apps/demo/
├── compose.yaml
└── Caddyfile
```

and starts the Compose application.

## Application layer

The demo application contains two services:

```text
Caddy
  |
  | reverse_proxy
  v
whoami
```

Caddy exposes port `8080` on the host.

The application is intentionally simple. Its purpose is to validate the deployment pipeline rather than provide production functionality.

## Reproducibility test

The current implementation has been tested by removing the application environment and allowing Ansible to recreate it.

Successful reconstruction confirms the following chain:

```text
source-controlled configuration
            |
            v
          Ansible
            |
            v
      Docker environment
            |
            v
      Compose application
            |
            v
       HTTP response
```

## Target architecture

The project will gradually evolve toward:

```text
Git
 |
 +--> Terraform
 |      |
 |      v
 |   Proxmox
 |      |
 |      v
 |    VMs
 |
 +--> Ansible
 |      |
 |      v
 |   Linux hosts
 |      |
 |      v
 |   Docker
 |      |
 |      v
 | Applications
 |
 +--> CI/CD
 |
 +--> Monitoring
 |
 +--> Backup / DR
```

These future layers are intentionally not represented as implemented components until they are actually deployed and tested.

## Architecture principle

The system is divided into independent automation layers:

```text
Infrastructure
    Terraform

First boot
    cloud-init

Operating system
    Ansible

Application runtime
    Docker Compose

Delivery
    GitHub Actions
```

The boundary between these layers should remain explicit so that each component can be replaced or tested independently.
