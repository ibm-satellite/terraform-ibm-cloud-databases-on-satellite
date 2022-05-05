locals {
  host_init = templatefile("${path.module}/init.sh", {
    "host_script" = var.host_script.host_script
  })
}

data "ibm_is_ssh_key" "existing" {
  name = var.existing_ssh_key
}

data "ibm_is_image" "host" {
  name = var.image
}

resource "ibm_is_instance" "location_hosts" {
  count = var.hosts.count

  name    = "${var.location_name}-${var.hosts.name}-0${count.index + 1}"
  vpc     = var.location_vpc.id
  zone    = "${var.region}-${count.index % 3 + 1}"
  image   = data.ibm_is_image.host.id
  profile = var.hosts.type
  keys    = [data.ibm_is_ssh_key.existing.id]

  primary_network_interface {
    name            = "eth0"
    subnet          = var.location_subnet[count.index % 3].id
    security_groups = [var.location_security_group.id]
  }

  user_data = local.host_init
}

resource "ibm_is_floating_ip" "location_hosts" {
  count = var.hosts.count

  name   = ibm_is_instance.location_hosts[count.index].name
  target = ibm_is_instance.location_hosts[count.index].primary_network_interface[0].id
}

