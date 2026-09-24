variable "project_id" {
  description = "Google Cloud project ID for the analytics environment."
  type        = string
  nullable    = false

  validation {
    condition = (
      can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id)) &&
      !startswith(var.project_id, "replace-with")
    )
    error_message = "project_id must be a valid 6-30 character Google Cloud project ID and must not be a placeholder."
  }
}

variable "project_name" {
  description = "Human-readable name for the analytics project."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.project_name)) >= 4 && length(trimspace(var.project_name)) <= 30
    error_message = "project_name must contain 4 to 30 characters."
  }
}

variable "organization_id" {
  description = "Numeric Google Cloud organization ID under which the project is created."
  type        = string
  nullable    = false

  validation {
    condition = (
      can(regex("^[0-9]{6,26}$", var.organization_id)) &&
      lower(var.organization_id) != "replace-with-organization-id"
    )
    error_message = "organization_id must be the numeric Google Cloud organization ID and must not be a placeholder."
  }
}

variable "billing_account_id" {
  description = "Billing account ID attached to the project. It is not a credential, but is marked sensitive to reduce accidental disclosure."
  type        = string
  nullable    = false
  sensitive   = true

  validation {
    condition = (
      length(trimspace(var.billing_account_id)) > 0 &&
      lower(trimspace(var.billing_account_id)) != "replace-with-billing-account-id"
    )
    error_message = "billing_account_id must be a real billing account ID, not the checked-in placeholder."
  }
}

variable "environment" {
  description = "Environment represented by this state and project."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be either dev or prod."
  }
}

variable "state_project_id" {
  description = "Project ID created by the bootstrap stack; it contains remote Terraform state."
  type        = string
  nullable    = false

  validation {
    condition = (
      can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.state_project_id)) &&
      !startswith(var.state_project_id, "replace-with")
    )
    error_message = "state_project_id must be a real Google Cloud project ID from the bootstrap outputs."
  }
}

variable "state_bucket_name" {
  description = "Globally unique GCS bucket name created by the bootstrap stack."
  type        = string
  nullable    = false

  validation {
    condition = (
      length(var.state_bucket_name) >= 3 &&
      length(var.state_bucket_name) <= 63 &&
      can(regex("^[a-z0-9][a-z0-9._-]*[a-z0-9]$", var.state_bucket_name)) &&
      !startswith(var.state_bucket_name, "replace-with")
    )
    error_message = "state_bucket_name must be a valid 3-63 character GCS bucket name and must not be a placeholder."
  }
}

variable "terraform_plan_service_account_email" {
  description = "Bootstrap-managed, read-only Terraform plan service account used by GitHub Actions."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^bch-terraform-plan@[a-z][a-z0-9-]{4,28}[a-z0-9]\\.iam\\.gserviceaccount\\.com$", var.terraform_plan_service_account_email))
    error_message = "terraform_plan_service_account_email must be the bootstrap plan service account email."
  }
}

variable "bigquery_location" {
  description = "BigQuery dataset location."
  type        = string
  default     = "US"
  nullable    = false

  validation {
    condition = (
      can(regex("^[A-Za-z0-9]+(-[A-Za-z0-9]+)*$", var.bigquery_location)) &&
      lower(var.bigquery_location) != "replace-with-location"
    )
    error_message = "bigquery_location must be a valid Google Cloud location such as EU or US."
  }
}

variable "deletion_protection" {
  description = "Whether Google Cloud deletion protection is enabled for the analytics project."
  type        = bool
  default     = true
  nullable    = false
}

variable "delete_dataset_contents_on_destroy" {
  description = "Whether BigQuery dataset contents are deleted when a dataset is destroyed."
  type        = bool
  default     = false
  nullable    = false
}

variable "github_repository_owner" {
  description = "GitHub organization or user that owns the analytics and infrastructure repositories."
  type        = string
  nullable    = false

  validation {
    condition = (
      can(regex("^[A-Za-z0-9][A-Za-z0-9-]{0,38}$", var.github_repository_owner)) &&
      lower(var.github_repository_owner) != "replace-with-github-owner"
    )
    error_message = "github_repository_owner must be a real GitHub owner and must not be a placeholder."
  }
}

variable "github_dbt_repository" {
  description = "Repository allowed to impersonate the dbt service account through GitHub OIDC."
  type        = string
  nullable    = false

  validation {
    condition = (
      length(var.github_dbt_repository) <= 100 &&
      can(regex("^[A-Za-z0-9_.-]+$", var.github_dbt_repository)) &&
      lower(var.github_dbt_repository) != "replace-with-dbt-repository"
    )
    error_message = "github_dbt_repository must be a real GitHub repository name and must not be a placeholder."
  }
}

variable "github_infrastructure_repository" {
  description = "Infrastructure repository allowed to impersonate the read-only plan service account."
  type        = string
  default     = "astrafy-bch-infra"
  nullable    = false

  validation {
    condition = (
      length(var.github_infrastructure_repository) <= 100 &&
      can(regex("^[A-Za-z0-9_.-]+$", var.github_infrastructure_repository)) &&
      lower(var.github_infrastructure_repository) != "replace-with-infrastructure-repository"
    )
    error_message = "github_infrastructure_repository must be a valid GitHub repository name and must not be a placeholder."
  }
}

variable "source_project" {
  description = "Project containing the public Bitcoin Cash source dataset."
  type        = string
  default     = "bigquery-public-data"
  nullable    = false

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.source_project))
    error_message = "source_project must be a valid Google Cloud project ID."
  }
}

variable "source_dataset" {
  description = "Public Bitcoin Cash source dataset ID."
  type        = string
  default     = "crypto_bitcoin_cash"
  nullable    = false

  validation {
    condition     = length(trimspace(var.source_dataset)) > 0 && !can(regex("[^A-Za-z0-9_]", var.source_dataset))
    error_message = "source_dataset must be a valid BigQuery dataset ID."
  }
}

variable "labels" {
  description = "Additional Google Cloud labels merged with the standard workload labels."
  type        = map(string)
  default     = {}
  nullable    = false

  validation {
    condition = (
      alltrue([
        for key in keys(var.labels) : (
          length(key) <= 63 && can(regex("^[a-z][a-z0-9_-]*$", key))
        )
      ]) &&
      alltrue([
        for value in values(var.labels) : (
          length(value) <= 63 && can(regex("^[a-z0-9_-]*$", value))
        )
      ])
    )
    error_message = "labels must use GCP-compatible lowercase keys and values no longer than 63 characters."
  }
}
