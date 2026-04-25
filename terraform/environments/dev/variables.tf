# variable "region" {
#    default = "eu-west-1"
# }

variable "cidr_block" {
   default = "10.0.0.0/16"
}

variable "public_subnet" {
   default = "10.0.1.0/24"
   description = "Public Subnet"
}

variable "private_subnet" {
   default = "10.0.2.0/24"
   description = "Private Subnet"
}


