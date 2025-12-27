resource "hcloud_firewall" "this" {
  name = var.name

  # Allow ALL private network traffic
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "any"
    source_ips = [var.private_cidr]
  }

  rule {
    direction  = "in"
    protocol   = "udp"
    port       = "any"
    source_ips = [var.private_cidr]
  }

  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = [var.private_cidr]
  }

  # Allow kube-apiserver from VPN
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "6443"
    source_ips = var.vpn_cidr
  }

  # SSH only from VPN
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = var.vpn_cidr
  }
}
