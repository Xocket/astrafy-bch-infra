project_id         = "replace-with-astrafy-bch-dev"
project_name       = "Astrafy BCH Analytics Dev"
organization_id    = "replace-with-organization-id"
billing_account_id = "replace-with-billing-account-id"
environment        = "dev"

state_project_id                     = "replace-with-state-project-id"
state_bucket_name                    = "replace-with-astrafy-bch-state-dev"
terraform_plan_service_account_email = "replace-with-plan-service-account@iam.gserviceaccount.com"

bigquery_location                  = "US"
deletion_protection                = false
delete_dataset_contents_on_destroy = true

github_repository_owner          = "replace-with-github-owner"
github_dbt_repository            = "bch-analytics-dbt"
github_infrastructure_repository = "bch-analytics-infra"

labels = {
  environment = "dev"
  managed_by  = "terraform"
  workload    = "bch-analytics"
}
