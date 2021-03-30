

#create security group for web
resource "aws_security_group" "web_security_group" {
name = "web_security_group"
description = "Allow all inbound traffic"
vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
}


#create security group ingress rule for web
resource "aws_security_group_rule" "web_ingress" {
count = length(var.web_ports)
type = "ingress"
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
from_port = element(var.web_ports, count.index)
to_port = element(var.web_ports, count.index)
security_group_id = aws_security_group.web_security_group.id
}


#create security group egress rule for web
resource "aws_security_group_rule" "web_egress" {
count = length(var.web_ports)
type = "egress"
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
from_port = element(var.web_ports, count.index)
to_port = element(var.web_ports, count.index)
security_group_id = aws_security_group.web_security_group.id
}

#create EC2 instance
resource "aws_instance" "my_web_instance" {
ami = "ami-0937dcc711d38ef3f"
instance_type = "t2.micro"
key_name = "karthik" #make sure you have your_private_ket.pem file
associate_public_ip_address = true
vpc_security_group_ids = [aws_security_group.web_security_group.id]
subnet_id = data.terraform_remote_state.vpc.outputs.public_subnets[1]
tags = {
Name = "my_web_instance"
}
volume_tags = {
Name = "my_web_instance_volume"
}
provisioner "remote-exec" { #install apache, mysql client, php
inline = [
"sudo mkdir -p /var/www/html/",
"sudo yum update -y",
"sudo yum install -y httpd",
"sudo service httpd start",
"sudo usermod -a -G apache ec2-user",
"sudo chown -R ec2-user:apache /var/www",
"sudo yum install -y mysql php php-mysql"
]
}
provisioner "file" { #copy the index file form local to remote
source = "index.php"
destination = "/var/www/html/index.php"
}
connection {
type = "ssh"
user = "ec2-user"
host = aws_instance.my_web_instance.public_ip
password = ""
#copy <your_private_key>.pem to your local instance home directory
#restrict permission: chmod 400 <your_private_key>.pem
private_key = file("/home/ubuntu/karthik.pem")
}
}

