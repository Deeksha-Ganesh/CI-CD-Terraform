resource "aws_security_group" "swig-sg" {
  name        = "swig-sg"
  description = "Open 22, 443, 80, 8080, 9000"
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow App Port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow App Port 9000"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow App Port 3000"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "swig-sg"
  }
}


resource "tls_private_key" "swig-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "swig-key" {
  key_name   = "swig-key"
  public_key = tls_private_key.swig-key.public_key_openssh
}

resource "local_file" "private_key" {
  content = tls_private_key.swig-key.private_key_pem
  filename = "C:\\Users\\User\\Downloads\\swig-key.pem"
  file_permission      = "0400"
  directory_permission = "0700"
}

resource "aws_instance" "swig-user" {
  ami           = "ami-0360c520857e3138f" 
  instance_type = "t2.micro"

  key_name               = aws_key_pair.swig-key.key_name
  vpc_security_group_ids = [aws_security_group.swig-sg.id]
  availability_zone      = "us-east-1b"
  user_data              = file("./resource.sh")

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    tags = {
      Name = "swig-root-volume"
    }
  }

  tags = {
    Name = "swig-user"
  }
}

resource "aws_ebs_volume" "swig-extra" {
  availability_zone = "us-east-1b"
  size              = 100
  tags = {
    Name = "swig-extra"
  }
}

resource "aws_volume_attachment" "swig-extra-attach" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.swig-extra.id
  instance_id = aws_instance.swig-user.id
}
