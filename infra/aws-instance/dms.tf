# dms.tf
resource "aws_dms_replication_subnet_group" "dms_sg" {
  replication_subnet_group_id = "dms-sg"
  subnet_ids                  = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  replication_subnet_group_description = "DMS subnet group"
}

resource "aws_dms_replication_instance" "dms_instance" {
  replication_instance_id   = "dms-instance-mongo-crate"
  replication_instance_class = "dms.t2.micro"
  allocated_storage         = 100
  replication_subnet_group_id = aws_dms_replication_subnet_group.dms_sg.id
  vpc_security_group_ids    = [aws_security_group.dms.id]
}

resource "aws_dms_endpoint" "mongo_source" {
  endpoint_id   = "mongo-source"
  endpoint_type = "source"
  engine_name   = "mongodb"
  username      = mongodbatlas_database_user.db-user.username
  password      = mongodbatlas_database_user.db-user.password
  server_name   = regex("mongodb://([^,]+):", mongodbatlas_advanced_cluster.atlas-cluster.connection_strings.0.standard)[0]
  port          = 27017
  database_name = "test"

  mongodb_settings {
    nesting_level  = "none"     # Set to "none" or "one" depending on your data
  }
}

resource "aws_dms_endpoint" "pg_destination" {
  endpoint_id   = "crate-target"
  endpoint_type = "target"
  engine_name   = "postgres"
  username      =  module.cratedb-cluster.cratedb_username
  password      =  module.cratedb-cluster.cratedb_password
  server_name   = module.cratedb-cluster.utility_vm_host
  port          = 5432
  database_name = "postgres"
}

resource "aws_dms_replication_task" "mongo_to_pg" {
  replication_task_id          = "mongo-to-pg"
  migration_type               = "full-load"
  source_endpoint_arn          = aws_dms_endpoint.mongo_source.endpoint_arn
  target_endpoint_arn          = aws_dms_endpoint.pg_destination.endpoint_arn
  replication_instance_arn     = aws_dms_replication_instance.dms_instance.replication_instance_arn
  table_mappings               = file("table-mappings.json")
  replication_task_settings    = file("replication-task-settings.json")
}