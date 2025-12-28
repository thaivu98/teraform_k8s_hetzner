terraform {
  source = "../../../../../modules/inventory"
}

include {
  path = find_in_parent_folders()
}

dependency "cp" {
  config_path = "../control-plane"
}

dependency "worker_1" {
  config_path = "../worker-1"
}

dependency "worker_2" {
  config_path = "../worker-2"
}

inputs = {
  control_planes = dependency.cp.outputs.nodes
  
  node_groups = {
    worker_1_group = {
      hosts  = dependency.worker_1.outputs.nodes
      labels = { "role" = "worker", "group" = "1" }
      taints = []
    }
    worker_2_group = {
      hosts  = dependency.worker_2.outputs.nodes
      labels = { "role" = "worker", "group" = "2" }
      taints = []
    }
  }
  
  output_path = "../../../../../kubespray/inventory/staging/website-staging/inventory.ini"
}
