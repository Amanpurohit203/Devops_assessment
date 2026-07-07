variable "project" {
  type    = string
  default = "bookings"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "container_image" {
  type = string
}

variable "task_cpu" {
  type = string
}

variable "task_memory" {
  type = string
}

variable "desired_count" {
  type = number
}

variable "db_instance_class" {
  type = string
}

variable "db_allocated_storage" {
  type = number
}

variable "db_backup_retention_period" {
  type = number
}

variable "db_deletion_protection" {
  type = bool
}

variable "db_password" {
  type      = string
  sensitive = true
}