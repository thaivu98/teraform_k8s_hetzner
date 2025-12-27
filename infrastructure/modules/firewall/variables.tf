variable "name" {}
variable "private_cidr" {}
variable "vpn_cidr" {
  type = list(string)
}
