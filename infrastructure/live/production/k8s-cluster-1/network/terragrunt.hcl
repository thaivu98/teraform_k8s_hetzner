terraform {
  source = "../../../../../modules/network"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name = "k8s-cluster-1-net"
  cidr = "10.0.0.0/16"
}
