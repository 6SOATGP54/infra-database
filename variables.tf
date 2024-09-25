variable "region" { 
    type = string 
    default = ""
}

variable "vpc_id" { 
    type = string
    default = ""
}

variable "project" {
    type = string
    default = ""
}

variable "env" {
    type = string
    default = ""
}

variable "username" {
  description = "Username for the master DB user"
  type        = string
}