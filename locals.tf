locals {
  required_services = toset([
    "bigquery.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
  ])

  common_labels = merge(var.labels, {
    environment = var.environment
    managed_by  = "terraform"
    workload    = "bch-analytics"
  })

  github_dbt_repository            = "${var.github_repository_owner}/${var.github_dbt_repository}"
  github_infrastructure_repository = "${var.github_repository_owner}/${var.github_infrastructure_repository}"

  github_dbt_repository_condition = format(
    "attribute.repository == '%s' && (attribute.ref == 'refs/heads/main' || (%s && attribute.event_name == 'pull_request' && attribute.actor == '%s'))",
    local.github_dbt_repository,
    var.environment == "dev",
    var.github_repository_owner,
  )
  github_infrastructure_repository_condition = format(
    "attribute.repository == '%s' && attribute.ref == 'refs/heads/main'",
    local.github_infrastructure_repository,
  )
  github_attribute_condition = format(
    "attribute.repository_owner == '%s' && (%s || %s)",
    var.github_repository_owner,
    local.github_dbt_repository_condition,
    local.github_infrastructure_repository_condition,
  )
}
