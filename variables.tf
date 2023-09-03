variable "main_domain" {
  default = "yurets.pro"
}

variable "domain" {
  default = "http3.yurets.pro"
}

variable "do_image" {
  default = "ubuntu-20-04-x64"
}

variable "do_location" {
  default = "fra1"
}

variable "droplet_count" {
  default = 1
}

variable "do_instance_size" {
  type = map(string)

  default = {
    "5$"  = "s-1vcpu-1gb"
    "10$" = "s-1vcpu-2gb"
    "15$" = "s-2vcpu-2gb"
    "20$" = "s-2vcpu-4gb"
  }
}

variable "domain_record" {
  type    = map(any)
  default = {}
}

variable "certbot_email" {
}

variable "certbot_cf_token" {
}
