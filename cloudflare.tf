#############################################################
#                        Domain                             #
#############################################################

data "cloudflare_zones" "http3_yurets_pro" {
  filter {
    name = var.main_domain
  }
}

resource "cloudflare_record" "http3_yurets_pro" {
  count = var.droplet_count

  zone_id = data.cloudflare_zones.http3_yurets_pro.zones.0.id
  name    = "http3"
  type    = "A"
  value   = digitalocean_floating_ip.http3_yurets_pro[count.index].ip_address
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "https" {
  count = var.droplet_count

  zone_id = data.cloudflare_zones.http3_yurets_pro.zones.0.id
  name    = "http3"
  type    = "HTTPS"
  ttl     = 1
  proxied = false
  data {
    priority = 1
    target   = "http3.yurets.pro."
    value    = "alpn=\"h3,h2\""
  }
}

resource "cloudflare_record" "http3_yurets_pro_extra_record" {
  for_each = var.domain_record

  zone_id = data.cloudflare_zones.http3_yurets_pro.zones.0.id
  name    = each.value.name
  type    = each.value.type
  value   = each.value.value
  ttl     = each.value.ttl
  proxied = each.value.proxied
}

resource "cloudflare_bot_management" "bot_protenction" {
  zone_id           = data.cloudflare_zones.http3_yurets_pro.zones.0.id
  auto_update_model = true
  fight_mode        = true
  enable_js         = true
}
