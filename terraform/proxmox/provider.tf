provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true

  ssh {
    agent    = true
    username = "root"

    node {
      name    = "pve"
      address = "2.26.162.232"
      port    = 48022
    }
  }
}
