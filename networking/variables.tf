# MODULE ------------ networking/variables.tf ---------------- MODULE

variable "vpc_cidr" {
  type = string
}

variable "pub_subnetcidr" {
  type = list(any)
}

variable "priv_subnetcidr" {
  type = list(any)
}

variable "priv_counter" {
  type = number
}

variable "pub_counter" {
  type = number
}

variable "max_subnets" {}

variable "security_groups" {
  type = map(any)
}

variable "sg_access_from" {
  type = list(any)
}

variable "db_subnet_group" {
  type = bool
}