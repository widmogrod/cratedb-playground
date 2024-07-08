# Create a Project
resource "mongodbatlas_project" "atlas-project" {
  org_id = var.atlas_org_id
  name   = var.atlas_project_name
}

# Create a Database User
resource "mongodbatlas_database_user" "db-user" {
  username           = "user-1"
  password           = random_password.db-user-password.result
  project_id         = mongodbatlas_project.atlas-project.id
  auth_database_name = "admin"
  roles {
    role_name     = "readWrite"
    database_name = "${var.atlas_project_name}-db"
  }
}

# Create a Database Password
resource "random_password" "db-user-password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Create Database IP Access List
resource "mongodbatlas_project_ip_access_list" "ip" {
  project_id = mongodbatlas_project.atlas-project.id
  ip_address = aws_instance.host.public_ip
}

resource "mongodbatlas_network_container" "test2" {
  project_id       = mongodbatlas_project.atlas-project.id
  atlas_cidr_block = var.atlas_vpc_cidr
  provider_name    = "AWS"
  region_name      = var.atlas_region
}

resource "mongodbatlas_network_peering" "test" {
  project_id             = mongodbatlas_project.atlas-project.id
  container_id           = mongodbatlas_network_container.test2.container_id
  accepter_region_name   = var.atlas_region
  provider_name          = "AWS"
  route_table_cidr_block = var.cidr_block
  vpc_id                 = aws_vpc.vpc.id
  aws_account_id         = data.aws_caller_identity.current.account_id
}

resource "mongodbatlas_project_ip_access_list" "test" {
  project_id         = mongodbatlas_project.atlas-project.id
  aws_security_group = aws_security_group.public.id
  comment            = "TestAcc for awsSecurityGroup"

  depends_on = [mongodbatlas_network_peering.test]
}

resource "mongodbatlas_privatelink_endpoint" "test" {
  project_id    = mongodbatlas_project.atlas-project.id
  provider_name = "AWS"
  region        = var.atlas_region
}

resource "aws_vpc_endpoint" "ptfe_service" {
  vpc_id             = aws_vpc.vpc.id
  service_name       = mongodbatlas_privatelink_endpoint.test.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  security_group_ids = [aws_security_group.public.id]
}

resource "mongodbatlas_privatelink_endpoint_service" "test" {
  project_id          = mongodbatlas_privatelink_endpoint.test.project_id
  private_link_id     = mongodbatlas_privatelink_endpoint.test.private_link_id
  endpoint_service_id = aws_vpc_endpoint.ptfe_service.id
  provider_name       = "AWS"
}

# Create an Atlas Advanced Cluster
resource "mongodbatlas_advanced_cluster" "atlas-cluster" {
  project_id             = mongodbatlas_project.atlas-project.id
  name                   = "${var.atlas_project_name}-${var.environment}-cluster"
  cluster_type           = "REPLICASET"
  backup_enabled         = false
  mongo_db_major_version = var.mongodb_version
  replication_specs {
    region_configs {
      electable_specs {
        instance_size = var.cluster_instance_size_name
        node_count    = 3
      }
      #       analytics_specs {
      #         instance_size = var.cluster_instance_size_name
      #         node_count    = 1
      #       }
      priority      = 7
      provider_name = var.cloud_provider
      region_name   = var.atlas_region
    }
  }
}


# Outputs to Display
output "atlas_cluster_connection_string_srv" {
  value = mongodbatlas_advanced_cluster.atlas-cluster.connection_strings.0.standard_srv
}
output "atlas_cluster_connection_string" {
  value = mongodbatlas_advanced_cluster.atlas-cluster.connection_strings.0.standard
}
output "atlas_cluster_connection_private_string" {
  value = mongodbatlas_advanced_cluster.atlas-cluster.connection_strings.0.private_endpoint
}
output "ip_access_list" { value = mongodbatlas_project_ip_access_list.ip.ip_address }
output "project_name" { value = mongodbatlas_project.atlas-project.name }
output "username" { value = mongodbatlas_database_user.db-user.username }
output "user_password" {
  sensitive = true
  value     = mongodbatlas_database_user.db-user.password
}