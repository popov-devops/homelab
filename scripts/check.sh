#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Ansible lint"
cd "$ROOT_DIR"
ansible-lint ansible/playbooks/site.yml

echo
echo "==> Terraform format"
cd "$ROOT_DIR/terraform/proxmox"
terraform fmt -check -recursive

echo
echo "==> Terraform validate"
terraform validate

echo
echo "==> Terraform plan"
terraform plan

echo
echo "All checks passed."
