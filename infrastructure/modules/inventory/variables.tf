variable "output_path" {
  description = "Path to write the generated inventory file"
  type        = string
}

variable "control_planes" {
  description = "Map of control plane nodes"
  type        = any
  default     = {}
}

variable "workers" {
  description = "Map of default worker nodes (legacy support)"
  type        = any
  default     = {}
}

variable "node_groups" {
  description = "Map of additional node groups with their hosts and configuration (labels, taints)"
  type = map(object({
    hosts = map(object({
      ip = string
    }))
    labels = map(string)
    taints = list(string)
  }))
  default = {}
}
