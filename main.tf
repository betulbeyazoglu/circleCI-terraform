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
resource "aws_iam_user" "circleci" {
  name = var.user
  path = "/system/"
}

resource "aws_iam_access_key" "circleci" {
  user = aws_iam_user.circleci.name
}

data "template_file" "circleci_policy" {
  template = file("circleci_s3_access.tpl.json")
  vars = {
    s3_bucket_arn = aws_s3_bucket.app.arn
  }
}

resource "local_file" "circle_credentials" {
  filename = "tmp/circleci_credentials"
  content  = "${aws_iam_access_key.circleci.id}\n${aws_iam_access_key.circleci.secret}"
}

resource "aws_iam_user_policy" "circleci" {
  name   = "AllowCircleCI"
  user   = aws_iam_user.circleci.name
  policy = data.template_file.circleci_policy.rendered
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
