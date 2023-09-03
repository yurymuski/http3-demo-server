# http3-demo-terraform

Terraform setup of http3 demo server (Digital Ocean)

link: https://http3.yurets.pro/

---
## Usage
```sh
export DIGITALOCEAN_TOKEN=""
export CLOUDFLARE_API_TOKEN=""
export TF_VAR_certbot_cf_token=""
export TF_VAR_certbot_email=""

terraform init
terraform plan -out=http3.plan
terraform apply http3.plan
```

