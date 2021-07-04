##############################################################
#                          SSH KEY                           #
##############################################################

### S ###
resource "digitalocean_ssh_key" "http3_yurets_pro" {
  name       = "yurets"
  public_key = file("~/.ssh/id_rsa.pub")
}

##############################################################
#                  Droplet + Floating IP                     #
##############################################################

resource "digitalocean_droplet" "http3_yurets_pro" {
  count              = var.droplet_count
  image              = var.do_image
  name               = var.domain
  region             = var.do_location
  size               = var.do_instance_size["5$"]
  private_networking = true

  ssh_keys = [
    digitalocean_ssh_key.http3_yurets_pro.id
  ]

  tags = [
    "production"
  ]

  connection {
    host        = self.ipv4_address
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "file" {
    content = templatefile("./files/nginx.conf", {
      domain = var.domain
      }
    )
    destination = "/opt/nginx.conf"
  }

  provisioner "file" {
    content = templatefile("./files/cloudflare.ini", {
      cf_token = var.certbot_cf_token
      }
    )
    destination = "/opt/cloudflare.ini"
  }

  provisioner "file" {
    source      = "files/index.html"
    destination = "/opt/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "set -o xtrace errexit",
      "sudo ln -s -f /run/systemd/resolve/resolv.conf /etc/resolv.conf",
      "sleep 60; sudo apt-get -y update && sudo DEBIAN_FRONTEND=noninteractive apt-get -y install htop nload iotop docker.io",
      "sudo wget https://github.com/bcicen/ctop/releases/download/0.7.6/ctop-0.7.6-linux-amd64 -O /usr/local/bin/ctop && sudo chmod +x /usr/local/bin/ctop",
      "/usr/bin/docker run -i --rm --name certbot -v /opt/letsencrypt:/etc/letsencrypt -v /opt/cloudflare.ini:/tmp/cloudflare.ini  certbot/dns-cloudflare certonly --dns-cloudflare --dns-cloudflare-credentials /tmp/cloudflare.ini --agree-tos --email ${var.certbot_email} --no-eff-email -d ${var.domain}",
      "echo '@weekly /usr/bin/docker run -i --rm --name certbot -v /opt/letsencrypt:/etc/letsencrypt -v /opt/cloudflare.ini:/tmp/cloudflare.ini  certbot/dns-cloudflare certonly --dns-cloudflare --dns-cloudflare-credentials /tmp/cloudflare.ini --agree-tos --email ${var.certbot_email} --no-eff-email -d ${var.domain} && /usr/bin/docker restart nginx' > /var/spool/cron/crontabs/root",
      "/usr/bin/docker run --name nginx -d -p 80:80 -p 443:443/tcp -p 443:443/udp -v /opt/letsencrypt/:/opt/nginx/certs/ -v /opt/nginx.conf:/etc/nginx/nginx.conf -v /opt/index.html:/etc/nginx/html/index.html ymuski/nginx-quic"
    ]
  }

}

resource "digitalocean_floating_ip" "http3_yurets_pro" {
  count  = var.droplet_count
  region = var.do_location
}

resource "digitalocean_floating_ip_assignment" "http3_yurets_pro" {
  count      = var.droplet_count
  ip_address = digitalocean_floating_ip.http3_yurets_pro[count.index].ip_address
  droplet_id = digitalocean_droplet.http3_yurets_pro[count.index].id
}


##############################################################
#                          DO Firewall                       #
##############################################################

resource "digitalocean_firewall" "http3_yurets_pro" {
  name = var.domain
  droplet_ids = concat(
    digitalocean_droplet.http3_yurets_pro[*].id
  )
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0"]
  }
  inbound_rule {
    protocol         = "udp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}


##############################################################
#                          DO Project                        #
##############################################################

resource "digitalocean_project" "http3_yurets_pro" {
  name        = var.domain
  description = var.domain
  purpose     = "Web Application"
  environment = "production"

}

data "digitalocean_project" "http3_yurets_pro" {
  name = var.domain
  depends_on = [
    digitalocean_project.http3_yurets_pro,
  ]
}

resource "digitalocean_project_resources" "http3_yurets_pro" {
  project = data.digitalocean_project.http3_yurets_pro.id
  resources = tolist(
    concat(
      tolist(digitalocean_droplet.http3_yurets_pro[*].urn),
      tolist(digitalocean_floating_ip.http3_yurets_pro[*].urn)
    )
  )
}
