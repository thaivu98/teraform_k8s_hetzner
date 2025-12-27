resource "local_file" "inventory" {
  filename = var.output_path
  content = templatefile("${path.module}/templates/inventory.ini.tmpl", {
    cps     = var.control_planes
    workers = var.workers
  })
}
