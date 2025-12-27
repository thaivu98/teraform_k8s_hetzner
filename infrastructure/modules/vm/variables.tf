variable "name" {}
variable "count" { type = number }
variable "server_type" {}
variable "image" { default = "ubuntu-22.04" }
variable "location" { default = "fsn1" }

variable "env" {}
variable "cluster" {}
variable "role" {}        # control-plane | worker
variable "nodegroup" {}   # cp | ai | website
variable "workload" {}    # ai | web | batch

variable "network_id" {}
variable "firewall_ids" {
  type = list(string)
}

variable "enable_public_ip" {
  type    = bool
  default = false
}

# 👉 SSH key bằng TÊN
variable "ssh_key_names" {
  type = list(string)
}
