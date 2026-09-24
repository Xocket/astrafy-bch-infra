output "state_project_id" {
  description = "Project containing the remote Terraform state bucket."
  value       = google_project.state.project_id
}

output "state_bucket_name" {
  description = "Versioned GCS bucket used by the primary stack."
  value       = google_storage_bucket.state.name
}

output "terraform_plan_service_account" {
  description = "Bootstrap-managed identity used by CI for read-only planning."
  value = {
    email = google_service_account.terraform_plan.email
    name  = google_service_account.terraform_plan.name
  }
}

output "remote_backend" {
  description = "Values required to configure the primary stack's GCS backend."
  value = {
    bucket      = google_storage_bucket.state.name
    dev_prefix  = "astrafy-bch-analytics/dev"
    prod_prefix = "astrafy-bch-analytics/prod"
  }
}
