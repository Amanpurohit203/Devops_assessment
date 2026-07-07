project     = "bookings"
environment = "prod"

vpc_cidr             = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.0.0/24", "10.1.1.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]
azs                  = ["us-east-1a", "us-east-1b"]

container_image = "nginx:latest"
task_cpu        = "512"
task_memory     = "1024"
desired_count   = 2

db_instance_class          = "db.t3.medium"
db_allocated_storage       = 100
db_backup_retention_period = 14
db_deletion_protection     = true