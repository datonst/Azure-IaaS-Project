resource "random_password" "AWSTunnel1ToInstance0-PSK" {
  length  = 16
  special = false

}

resource "random_password" "AWSTunnel2ToInstance0-PSK" {
  length  = 16
  special = false
}

# aws ec2 create-key-pair --key-name web-ec2-key-pair --query 'KeyMaterial' --output text > web-ec2-key-pair.pem
# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create the Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "key-pair"
  public_key = tls_private_key.key_pair.public_key_openssh
}
# Save file
resource "local_file" "ssh_key_private" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}


data "http" "source_ip" {
  url = "https://ifconfig.me"
}