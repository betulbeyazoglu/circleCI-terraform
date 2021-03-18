terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.22.0"
    }
  }
  backend "s3" {
    bucket = "62a96690-3736-bd98-5de8-9199e784da38-backend"
    key = "terraform/webapp/terraform.tfstate"
    region = "us-east-1"
  }
}
provider "aws" {
  region = "us-east-1"
  }


resource "aws_instance" "project-bb" {
  ami = "ami-013f17f36f8b1fefb"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  
  user_data = <<-EOF
              #! /bin/bash
              sudo apt-get update
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              sudo bash -c 'echo <h1>Deployed via Terraform</h1> > /var/www/html/index.html'
              EOF
  tags = {
    Name = "project-bb"
  }
}
