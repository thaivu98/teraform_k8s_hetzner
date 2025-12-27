terraform {
  source = "../../../../modules/inventory"
}

dependency "cp" {
  config_path = "../control-plane"
}

dependency "worker" {
  config_path = "../worker"
}

inputs = {
  control_planes = dependency.cp.outputs.nodes
  workers        = dependency.worker.outputs.nodes
  output_path    = "../../../../kubespray/inventory/dev/cluster-dev/inventory.ini"
}
