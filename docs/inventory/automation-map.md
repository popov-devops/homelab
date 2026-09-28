# Automation Map

| Current component | Terraform/OpenTofu | Ansible | Docker Compose | Manual / data |
|---|---:|---:|---:|---:|
| Proxmox VM 100 | yes | inside guest | no | no |
| Proxmox VM 101 | yes | inside guest | no | no |
| Proxmox LXC | yes | yes | maybe | no |
| Linux users / SSH | no | yes | no | no |
| Packages | no | yes | no | no |
| Docker Engine | no | yes | no | no |
| Docker containers | no | no | yes | no |
| Application volumes | no | no | yes | data |
| Monitoring agents | no | yes | no | no |
| Application configuration | no | templates | yes | no |
| Secrets | no | Vault/SOPS later | Compose secrets/env | external secret source |
| Proxmox storage hardware | partial | no | no | yes |
| Physical server / BIOS / firmware | no | no | no | yes |
| Backup data | no | no | no | yes |
| Router physical configuration | no* | possibly | no | yes |

\* MikroTik automation can be added later, but it should not block the initial DevOps path.

## First implementation target

Do not start with the entire infrastructure.

Start with **one disposable VM**:

```text
Terraform/OpenTofu
        |
        v
Proxmox VM
        |
        v
Ansible
        |
        v
Ubuntu/Debian baseline
        |
        v
Docker Engine
        |
        v
one simple Compose application
```

Once this works end-to-end, migrate existing hosts/services incrementally.
