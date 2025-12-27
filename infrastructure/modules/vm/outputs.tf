output "nodes" {
  value = {
    for s in hcloud_server.this :
    s.name => {
      ip   = s.ipv4_address
      role = var.role
    }
  }
}
