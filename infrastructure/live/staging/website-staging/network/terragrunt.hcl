terraform {
  source = "../../../../../modules/network"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name = "website-staging-net"
  cidr = "10.0.0.0/16"
}
