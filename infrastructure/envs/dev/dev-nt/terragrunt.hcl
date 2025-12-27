remote_state {
  backend = "s3"
  config = {
    bucket         = "tf-state-dev"
    key            = "cluster-dev/${path_relative_to_include()}.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "hcloud" {
  token = var.hcloud_token
}
EOF
}

inputs = {
  cluster_name = "cluster-dev"
  env          = "dev"
}
