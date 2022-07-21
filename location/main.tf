resource "ibm_satellite_location" "create_location" {
  count = var.is_location_exist == false ? 1 : 0

  location     = var.location_name
  managed_from = var.managed_from
  zones        = [for idx in range(1, 4) : "${var.region}-${idx}"]

  timeouts {
    create = "60m"
  }

  depends_on = [
    ibm_iam_authorization_policy.postgres-satellite,
  ]
}

resource "ibm_is_vpc" "location_vpc" {
  name = var.location_name
}

resource "ibm_is_security_group" "location_security_group" {
  name = var.location_name
  vpc  = ibm_is_vpc.location_vpc.id
}

resource "ibm_is_security_group_rule" "location_security_rule_inbound" {
  direction = "inbound"
  group     = ibm_is_security_group.location_security_group.id
}

resource "ibm_is_security_group_rule" "location_security_rule_outbound" {
  direction = "outbound"
  group     = ibm_is_security_group.location_security_group.id
}

resource "ibm_is_subnet" "location_subnet_zone" {
  count                    = 3
  name                     = "${var.location_name}-${var.region}-${count.index + 1}"
  vpc                      = ibm_is_vpc.location_vpc.id
  zone                     = "${var.region}-${count.index + 1}"
  total_ipv4_address_count = 256
}

data "ibm_satellite_attach_host_script" "script" {
  location      = data.ibm_satellite_location.location.id
  host_provider = "ibm"
}

data "ibm_satellite_location" "location" {
  location   = var.location_name
  depends_on = [ibm_satellite_location.create_location]
}

output "location_id" {
  value = data.ibm_satellite_location.location.id
}

output "host_script" {
  value = data.ibm_satellite_attach_host_script.script
}

output "location_vpc" {
  value = ibm_is_vpc.location_vpc
}

output "location_subnet" {
  value = ibm_is_subnet.location_subnet_zone
}

output "location_security_group" {
  value = ibm_is_security_group.location_security_group
}
