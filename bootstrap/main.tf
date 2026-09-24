locals {
  common_labels = merge(var.labels, {
    environment = "shared"
    managed_by  = "terraform"
    workload    = "terraform-state"
  })
}

resource "google_project" "state" {
  project_id      = var.state_project_id
  name            = var.state_project_name
  org_id          = var.organization_id
  billing_account = var.billing_account_id
  deletion_policy = "PREVENT"
  labels          = local.common_labels
}

resource "google_project_service" "required" {
  for_each = toset([
    "billingbudgets.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
  ])

  project            = google_project.state.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_service_account" "terraform_plan" {
  account_id   = "bch-terraform-plan"
  display_name = "BCH Terraform CI plan"
  description  = "Read-only identity used by GitHub Actions to authenticate and plan; it cannot apply changes."
  project      = google_project.state.project_id

  depends_on = [google_project_service.required]
}

resource "google_project_iam_member" "plan_state_service_account_viewer" {
  project = google_project.state.project_id
  role    = "roles/iam.serviceAccountViewer"
  member  = "serviceAccount:${google_service_account.terraform_plan.email}"
}

resource "google_storage_bucket" "state" {
  name                        = var.state_bucket_name
  project                     = google_project.state.project_id
  location                    = var.storage_location
  storage_class               = "STANDARD"
  force_destroy               = false
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  labels                      = local.common_labels

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      days_since_noncurrent_time = var.noncurrent_version_retention_days
      with_state                 = "ARCHIVED"
    }
  }

  depends_on = [google_project_service.required]
}

resource "google_storage_bucket_iam_member" "plan_state_reader" {
  bucket = google_storage_bucket.state.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.terraform_plan.email}"
}

resource "google_billing_budget" "guardrail" {
  provider        = google.budget
  billing_account = var.billing_account_id
  display_name    = "Astrafy THC-006 monthly alert"

  amount {
    specified_amount {
      currency_code = var.budget_currency_code
      units         = var.budget_amount
    }
  }

  threshold_rules {
    threshold_percent = 0.5
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 0.9
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "CURRENT_SPEND"
  }
}
