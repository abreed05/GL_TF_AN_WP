variable "ec2_image" {
  default = "ami-0885b1f6bd170450c"
}

variable "ec2_instance_type" {
  default = "t2.micro"
}

variable "ec2_keypair" {
  default = "AWS-Gitlab"
}

variable "ec2_count" {
  default = "2"
}

variable "ec2_tags" {
  default = "Gitlab-Demo-Terraform-1"
} 

variable "domain" {
  type = string
  default = "yourdomain.com"
}