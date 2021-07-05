# http3-demo-terraform

Terraform setup of http3 demo server (Digital Ocean) 

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

---
## TODO

- [ ] Add HTTPS dns record 
  >  expected type to be one of [A AAAA CAA CNAME TXT SRV LOC MX NS SPF CERT DNSKEY DS NAPTR SMIMEA SSHFP TLSA URI PTR], got HTTPS
