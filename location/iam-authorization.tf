# Authorization policy between Postgres and Satellite
resource "ibm_iam_authorization_policy" "postgres-satellite" {
  count               = var.manage_iam_policy == true ? 1 : 0
  source_service_name = "databases-for-postgresql"
  target_service_name = "satellite"
  # target_resource_instance_id = module.location.id
  roles = ["Satellite Cluster Creator", "Satellite Link Administrator", "Satellite Link Source Access Controller"]
}
