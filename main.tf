provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

module "location" {
  source = "./location"

  location_name     = var.location_name
  is_location_exist = var.is_location_exist
  manage_iam_policy = var.manage_iam_policy
  managed_from      = var.managed_from
  region            = var.region
}

module "control_plane" {
  source = "./host"

  location_name           = var.location_name
  image                   = var.image
  existing_ssh_key        = var.existing_ssh_key
  region                  = var.region
  hosts                   = var.control_plane_hosts
  host_script             = module.location.host_script
  location_vpc            = module.location.location_vpc
  location_subnet         = module.location.location_subnet
  location_security_group = module.location.location_security_group
}

module "customer" {
  source = "./host"

  location_name           = var.location_name
  image                   = var.image
  existing_ssh_key        = var.existing_ssh_key
  region                  = var.region
  hosts                   = var.customer_hosts
  host_script             = module.location.host_script
  location_vpc            = module.location.location_vpc
  location_subnet         = module.location.location_subnet
  location_security_group = module.location.location_security_group
}

module "internal" {
  source = "./host"

  location_name           = var.location_name
  image                   = var.image
  existing_ssh_key        = var.existing_ssh_key
  region                  = var.region
  hosts                   = var.internal_hosts
  host_script             = module.location.host_script
  location_vpc            = module.location.location_vpc
  location_subnet         = module.location.location_subnet
  location_security_group = module.location.location_security_group
}
