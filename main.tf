terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws",
        version = "~> 5.1"
    }         
  }
}

provider "aws" {
     region = "eu-west-2" 
  
}
//Create keypair for my instance
# resource  "tls_private_key" "babykey" {
#   algorithm = "RSA"
#   rsa_bits = "4096"
# }
resource  "aws_key_pair" "awskey" {
     key_name = "testkey"
     public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDADlN5XdpC5ipy7nWYMEVgm/IAievA5M91porkjLt9bm9x6x/xRMZvZNn69hfylUmn84en0qCf7OZ9CoWX0BymMXAOd44DH6ZpBV4GcM6Zmxd4MgYHAvnRrGEE0EN2VuLIwkERusJlnez1muQXE65IL8wUP85/yvRxFfZhJtxQWQNgwPKG3v3WK/+5CnhAlG21TtKi3FbeFAUT5tBhr8YOR00myJ467CSys/+3RFp2o+pHzpU5ouIf8yEZiaFysgcJzS7fmu0hzqv7usIu+TMsfIGnsfLUOEJHYWFEyUP5pFuu75BNUV1F+H0geTkUlgtaMgYDJI7zhlBArAYCMoobz1sItRLAyDESzHcp114zZ7eJsTpS47wDh8OKjNn2PKnLXvNo/1npiooKJNgoCA8P2bBG75qsk026EHI8AZzEL4sTZPn4xS921vx5CA7WU0/1EbTSUgywu3u3PtOhBCmWVqrF/WTTvEKgIVUdHi/wkDbTD5j+BKls7GqRmpqv8+E= jade@Jades-MBP"
}

//save the private key comment  another
#   resource  "local_file" "storing_baby_pem"{
#       content = tls_private_key.babykey.private_key_pem
#       filename = aws_key_pair.babykey_key_pair.key_name 
# } 
//security group
  resource  "aws_security_group" "jade_ssg" {
      name = "jade"
      description = "This allows access to the instances"
      vpc_id = "vpc-084ebc40bf53df751"

      ingress {
          description = "Allow SSH access"
          protocol = "TCP"
          from_port = 22
          to_port = 22
          cidr_blocks = ["0.0.0.0/0"]
      }

      ingress {
           description = "Allow HTTP access"
           protocol = "TCP"
           from_port = 80
           to_port = 80
           cidr_blocks = ["0.0.0.0/0"]
      }
      egress {
          description = "Outbound traffic for demo1 instance"
          from_port = "0"
          to_port = "0"
          protocol = "-1"
          cidr_blocks =  ["0.0.0.0/0"]
      }
      tags = {
          name = "Security group for demo1 instance"
      }  
}        
//create an intance
resource "aws_instance" "demo1_instance" {
    ami = "ami-0505148b3591e4c07"
    instance_type = "t2.micro"
    count = 1
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.jade_ssg.id]

    key_name = aws_key_pair.awskey.key_name
    //user_data = file("/Users/jade/DevOps/learnings/terra1/run.sh")
    
    tags = { 
        Name = "demo1_instance"
    }    
    connection {
        host = self.public_ip
        type = "ssh"
        user = "ubuntu"
        private_key = "${file("testkey")}"
    }   

// add a provisioner to copy the file over to the instance
provisioner "remote-exec" {
  script = "/Users/jade/DevOps/learnings/webdev_actions_pull2instance/config.sh"
  when = create
}

}
