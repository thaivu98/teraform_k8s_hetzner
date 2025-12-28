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
  name            = "k8s-gpu"
  cluster         = "k8s-cluster-1"
  env             = "prod"
  role            = "worker"
  nodegroup       = "gpu-nodes"
  count           = 1
  
  # Example GPU instance type (although CX31 is not GPU, using as placeholder)
  server_type     = "cx31" 
  image           = "ubuntu-22.04"
  location        = "fsn1"
  ssh_key_names   = ["thaivd"]
  enable_public_ip = true
  
  network_id      = dependency.network.outputs.network_id
  firewall_ids    = []
}
