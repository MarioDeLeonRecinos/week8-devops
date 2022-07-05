resource "google_project_service" "services" {
  for_each = toset(var.services)
  service  = each.value
}
