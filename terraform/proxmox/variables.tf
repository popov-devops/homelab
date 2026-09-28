variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node"
  type        = string
  default     = "pve"
}

variable "vm_id" {
  description = "VM ID"
  type        = number
  default     = 110
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "devops-01"
}
