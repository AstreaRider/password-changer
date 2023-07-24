terraform {
  required_providers {
    ssh = {
      source = "loafoe/ssh"
      version = "2.6.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "3.18.0"
    }
  }
}

provider "ssh" {
  alias = "loafoe"
}

resource "ssh_resource" "init" {
  provider       = ssh.loafoe
  for_each       = toset(var.vault_name)
  host         = data.vault_kv_secret_v2.secret_data["${each.key}"].data["host"]
  user         = data.vault_kv_secret_v2.secret_data["${each.key}"].data["username"]
  password     = data.vault_kv_secret_v2.secret_data["${each.key}"].data["current_password"]
  port         = 22

  file {
    content     = "${data.vault_kv_secret_v2.secret_data["${each.key}"].data["current_password"]}\n${data.vault_kv_secret_v2.secret_data["${each.key}"].data["new_password"]}\n${data.vault_kv_secret_v2.secret_data["${each.key}"].data["new_password"]}"
    destination = "/home/${data.vault_kv_secret_v2.secret_data["${each.key}"].data["username"]}/inputfile"
    permissions = "0664"
  }

  commands = [
    "passwd ${data.vault_kv_secret_v2.secret_data["${each.key}"].data["username"]} < /home/${data.vault_kv_secret_v2.secret_data["${each.key}"].data["username"]}/inputfile | wall -n 'Koneksi terputus karena password diganti, hubungi administrator!' | pkill -o -u ${data.vault_kv_secret_v2.secret_data["${each.key}"].data["username"]} sshd"
  ]

}