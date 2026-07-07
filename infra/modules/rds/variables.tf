variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "rds_sg_id" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "db_name" {
  type    = string
  default = "bookingsdb"
}

variable "db_username" {
  type    = string
  default = "app_admin"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "backup_retention_period" {
  type = number
}

variable "deletion_protection" {
  type = bool
}