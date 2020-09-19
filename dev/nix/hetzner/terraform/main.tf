terraform {
  backend "local" {
    path = "../../../../docs/terraform-state/hetzner.tfstate"
  }
}

provider "hcloud" {}

resource "hcloud_server" "ai-banana" {
  name        = "ai-banana"
  image       = "ubuntu-20.04"
  server_type = "cx11"
  location    = "nbg1"
  ssh_keys    = [hcloud_ssh_key.jasper.id]
  backups     = false
  user_data   = <<-EOT
    #!/bin/sh
    curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | PROVIDER=hetznercloud NIX_CHANNEL=nixos-20.03 bash 2>&1 | tee /tmp/infect.log
    EOT
}

resource "hcloud_volume" "volume1" {
  name     = "volume1"
  size     = 80
  location = "nbg1"
  format   = "ext4"
}

resource "hcloud_volume_attachment" "volume1" {
  volume_id = hcloud_volume.volume1.id
  server_id = hcloud_server.ai-banana.id
  automount = false
}

resource "hcloud_ssh_key" "jasper" {
  name       = "Jaspers key"
  public_key = file("~/.ssh/id_rsa.pub")
}
