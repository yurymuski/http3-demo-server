##############################################################
#                       Initialization                       #
##############################################################

# DIGITALOCEAN_TOKEN required
provider "digitalocean" {
}

# CLOUDFLARE_API_TOKEN required
provider "cloudflare" {
  account_id = var.cloudflare_account_id
}
