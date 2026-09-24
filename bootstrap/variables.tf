variable "state_project_id" {
  description = "Google Cloud project ID dedicated to Terraform state."
  type        = string
  nullable    = false

  validation {
    condition = (
      can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.state_project_id)) &&
      !startswith(var.state_project_id, "replace-with")
    )
    error_message = "state_project_id must be a valid 6-30 character Google Cloud project ID and must not be a placeholder."
  }
}

variable "state_project_name" {
  description = "Human-readable name for the Terraform state project."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.state_project_name)) >= 4 && length(trimspace(var.state_project_name)) <= 30
    error_message = "state_project_name must contain 4 to 30 characters."
  }
}

variable "organization_id" {
  description = "Numeric Google Cloud organization ID under which the state project is created."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9]{6,26}$", var.organization_id))
    error_message = "organization_id must be the numeric Google Cloud organization ID."
  }
}

variable "billing_account_id" {
  description = "Billing account ID attached to the state project. It is not a credential, but is marked sensitive to reduce accidental disclosure."
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

variable "state_bucket_name" {
  description = "Globally unique GCS bucket name for versioned Terraform state."
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

variable "storage_location" {
  description = "GCS location for the Terraform state bucket."
  type        = string
  default     = "EU"
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z0-9]+(-[A-Za-z0-9]+)*$", var.storage_location))
    error_message = "storage_location must be a valid Google Cloud location such as EU or US."
  }
}

variable "noncurrent_version_retention_days" {
  description = "Days to retain archived Terraform state object versions before lifecycle cleanup."
  type        = number
  default     = 90
  nullable    = false

  validation {
    condition     = var.noncurrent_version_retention_days >= 30 && var.noncurrent_version_retention_days <= 3650
    error_message = "noncurrent_version_retention_days must be between 30 and 3650."
  }
}

variable "budget_amount" {
  description = "Monthly alert threshold in the billing account currency; alerts do not cap spend."
  type        = number
  default     = 2
  nullable    = false

  validation {
    condition     = var.budget_amount > 0 && var.budget_amount <= 100
    error_message = "budget_amount must be between 0 and 100 in the billing account currency."
  }
}

variable "budget_currency_code" {
  description = "ISO 4217 currency code used by the billing account budget."
  type        = string
  default     = "EUR"
  nullable    = false

  validation {
    condition     = can(regex("^[A-Z]{3}$", var.budget_currency_code))
    error_message = "budget_currency_code must be a three-letter uppercase ISO 4217 code."
  }
}

variable "labels" {
  description = "Additional Google Cloud labels merged with standard bootstrap labels."
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
