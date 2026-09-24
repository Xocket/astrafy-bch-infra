state_project_id                  = "replace-with-astrafy-bch-state"
state_project_name                = "Astrafy BCH Terraform State"
organization_id                   = "replace-with-organization-id"
billing_account_id                = "replace-with-billing-account-id"
state_bucket_name                 = "replace-with-astrafy-bch-state"
storage_location                  = "EU"
noncurrent_version_retention_days = 90
budget_amount                     = 2
budget_currency_code              = "EUR"

labels = {
  environment = "shared"
  managed_by  = "terraform"
  workload    = "terraform-state"
}
