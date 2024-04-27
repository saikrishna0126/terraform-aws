variable "azs" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]

}

variable "aws_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

}

variable "private_subnet_cidr" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

}

variable "http_port" {
  description = "The port number for HTTP traffic"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "The port number for HTTPS traffic"
  type        = number
  default     = 443
}

variable "ssh_port" {
  description = "The port number for SSH traffic"
  type        = number
  default     = 22
}

variable "instance_types" {
  description = "List of instance types for EC2 instances"
  default     = ["t2.large", "t2.micro"]
}

variable "instance_names" {
  description = "List of instance names for EC2 instances"
  default     = ["public-1", "private-2"]
}

variable "ami_id" {
    default = ""
    description = ""
}
