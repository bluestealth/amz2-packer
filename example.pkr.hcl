variable "version" {
  type        = string
  description = "release of amazon linux to use"
  default     = "2.0.20210427.0"
}

variable "iso_dir" {
  type        = string
  description = "disk location to use for images"
  default     = "./iso"
}

variable "format" {
  type        = string
  description = "output format"
  default     = "qcow2"
  validation {
    condition     = contains(["raw", "qcow2"], var.format)
    error_message = "The image format is not valid, must be raw or qcow2."
  }
}

variable "headless" {
  type        = bool
  description = "output display"
  default     = true
}

locals {
  http_root       = "${path.root}/http_root"
  private_ssh_key = "${path.root}/bootstrap.key"
  iteration       = formatdate("YYYYMMDDhhmmss", timestamp())
}

source "qemu" "example" {
  vm_name              = "{{build_name}}.${var.format}"
  ssh_username         = "ec2-user"
  iso_urls             = ["${var.iso_dir}/amzn2-kvm-${var.version}-x86_64.xfs.gpt.qcow2", "https://cdn.amazonlinux.com/os-images/${var.version}/kvm/amzn2-kvm-${var.version}-x86_64.xfs.gpt.qcow2"]
  iso_checksum         = "file:https://cdn.amazonlinux.com/os-images/${var.version}/kvm/SHA256SUMS"
  format               = "${var.format}"
  disk_image           = true
  http_directory       = local.http_root
  communicator         = "ssh"
  firmware_type        = "bios"
  machine_type         = "q35"
  accelerator          = "kvm"
  seed_from            = "http://{{ .HTTPIP }}:{{ .HTTPPort }}/instance-metadata/"
  net_device           = "virtio-net"
  disk_interface       = "virtio"
  ssh_private_key_file = local.private_ssh_key
  output_directory     = "builds/{{build_name}}/${local.iteration}"
  headless             = var.headless
}

build {
  sources = ["source.qemu.example"]
  post-processor "manifest" {
    output = "manifest.json"
  }
  post-processor "shell-local" {
    scripts = ["${path.root}/scripts/local.py"]
  }
}
