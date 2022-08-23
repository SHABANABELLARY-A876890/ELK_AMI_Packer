packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
variable "ami_prefix" {
  type    = string
  default = "logstach"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "logstach" {
    ami_name      = "${var.ami_prefix}-${local.timestamp}"
  #ami_name          = "logstach"
  instance_type     = "t3.small"
  region            = "eu-west-1"
  vpc_id            = "vpc-0eb89aea173a47e3e"
  subnet_id         = "subnet-042449d9d8fdaa9d9"
  security_group_id = "sg-027f17a7576297b79"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"
  tags = {
    "Name" = "logstach-Server"
  }
  
}

build {
  name = "logstach-packer"
  sources = [
    "source.amazon-ebs.logstach",
  ]
  provisioner "ansible" {
    playbook_file = "./playbooks/logstach.yml"
  }
}
