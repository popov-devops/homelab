# Homelab Current Inventory

Generated from the provided HOME and WORK host snapshots.

## HOME

| Host | OS | CPU | Storage / notable state | IP / gateway | Role |
|---|---|---:|---|---|---|
| archlinux | Arch Linux | 2 vCPU | `/` ext4 108G, ~20% used | 192.168.88.223 / 192.168.88.1 | Docker/media utility host |
| cloud | Ubuntu 24.04.4 LTS | 2 vCPU | `/` 56G, `/mnt/data` 1.8T, ~98% used | 192.168.88.246 / 192.168.88.1 | Gitea + Grafana |
| orangepizero3 | Armbian 26.2.0-trunk / Ubuntu 24.04 | 4 cores | 29G root, ~79% used | 192.168.88.197 / 192.168.88.1 | Small ARM utility / infrastructure host |
| nezha | Ubuntu 22.04.5 LTS | 1 vCPU | 28G root | DHCP / 192.168.88.1 | Nezha / monitoring utility |
| omarchy | Omarchy | 8 vCPU | Btrfs 237G, ~9% used | 192.168.10.169 / 192.168.10.1 | Admin workstation |

### HOME Docker services

**archlinux**
- qbittorrent

**cloud**
- gitea
- grafana

Other HOME hosts did not show active Docker containers in the snapshots.

## WORK / LAB

| Host | OS | CPU | Storage / notable state | IP / gateway | Role |
|---|---|---:|---|---|---|
| pve-work | Proxmox VE / Debian 13 | 4 vCPU | local-lvm ~94.7%; lvm2 ~96.6%; lvm3 ~98.8%; lvm4 ~99.8% | 192.168.1.191 / 192.168.1.1 | Proxmox host |
| omv | Debian 13 | 4 vCPU | 30G root + 787G + 885G + 1.8T data disks | 192.168.1.196 / 192.168.1.1 | OpenMediaVault storage VM |
| erling | Ubuntu 26.04 LTS | 4 vCPU | root 441G, ~54% used | 192.168.1.162 / 192.168.1.1 | Main Docker application host |
| arch | EndeavourOS | 8 vCPU | NVMe 1.8T, ~82% used | 192.168.1.186 / 192.168.1.1 | Admin / utility workstation |

## Proxmox

### VM 100 — omv
- 2 cores
- 2048 MB RAM
- 32G boot disk on `local-lvm`
- additional 800G disk on `local-lvm`
- additional 900G disk on `lvm2`
- additional 1.86T disk on `lvm4`
- virtio network on `vmbr0`

### VM 101 — erling
- 2 cores
- 8192 MB RAM
- 450G disk on `lvm3`
- virtio network on `vmbr0`

### LXC
- 103 `pdm` — stopped, Debian, 2 cores / 1G RAM / 10G rootfs, 192.168.1.173/24
- 104 `jellyfin` — running, Ubuntu, 2 cores / 2G RAM / 16G rootfs, `/mnt/media` bind mount
- 105 `netbird` — stopped, Debian, 2 cores / 2G RAM / 20G rootfs
- 106 `asterisk` — stopped, Debian, 1 core / 1G RAM / 8G rootfs
- 107 `reticulum-node` — stopped, Debian, 1 core / 512M RAM / 8G rootfs

### Proxmox network

- `vmbr0`
- address `192.168.1.191/24`
- gateway `192.168.1.1`
- bridge port `enp4s0`
- STP disabled

### Proxmox storage

- `local` — directory
- `local-lvm` — LVM-thin
- `lvm2` — LVM
- `lvm3` — LVM
- `lvm4` — LVM
- `pbs-backup` — PBS datastore `backup-pool`, currently inactive in snapshot

**Important operational finding:** several local storage pools are critically full. This must be treated as an infrastructure issue before automated provisioning is introduced.

## WORK Docker services — erling

Application groups visible in snapshot:

- Syncthing
- Immich + PostgreSQL + Valkey + ML
- Vikunja + PostgreSQL + Redis
- Forgejo + PostgreSQL
- Jellyfin
- Nextcloud + MariaDB + Redis
- sing-box
- Transmission
- Dozzle
- Uptime Kuma
- Dockge
- Watchtower
- Stirling PDF
- ERPNext stack
- Zabbix + PostgreSQL
- Prometheus
- Grafana
- cAdvisor
- SNMP exporter
- node-exporter
- blackbox exporter
- Supabase stack
- n8n + PostgreSQL
- Rackula
- MinIO

`watchtower` was restarting at snapshot time and should be investigated separately.
