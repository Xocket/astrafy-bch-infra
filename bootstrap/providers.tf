provider "google" {}

provider "google" {
  alias                 = "budget"
  billing_project       = var.state_project_id
  user_project_override = true
}
