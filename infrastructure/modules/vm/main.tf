resource "hcloud_server" "this" {
  count       = var.count
  name        = "${var.name}-${count.index + 1}"
  server_type = var.server_type
  image       = var.image
  location    = var.location

  # 👉 SSH KEY DÙNG TÊN
  ssh_keys = var.ssh_key_names

  # 👉 PUBLIC IP (EGRESS ONLY)
  public_net {
    ipv4_enabled = var.enable_public_ip
    ipv6_enabled = false
  }

  network {
    network_id = var.network_id
  }

  firewall_ids = var.firewall_ids

  labels = {
    env       = var.env
    cluster   = var.cluster
    role      = var.role
    nodegroup = var.nodegroup
    workload  = var.workload
  }
}
