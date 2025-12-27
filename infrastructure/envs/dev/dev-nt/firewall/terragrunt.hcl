include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/firewall"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  name         = "dev-nt-firewall"
  private_cidr = "10.10.0.0/16"
  vpn_cidr     = ["10.99.0.0/24"]
}
