variable "region" {
  default = "ap-south-1"
}
variable "az1" {
  default = "ap-south-1a"
}
variable "az2" {
  default = "ap-south-1b"
}
variable "vpc_cidr" {
  # moved to 10.1.0.0/16 to avoid overlap with existing 10.0.0.0/16
  default = "10.1.0.0/16"
}
variable "private-vpc_cidr" {
  default = "10.1.0.0/20"
}
variable "private-vpc_cidr2" {
  default = "10.1.16.0/20"
}
variable "public-cidr" {
  default = "10.1.32.0/20"
}
variable "project_name" {
  default = "FCT"
}
variable "igw_cidr" {
  default = "0.0.0.0/0"
}
variable "ami" {
  default = "ami-00ca570c1b6d79f36"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "key" {
  default = "com"
}
