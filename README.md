# Homelab DevOps / IaC

Infrastructure-as-Code and DevOps laboratory built on a real Proxmox-based homelab.

The project is designed as a reproducible environment for practicing and demonstrating:

* Terraform
* cloud-init
* Ansible
* Docker
* Docker Compose
* Git / GitHub
* CI/CD
* observability
* backup and disaster recovery

The infrastructure is intentionally built incrementally. Each layer has a clearly defined responsibility.

## Architecture

```text
                         Git
                          |
                          v
                     Terraform
                          |
                          v
                    Proxmox VE
                          |
                    VM lifecycle
                          |
                          v
                    cloud-init
                          |
                 OS bootstrap / SSH
                          |
                          v
                      Ansible
                          |
              OS configuration / Docker
                          |
                          v
                  Docker Compose
                          |
                          v
                    Applications
```

### Responsibility boundaries

| Layer          | Responsibility                                                          |
| -------------- | ----------------------------------------------------------------------- |
| Terraform      | Proxmox VM lifecycle and infrastructure resources                       |
| cloud-init     | Initial OS bootstrap, user, SSH key, QEMU Guest Agent                   |
| Ansible        | Linux configuration, packages, Docker Engine and application deployment |
| Docker Compose | Application containers, networks and runtime configuration              |
| Git            | Version control and change history                                      |
| GitHub Actions | CI/CD — planned                                                         |

Physical servers, network hardware and storage hardware remain outside Terraform and are documented as infrastructure inventory.

## Current implementation

The current end-to-end path is:

```text
Terraform
    |
    +--> Proxmox VM: devops-01
              |
              v
         cloud-init
              |
              v
           Ansible
              |
       +------+------+
       |             |
    base role    docker role
                     |
                     v
                Docker Engine
                     |
                     v
                  demo role
                     |
                     v
               Docker Compose
                 /        \
              Caddy      whoami
```

The current disposable training VM is:

| Property    | Value                     |
| ----------- | ------------------------- |
| Name        | `devops-01`               |
| VM ID       | `110`                     |
| OS          | Ubuntu Server 24.04.5 LTS |
| CPU         | 2 vCPU                    |
| RAM         | 2 GiB                     |
| Disk        | 20 GiB                    |
| Network     | `vmbr0`                   |
| Addressing  | DHCP                      |
| Guest Agent | QEMU Guest Agent          |

## Repository structure

```text
.
├── ansible.cfg
├── ansible/
│   ├── inventory/
│   │   └── hosts.yml
│   ├── playbooks/
│   │   └── site.yml
│   ├── requirements.yml
│   └── roles/
│       ├── base/
│       ├── docker/
│       └── demo/
│
├── apps/
│   └── demo/
│       ├── compose.yaml
│       └── Caddyfile
│
├── docs/
│   └── inventory/
│       ├── architecture.md
│       ├── automation-map.md
│       └── inventory.md
│
└── terraform/
    └── proxmox/
        ├── cloud-init.yaml
        ├── main.tf
        ├── outputs.tf
        ├── provider.tf
        ├── variables.tf
        └── versions.tf
```

## Deployment flow

### 1. Terraform

Terraform provisions the Proxmox VM and its infrastructure parameters:

* VM ID and name
* CPU
* memory
* disk
* network interface
* cloud-init configuration
* QEMU Guest Agent

The Terraform state is local and is intentionally excluded from Git.

### 2. cloud-init

cloud-init performs the initial VM bootstrap:

* creates the `devops` user;
* installs the SSH public key;
* configures sudo access;
* installs QEMU Guest Agent;
* enables the guest agent.

### 3. Ansible

Ansible configures the operating system.

The current playbook applies three roles:

```text
base
  ├── packages
  ├── hostname
  └── qemu-guest-agent

docker
  ├── Docker repository
  ├── Docker Engine
  ├── Docker Compose plugin
  └── docker group

demo
  ├── application directory
  ├── Compose configuration
  ├── Caddy configuration
  └── application startup
```

The playbook is expected to be idempotent: running it repeatedly should converge the host without unnecessary changes.

### 4. Docker Compose

The demo application consists of:

```text
Caddy
  |
  v
whoami
```

Caddy listens on port `8080` of the VM and reverse-proxies requests to the `whoami` container.

The application is deployed by Ansible using the `community.docker` collection.

## Reproducibility

The current implementation has been tested by rebuilding the application environment from scratch.

The validation sequence included:

```text
Terraform-managed VM
        |
        v
cloud-init bootstrap
        |
        v
Ansible configuration
        |
        v
Docker Engine
        |
        v
Docker Compose
        |
        v
Caddy + whoami
```

The demo application was successfully recreated after removing its application directory and Docker containers.

## Development principles

### Infrastructure should be reproducible

If a component can be recreated from code, it should eventually be represented as code.

### Separate responsibilities

Terraform should not configure applications.

Ansible should not create Proxmox infrastructure.

Docker Compose should not configure the underlying Linux host.

### Prefer incremental automation

The project starts with one disposable VM rather than attempting to automate the entire homelab immediately.

### Test destructive scenarios

A successful `apply` is not sufficient validation.

The project should eventually include controlled:

* rebuild tests;
* backup restoration;
* disaster recovery tests;
* migration tests.

## Roadmap

### Implemented

* [x] Git repository
* [x] Terraform
* [x] Proxmox VM provisioning
* [x] cloud-init bootstrap
* [x] Ansible inventory
* [x] Ansible base role
* [x] Ansible Docker role
* [x] Docker Engine
* [x] Docker Compose
* [x] Demo application
* [x] Idempotency testing
* [x] Application rebuild testing

### Planned

* [ ] Terraform validation / formatting in CI
* [ ] Ansible linting and syntax validation
* [ ] GitHub Actions
* [ ] Automated deployment workflow
* [ ] Secrets management
* [ ] Monitoring
* [ ] Centralized logging
* [ ] Backup and restore
* [ ] Disaster recovery test
* [ ] Rebuild on independent Proxmox infrastructure

## License

This repository is primarily a personal DevOps / Infrastructure-as-Code laboratory and portfolio project.

## CI/CD

Infrastructure changes are validated through GitHub Actions before merging to `main`.
