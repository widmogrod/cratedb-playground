# Atlas Organization ID
variable "atlas_org_id" {
  type        = string
  description = "Atlas Organization ID"
}
# Atlas Project Name
variable "atlas_project_name" {
  type        = string
  description = "Atlas Project Name"
}

# Atlas Project Environment
variable "environment" {
  type        = string
  description = "The environment to be built"
}

# Cluster Instance Size Name
variable "cluster_instance_size_name" {
  type        = string
  description = "Cluster instance size name"
}

# Cloud Provider to Host Atlas Cluster
variable "cloud_provider" {
  type        = string
  description = "AWS or GCP or Azure"
}

# Atlas Region
variable "atlas_region" {
  type        = string
  description = "Atlas region where resources will be created"
}

# MongoDB Version
variable "mongodb_version" {
  type        = string
  description = "MongoDB Version"
}

variable "mongodb_atlas_public_key" {
  description = "Public API key to authenticate to Atlas"
  type        = string
}
variable "mongodb_atlas_private_key" {
  description = "Private API key to authenticate to Atlas"
  type        = string
}

variable "atlas_vpc_cidr" {
  type = string
}


variable "aws_region" {
  default = "eu-west-1"
}