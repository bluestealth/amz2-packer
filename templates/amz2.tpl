#cloud-config
growpart:
  mode: auto
disable_root: true
ssh_pwauth: no
packages:
  - amazon-linux-extras
  - docker
package_upgrade: true
package_reboot_if_required: true
timezone: "UTC"
ssh_authorized_keys:
  - ${public_key}
bootcmd:
  - [ "mkdir", "-p", "/var/log/journal" ]
users:
  - default
runcmd:
  - ["amazon-linux-extras", "install", "-y", "kernel-ng"]
  - ["yum", "erase", "-y", "amazon-ssm-agent"]