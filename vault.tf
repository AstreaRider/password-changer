provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

data "vault_kv_secret_v2" "secret_data" {
  mount    = var.vault_path
  for_each = toset(var.vault_name)
  name     = each.key
}

output "content-email" {
  value = {
    for k, v in data.vault_kv_secret_v2.secret_data : k => "Update password on VM on ${v.name}(${v.data["host"]}) successfully done. Use ${v.data["new_password"]} as new password to login."
  }
  sensitive = true
}