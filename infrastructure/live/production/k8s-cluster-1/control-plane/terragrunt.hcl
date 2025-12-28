terraform {
  source = "../../../../../modules/vm"
}

include {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  name            = "k8s-cp"
  cluster         = "k8s-cluster-1"
  env             = "prod"
  role            = "control-plane"
  nodegroup       = "control-plane"
  count           = 3
  # Adjust as needed
  server_type     = "cx31"
  image           = "ubuntu-22.04"
  location        = "fsn1"
  ssh_key_names   = ["thaivd"] 
  enable_public_ip = true
  
  network_id      = dependency.network.outputs.network_id
  firewall_ids    = [] # Add if needed
}
