terraform {
  source = "../../../../../modules/inventory"
}

include {
  path = find_in_parent_folders()
}

dependency "cp" {
  config_path = "../control-plane"
}

dependency "worker_2" {
  config_path = "../worker-2"
}

dependency "worker_1" {
  config_path = "../worker-1"
}

inputs = {
  control_planes = dependency.cp.outputs.nodes
  
  node_groups = {
    worker_2_group = {
      hosts  = dependency.worker_2.outputs.nodes
      labels = { 
        "role" = "gpu"
        "accelerator" = "nvidia" 
      }
      taints = [ "dedicated=gpu:NoSchedule" ]
    }
    worker_1_group = {
      hosts  = dependency.worker_1.outputs.nodes
      labels = { "role" = "worker" }
      taints = []
    }
  }
  
  output_path = "../../../../../kubespray/inventory/prod/k8s-cluster-1/inventory.ini"
}
