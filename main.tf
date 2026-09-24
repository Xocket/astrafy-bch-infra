resource "google_project" "this" {
  project_id      = var.project_id
  name            = var.project_name
  org_id          = var.organization_id
  billing_account = var.billing_account_id
  deletion_policy = var.deletion_protection ? "PREVENT" : "DELETE"
  labels          = local.common_labels

  lifecycle {
    precondition {
      condition     = var.project_id != var.state_project_id
      error_message = "The analytics project_id must differ from the dedicated state_project_id."
    }
  }
}

resource "google_project_service" "required" {
  for_each = local.required_services

  project            = google_project.this.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_bigquery_dataset" "this" {
  for_each = toset(["staging", "marts"])

  dataset_id                 = each.key
  project                    = google_project.this.project_id
  description                = "Astrafy BCH Analytics ${title(each.key)} dataset (${var.environment})."
  location                   = var.bigquery_location
  delete_contents_on_destroy = var.delete_dataset_contents_on_destroy
  labels                     = local.common_labels

  depends_on = [google_project_service.required]
}

resource "google_bigquery_table" "source_access_view" {
  project     = google_project.this.project_id
  dataset_id  = google_bigquery_dataset.this["staging"].dataset_id
  table_id    = "bch_transactions_source"
  description = "Terraform-managed access view over the required public Bitcoin Cash transactions source."

  view {
    query          = "SELECT * EXCEPT(`hash`), `hash` AS transaction_hash FROM `${var.source_project}.${var.source_dataset}.transactions`"
    use_legacy_sql = false
  }

  depends_on = [google_project_service.required]
}

resource "google_service_account" "dbt" {
  account_id   = "bch-dbt-runner"
  display_name = "BCH dbt runner"
  description  = "Runs dbt against the ${var.environment} staging and marts datasets."
  project      = google_project.this.project_id

  depends_on = [google_project_service.required]
}

resource "google_project_iam_custom_role" "dbt_dataset_creator" {
  project     = google_project.this.project_id
  role_id     = "bchDbtDatasetCreator"
  title       = "BCH dbt dataset creator"
  description = "Allows dbt to ensure its provisioned BigQuery schemas exist without granting project-wide data editing."
  stage       = "GA"
  permissions = [
    "bigquery.datasets.create",
    "bigquery.datasets.get",
  ]
}

resource "google_project_iam_member" "dbt_dataset_creator" {
  project = google_project.this.project_id
  role    = google_project_iam_custom_role.dbt_dataset_creator.name
  member  = "serviceAccount:${google_service_account.dbt.email}"
}

resource "google_project_iam_member" "dbt_job_user" {
  project = google_project.this.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.dbt.email}"
}

resource "google_bigquery_dataset_iam_member" "dbt_data_editor" {
  for_each = google_bigquery_dataset.this

  project    = each.value.project
  dataset_id = each.value.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.dbt.email}"
}

resource "google_iam_workload_identity_pool" "github" {
  project                   = google_project.this.project_id
  workload_identity_pool_id = "github-actions"
  display_name              = "GitHub Actions"
  description               = "GitHub OIDC identities for the ${var.environment} BCH Analytics stack."

  depends_on = [google_project_service.required]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = google_iam_workload_identity_pool.github.project
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "GitHub Actions OIDC"
  description                        = "Accepts only the configured Astrafy repositories and protected refs."

  oidc {
    issuer_uri        = "https://token.actions.githubusercontent.com"
    allowed_audiences = ["sts.googleapis.com"]
  }

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.ref"              = "assertion.ref"
    "attribute.event_name"       = "assertion.event_name"
    "attribute.actor"            = "assertion.actor"
  }

  attribute_condition = local.github_attribute_condition

  lifecycle {
    precondition {
      condition     = var.github_dbt_repository != var.github_infrastructure_repository
      error_message = "The dbt and infrastructure repositories must be distinct so their WIF ref policies cannot be combined."
    }
  }
}

resource "google_service_account_iam_member" "dbt_wif" {
  service_account_id = google_service_account.dbt.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${google_project.this.number}/locations/global/workloadIdentityPools/github-actions/attribute.repository/${local.github_dbt_repository}"

  depends_on = [google_iam_workload_identity_pool_provider.github]
}

resource "google_service_account_iam_member" "terraform_plan_wif" {
  service_account_id = "projects/${var.state_project_id}/serviceAccounts/${var.terraform_plan_service_account_email}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${google_project.this.number}/locations/global/workloadIdentityPools/github-actions/attribute.repository/${local.github_infrastructure_repository}"

  lifecycle {
    precondition {
      condition     = endswith(var.terraform_plan_service_account_email, "@${var.state_project_id}.iam.gserviceaccount.com")
      error_message = "terraform_plan_service_account_email must belong to state_project_id."
    }
  }

  depends_on = [google_iam_workload_identity_pool_provider.github]
}

resource "google_project_iam_member" "terraform_plan_viewer" {
  project = google_project.this.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${var.terraform_plan_service_account_email}"
}

resource "google_project_iam_member" "terraform_plan_service_usage" {
  project = google_project.this.project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${var.terraform_plan_service_account_email}"
}

resource "google_billing_account_iam_member" "terraform_plan_viewer" {
  billing_account_id = var.billing_account_id
  role               = "roles/billing.viewer"
  member             = "serviceAccount:${var.terraform_plan_service_account_email}"
}
