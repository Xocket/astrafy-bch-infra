project_id         = "replace-with-astrafy-bch-prod"
project_name       = "Astrafy BCH Analytics Prod"
organization_id    = "replace-with-organization-id"
billing_account_id = "replace-with-billing-account-id"
environment        = "prod"

state_project_id                     = "replace-with-state-project-id"
state_bucket_name                    = "replace-with-astrafy-bch-state-prod"
terraform_plan_service_account_email = "replace-with-plan-service-account@iam.gserviceaccount.com"

bigquery_location                  = "US"
deletion_protection                = true
delete_dataset_contents_on_destroy = false

github_repository_owner          = "replace-with-github-owner"
github_dbt_repository            = "bch-analytics-dbt"
github_infrastructure_repository = "bch-analytics-infra"

labels = {
  environment = "prod"
  managed_by  = "terraform"
  workload    = "bch-analytics"
}
