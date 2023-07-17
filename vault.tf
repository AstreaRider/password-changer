provider "vault" {
  address       = var.vault_address
  token         = var.vault_token
}

data "vault_kv_secret_v2" "secret_data" {
  mount = var.vault_path
  name  = var.vault_name
}

output "vault_secrets" {
  value = data.vault_kv_secret_v2.secret_data.data
  sensitive = true
}