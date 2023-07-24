provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

data "vault_kv_secret_v2" "secret_data" {
  mount    = var.vault_path
  for_each = toset(var.vault_name)
  name     = each.key
}

output "vault_secrets" {
  value = {
    for k, v in data.vault_kv_secret_v2.secret_data : k => v.data["current_password"]
  }
  sensitive = true
}