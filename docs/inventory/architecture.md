# Current Architecture

## Logical layers

```text
                    Network / Router
                         |
             +-----------+-----------+
             |                       |
         HOME LAN                WORK/LAB LAN
             |                       |
       +-----+------+          +-----+------+
       |            |          |            |
   physical      utility    Proxmox      physical
    hosts         hosts        |           hosts
                              |
                    +---------+---------+
                    |                   |
                  VM 100              VM 101
                    |                   |
                   OMV               erling
                    |                   |
                 storage            Docker
                                        |
                              applications / infra
```

## Desired IaC ownership

### Terraform / OpenTofu

Owns infrastructure resources that can be recreated:

- Proxmox VMs
- Proxmox LXC containers
- VM/LXC CPU and memory
- virtual disks
- virtual network interfaces
- Proxmox storage attachment
- VM/LXC lifecycle

It should **not** own application data or secrets.

### Ansible

Owns operating-system configuration:

- users and SSH
- packages
- system configuration
- filesystem mounts
- firewall
- Docker Engine
- monitoring agents
- systemd units
- host-specific configuration

### Docker Compose

Owns application deployment:

- containers
- images
- networks
- volumes
- application environment
- service dependencies
- application-level configuration

### Git / CI

Owns the delivery workflow:

```text
commit
  |
  +--> format / lint / validate
  |
  +--> Terraform plan
  |
  +--> Ansible lint / syntax check
  |
  +--> approval
  |
  +--> apply / deployment
```

## Rebuild target

The end state of this project should allow:

```text
new Proxmox host
       |
       v
Terraform/OpenTofu
       |
       v
VM/LXC infrastructure
       |
       v
Ansible
       |
       v
configured Linux hosts
       |
       v
Docker Compose
       |
       v
applications
       |
       v
restore persistent data
```

The final validation is a controlled rebuild/restore test, not merely a successful `terraform apply`.
