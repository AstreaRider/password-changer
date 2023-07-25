terraform {
  required_providers {
    ssh = {
      source   = "loafoe/ssh"
      version  = "2.6.0"
    }
    vault = {
      source   = "hashicorp/vault"
      version  = "3.18.0"
    }
     null = {
      source = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

provider "ssh" {
  alias = "loafoe"
}

resource "ssh_resource" "init" {
  provider     = ssh.loafoe
  for_each     = toset(var.vault_name)
  host         = data.vault_kv_secret_v2.secret_data["${each.key}"].data["host"]
  user         = data.vault_kv_secret_v2.secret_data["${each.key}"].data["username"]
  password     = data.vault_kv_secret_v2.secret_data["${each.key}"].data["current_password"]
  port         = 22


  file {
    content     = "${data.vault_kv_secret_v2.secret_data["${each.key}"].data["current_password"]}\n${data.vault_kv_secret_v2.secret_data["${each.key}"].data["new_password"]}\n${data.vault_kv_secret_v2.secret_data["${each.key}"].data["new_password"]}"
    destination = "/home/${data.vault_kv_secret_v2.secret_data["${each.key}"].data["username"]}/inputfile"
    permissions = "0664"
  }

  commands      = [
    "passwd ${data.vault_kv_secret_v2.secret_data["${each.key}"].data["username"]} < /home/${data.vault_kv_secret_v2.secret_data["${each.key}"].data["username"]}/inputfile | echo last update password $(date) with ${data.vault_kv_secret_v2.secret_data["${each.key}"].data["new_password"]} as new password >> /home/${data.vault_kv_secret_v2.secret_data["${each.key}"].data["username"]}/change-password.log | pkill -o -u ${data.vault_kv_secret_v2.secret_data["${each.key}"].data["username"]} sshd"
  ]

}

provider "null" {
  alias = "provider"
}

resource "null_resource" "content-email" {
  provider = null.provider
  for_each = toset(var.vault_name)
  provisioner "local-exec" {
    command = "echo Update password on VM ${each.key}, IP ${data.vault_kv_secret_v2.secret_data["${each.key}"].data["host"]} successfully done at $(date). Use password ${data.vault_kv_secret_v2.secret_data["${each.key}"].data["new_password"]} as new password to login >> content-email.txt"
  }
}

resource "null_resource" "send-email" {
  provider = null.provider
  provisioner "local-exec" {
    command = "python3 email-notification.py ${var.email_sender} ${var.email_sender_password} ${var.email_receiver}"
  }
  depends_on = [ null_resource.content-email ]
}