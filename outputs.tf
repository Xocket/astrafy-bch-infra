output "project" {
  description = "Analytics project identifiers."
  value = {
    id     = google_project.this.project_id
    name   = var.project_name
    number = google_project.this.number
  }
}

output "source_dataset" {
  description = "Public source dataset used by the dbt project."
  value       = "${var.source_project}.${var.source_dataset}"
}

output "source_access_view" {
  description = "Terraform-managed view that exposes the required public source to the dbt identity."
  value       = "${google_project.this.project_id}.${google_bigquery_dataset.this["staging"].dataset_id}.${google_bigquery_table.source_access_view.table_id}"
}

output "enabled_services" {
  description = "Google Cloud APIs enabled by the analytics stack."
  value       = sort(tolist(local.required_services))
}

output "bigquery_datasets" {
  description = "Fully qualified BigQuery dataset IDs used by dbt."
  value = {
    for name, dataset in google_bigquery_dataset.this :
    name => "${dataset.project}.${dataset.dataset_id}"
  }
}

output "dbt_service_account" {
  description = "Identity used by the dbt repository and GitHub Actions."
  value = {
    email = google_service_account.dbt.email
    name  = google_service_account.dbt.name
  }
}

output "workload_identity" {
  description = "Keyless GitHub Actions Workload Identity Federation configuration."
  value = {
    pool_id     = google_iam_workload_identity_pool.github.workload_identity_pool_id
    provider_id = google_iam_workload_identity_pool_provider.github.workload_identity_pool_provider_id
    provider    = google_iam_workload_identity_pool_provider.github.name
    audience    = "sts.googleapis.com"
  }
}

output "github_actions_wif" {
  description = "Non-secret values for google-github-actions/auth configuration."
  value = {
    dbt = {
      workload_identity_provider = google_iam_workload_identity_pool_provider.github.name
      service_account            = google_service_account.dbt.email
    }
    terraform_plan = {
      workload_identity_provider = google_iam_workload_identity_pool_provider.github.name
      service_account            = var.terraform_plan_service_account_email
    }
  }
}

output "remote_backend" {
  description = "Remote GCS backend values for this environment."
  value = {
    bucket = var.state_bucket_name
    prefix = "astrafy-bch-analytics/${var.environment}"
  }
}
