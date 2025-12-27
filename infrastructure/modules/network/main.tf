resource "hcloud_network" "this" {
  name     = var.name
  ip_range = var.cidr
}
