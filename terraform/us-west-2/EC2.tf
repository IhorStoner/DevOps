#----------------------------------------------------
// Generate the SSH keypair that we’ll use to configure the EC2 instance.
// After that, write the private key to a local file and upload the public key to AWS
resource "tls_private_key" "key" {
  algorithm = "RSA"
}
resource "local_sensitive_file" "private_key" {
  filename        = "${var.key_name}.pem"
  content         = tls_private_key.key.private_key_pem
  file_permission = "0400"
}
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.key.public_key_openssh
}

#----------------------------------------------------
# Create Security Group for the Bastion Host aka Jump Box
# terraform aws create security group
resource "aws_security_group" "main-security-group" {
  name        = "HTTP/HTTPS/SSH Security Group"
  description = "Enable HTTP/HTTPS access on Port 80/443 via ALB and SSH access on Port 22"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.security_group_location]
  }

  ingress {
    description = "HTTP Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.security_group_location]
  }

  ingress {
    description = "HTTPS Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.security_group_location]
  }

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.security_group_location]
  }

  ingress {
    description = "DB Access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.security_group_location]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "HTTP/HTTPS/SSH"
  }
}

#----------------------------------------------------

#Create a new EC2 launch configuration
resource "aws_instance" "ec2_public" {
  ami                         = "ami-08e2d37b6a0129927"
  instance_type               = var.instance_type
  key_name                    = var.key_name
  security_groups             = [aws_security_group.main-security-group.id]
  subnet_id                   = aws_subnet.main_public.id
  associate_public_ip_address = true
  user_data                   = file("user_data.sh")


  lifecycle {
    create_before_destroy = true
  }
  tags = {
    "Name" = "EC2-PUBLIC"
  }
  # Copies the ssh key file to home dir
  provisioner "file" {
    source      = "./${var.key_name}.pem"
    destination = "/home/ec2-user/${var.key_name}.pem"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }
  }
  //chmod key 400 on EC2 instance
  provisioner "remote-exec" {
    inline = ["chmod 400 ~/${var.key_name}.pem"]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }
  }
}

output "EC2_PUBLIC_URL" {
  value = aws_instance.ec2_public.public_ip
}