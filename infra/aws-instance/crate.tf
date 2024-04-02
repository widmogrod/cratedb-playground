module "cratedb-cluster" {
  source = "github.com/crate/crate-terraform.git/aws"

  # Global configuration items for naming/tagging resources
  config = {
    project_name = "example-project"
    environment  = "test"
    owner        = "widmogrod"
    team         = "ghosteam"
  }

  # CrateDB-specific configuration
  crate = {
    # Java Heap size in GB available to CrateDB
    heap_size_gb = 2

    cluster_name = "crate-cluster"

    # The number of nodes the cluster will consist of
    cluster_size = 2

    # Enables a self-signed SSL certificate
    ssl_enable = true
  }

  # The disk size in GB to use for CrateDB's data directory
  disk_size_gb = 512

  # The AWS region
  region = var.aws_region

  # The VPC to deploy to
  vpc_id = aws_vpc.vpc.id

  # Applicable subnets of the VPC
  subnet_ids = aws_subnet.private_subnet.*.id

  # The corresponding availability zones of above subnets
  availability_zones = aws_subnet.private_subnet.*.availability_zone

  # The SSH key pair for EC2 instances
  ssh_keypair = "gh-dev-mac-studio"

  # Enable SSH access to EC2 instances
  ssh_access = true
}

output "cratedb" {
  value     = module.cratedb-cluster
  sensitive = true
}