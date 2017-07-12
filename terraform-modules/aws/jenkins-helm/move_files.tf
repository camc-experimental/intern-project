variable "user" {}
variable "key" {}
variable "ip_address" {}

resource "null_resource" "move_files" {
  connection {
    host        = "${var.ip_address}"
    user        = "${var.user}"
    private_key = "${var.key}"
  }

  provisioner "remote-exec" {
   inline = [
     "sudo bash -c 'mkdir /home/admin/scripts /home/admin/jenkins_imports'",
     "sudo bash -c 'chown admin:admin /home/admin/scripts /home/admin/jenkins_imports'"
   ]
  }

  provisioner "file" {
    source      = "${path.module}/files/"
    destination = "/home/admin/scripts"
  }

  provisioner "file" {
    source      = "${path.module}/jenkins_imports/"
    destination = "/home/admin/jenkins_imports"
  }

  provisioner "remote-exec" {
   inline = [
     "sudo bash -c 'chmod +x /home/admin/scripts/*.sh'"
   ]
  }
}
