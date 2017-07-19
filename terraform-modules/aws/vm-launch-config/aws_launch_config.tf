variable "aws_s3_bucket" {
  description = "AWS S3 bucket name"
  default = ""
}

variable "cluster_name" {
  description = "Identifier used for naming cluster resources"
  default = ""
}

variable "aws_key_pair_name" {
  description = "AWS key pair name"
  default = ""
}

# Master vars
variable "master_image_id" {
  default = ""
}

variable "master_flavor"{
  default = ""
}

variable "master_iam_instance_profile" {
  default = ""
}

variable "master_security_groups" {
  #type = "list"
  default = []
}

variable "master_script" {
  default = "config_data/aws_launch_configuration_master_user_data"
}

variable "master_script_name" {
  default = "master.sh"
}

# Nodes vars
variable "node_image_id" {
  default = ""
}

variable "node_flavor"{
  default = ""
}

variable "node_iam_instance_profile" {
  default = ""
}

variable "node_security_groups" {
  #type = "list"
  default = []
}

variable "node_script" {
  default = "config_data/aws_launch_configuration_nodes_user_data"
}

variable "node_script_name" {
  default = "nodes.sh"
}

data "template_file" "nodes_user_data" {
  template = "${file("${path.module}/${var.node_script}")}"

  vars {
    aws_s3_bucket = "${var.aws_s3_bucket}"
    cluster_name = "${var.cluster_name}"
  }
}

data "template_file" "master_user_data" {
  template = "${file("${path.module}/${var.master_script}")}"
  vars {
    aws_s3_bucket = "${var.aws_s3_bucket}"
    cluster_name = "${var.cluster_name}"
  }
}


data "template_cloudinit_config" "master_config" {
  part {
    content_type = "text/x-shellscript"
    filename     = "${var.master_script}"
    content      = "${data.template_file.master_user_data.rendered}"
  }
}

data "template_cloudinit_config" "nodes_config" {
  part {
    content_type = "text/x-shellscript"
    filename     = "${var.node_script}"
    content      = "${data.template_file.nodes_user_data.rendered}"
  }
}

resource "aws_launch_configuration" "master-sandbox-dev-cloudautomationcontent-com" {
  name_prefix                 = "${format("master-us-east-1c.masters.%s.dev.cloudautomationcontent.com-",var.cluster_name)}"
  image_id                    = "${var.master_image_id}"
  instance_type               = "${var.master_flavor}"
  key_name                    = "${var.aws_key_pair_name}"
  iam_instance_profile        = "${var.master_iam_instance_profile}"
  security_groups             = ["${var.master_security_groups}"]
  associate_public_ip_address = true
  user_data                   =  "${data.template_cloudinit_config.master_config.rendered}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  ephemeral_block_device = {
    device_name  = "/dev/sdc"
    virtual_name = "ephemeral0"
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "nodes-sandbox-dev-cloudautomationcontent-com" {
  name_prefix                 = "${format("nodes.%s.dev.cloudautomationcontent.com-",var.cluster_name)}"
  image_id                    = "${var.node_image_id}"
  instance_type               = "${var.node_flavor}"
  key_name                    = "${var.aws_key_pair_name}"
  iam_instance_profile        = "${var.node_iam_instance_profile}"
  security_groups             = ["${var.node_security_groups}"]
  associate_public_ip_address = true
  user_data                   = "${data.template_cloudinit_config.nodes_config.rendered}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}


output "aws_launch_config_nodes_id" {
  value = "${aws_launch_configuration.nodes-sandbox-dev-cloudautomationcontent-com.id}"
}

output "aws_launch_config_master_id" {
  value = "${aws_launch_configuration.master-sandbox-dev-cloudautomationcontent-com.id}"
}
