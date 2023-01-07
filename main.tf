resource "aws_key_pair" "aws-key" {
  key_name   = "aws-key"
  public_key = file(var.PUBLIC_KEY_PATH)// Path is in the variables file
}

resource "aws_instance" "nginx_server" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"
  # VPC
  subnet_id = aws_subnet.public_subnets.id
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.ssh-allowed-nginx.id}"]
  # the Public SSH key
  key_name = aws_key_pair.aws-key.id
  # nginx installation
  # storing the nginx.sh file in the EC2 instnace
  provisioner "file" {
    source      = "nginx.sh"
    destination = "/tmp/nginx.sh"
  }
  # Exicuting the nginx.sh file
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/nginx.sh",
      "sudo /tmp/nginx.sh"
    ]
  }
  # Setting up the ssh connection to install the nginx server
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("${var.PRIVATE_KEY_PATH}")
  }

  tags = {
    Name = "nginx server"
    type = "web server"
  }
}

resource "aws_instance" "tomcat" {
  count = "1"
  instance_type = "t2.micro"


  iam_instance_profile = "${aws_iam_instance_profile.tomcat_ec2_profile.name}"

  ami = "${var.ami}"

  key_name = aws_key_pair.aws-key.id

  vpc_security_group_ids = ["${aws_security_group.tomcat.id}"]
  subnet_id              = aws_subnet.private_subnets.id

  tags = {
    Name = "tomcat server"
    type = "app server"
  }
  # Provisioners; run in the order below:

  # This one waits until the ssh connection comes alive
  provisioner "remote-exec" {
    inline = [ "echo hello" ]

    connection {
      type = "ssh"
      user = "${var.EC2_USER}"
      private_key = "${file(var.PRIVATE_KEY_PATH)}"
    }
  }

  # This one runs ansible locally to configure the remote ec2 instance
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.EC2_USER} -i '${self.public_ip},' --private-key ${var.PRIVATE_KEY_PATH} -b install-tomcat.yaml"
  }
}

# RDS resources

resource "aws_db_instance" "postgresql" {
  engine                          = "postgres"
  engine_version                  = "11.5"
  instance_class                  = "db.t3.micro"
  storage_type                    = "gp2"
  name                            = "Application DB"
  allocated_storage               = var.allocated_storage
  password                        = var.database_password
  username                        = var.database_username
  port                            = var.database_port
  vpc_security_group_ids          = aws_security_group.postgresql.id
  db_subnet_group_name            = aws_db_subnet_group.db_subnet.name


  tags =
  {
    Name        = "application DB",
    type        = "DB server"
  }
}