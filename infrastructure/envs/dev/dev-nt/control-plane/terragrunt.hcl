terraform {
  source = "../../../../modules/vm"
}

include {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  cluster_name    = "cluster-dev"
  environment     = "staging"
  role            = "control-plane"
  nodegroup       = "control-plane"
  instance_count  = 3
  server_type     = "cx31"
  location        = "fsn1"
  ssh_key_name    = "thaivd"
  network_id      = dependency.network.outputs.network_id
}
