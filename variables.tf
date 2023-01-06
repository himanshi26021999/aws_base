variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "ami" {
  default = "ami-0a5e707736615003c"
}

variable "s3bucket" {
  default = "mybucket"
}
# Access the ec2 instance remotely to run ansible; user and key:

variable "PRIVATE_KEY_PATH" {
  default = "~/.ssh/aws/mykeypair.pem"
}
variable "PUBLIC_KEY_PATH" {
  default = "aws-key.pub"
}
variable "EC2_USER" {
  default = "ubuntu"
}

#RDS credentials
variable "database_username" {
  type        = string
  description = "Name of user inside storage engine"
}

variable "database_password" {
  type        = string
  description = "Database password inside storage engine"
}

variable "database_port" {
  default     = 5432
  type        = number
  description = "Port on which database will accept connections"
}

variable "allocated_storage" {
  default     = 32
  type        = number
  description = "Storage allocated to database instance"
}