variable "template" {
  type        = string
  description = "path to cloud-init templatefile"
  default     = ""
}

locals {
  template = var.template == "" ? "${path.module}/templates/amz2.tpl" : var.template
}

resource "tls_private_key" "ssh_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "local_file" "ssh_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/bootstrap.key"
  file_permission = "0400"
}

data "template_file" "cloudinit" {
  template = file(local.template)
  vars = {
    public_key = tls_private_key.ssh_key.public_key_openssh
  }
}

data "template_cloudinit_config" "cloudinit" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloudinit.rendered
  }
}

resource "local_file" "userdata" {
  content         = data.template_cloudinit_config.cloudinit.rendered
  filename        = "${path.module}/http_root/instance-metadata/user-data"
  file_permission = "0640"
}

resource "local_file" "metadata" {
  content         = yamlencode({})
  filename        = "${path.module}/http_root/instance-metadata/meta-data"
  file_permission = "0640"
}

resource "local_file" "vendordata" {
  content         = yamlencode({})
  filename        = "${path.module}/http_root/instance-metadata/vendor-data"
  file_permission = "0640"
}
