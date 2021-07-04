output "droplet_ip" {
  value = digitalocean_droplet.http3_yurets_pro[*].ipv4_address
}

output "domain" {
  value = var.domain
}