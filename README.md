# BCH Analytics Infrastructure

[![Terraform CI](https://github.com/Xocket/astrafy-bch-infra/actions/workflows/terraform.yml/badge.svg)](https://github.com/Xocket/astrafy-bch-infra/actions/workflows/terraform.yml)

Terraform for the Astrafy BCH analytics challenge. It provisions
isolated Google Cloud projects, BigQuery datasets, a least-privilege dbt
service account, keyless GitHub authentication, and versioned remote
state.

Status: verified. Both stacks are applied for the dev environment; CI
formats, validates, and produces a read-only plan with workload
identity. No workflow can apply.

- Requirements: [`docs/REQUIREMENTS.md`](docs/REQUIREMENTS.md)
- Evidence: [`docs/COMPLIANCE.md`](docs/COMPLIANCE.md)
- Decisions: [`docs/adr/`](docs/adr/)
- dbt repository: https://github.com/Xocket/astrafy-bch-dbt

## Stack

| Area | Implementation |
|---|---|
| Remote state | Versioned private GCS bucket, uniform access, public access prevention, 90-day noncurrent cleanup |
| Cost guardrail | EUR 2 monthly budget, alerts at 50/90/100%; alerts do not stop spending |
| Bootstrap APIs | Billing, Budgets, IAM, IAM Credentials, Service Usage, Storage |
| Analytics project | One `dev` or `prod` project per state prefix; deletion protection on in prod |
| Project APIs | BigQuery, Billing, Resource Manager, IAM, IAM Credentials, Service Usage, Storage |
| BigQuery | `staging` and `marts` datasets in US, co-located with the public source |
| dbt identity | `jobUser` plus a custom dataset-create/get role; `dataEditor` on the two owned datasets only |
| Source view | Terraform-managed `bch_transactions_source` view over the public table; dbt never edits the public dataset |
| GitHub auth | Workload Identity Federation with owner/repository/ref/event/actor conditions |
| Plan identity | Bootstrap service account: state read plus project and billing metadata view; it cannot write anything |
| Local safeguards | Format/validate commands, pre-commit, sensitive variables, placeholder rejection, ignores |

No provider credentials or service-account keys are accepted as
variables. Checked-in `tfvars` hold placeholders; variable validation
rejects them during a real plan.

## Layout

```text
├── bootstrap/            # state project, state bucket, read-only plan identity
├── environments/         # dev.tfvars, prod.tfvars (placeholders)
├── main.tf               # project, APIs, datasets, service accounts, IAM, WIF
├── docs/                 # requirements, evidence, ADRs
└── .github/workflows/    # fmt, validate, keyless read-only plan
```

## Prerequisites

- Terraform `>= 1.6.6, < 2.0.0`; CI pins `1.16.4`
- Google Cloud CLI with application-default credentials
- Billing enabled; `roles/resourcemanager.projectCreator` on the
  organization; `roles/billing.user` on the billing account; permission
  to grant `roles/iam.workloadIdentityUser` and `roles/billing.viewer`
- Unique project IDs and a globally unique state bucket name
- Docker for the Terraform pre-commit hook (optional); GNU Make optional

## Bootstrap the state (once)

A bucket cannot be its own first backend. The bootstrap stack creates
the state project, the bucket, and the plan identity. Its own state is
local and gitignored; keep it safe — it is the root of trust.

```powershell
terraform -chdir=bootstrap init
terraform -chdir=bootstrap plan -var-file="environments/shared.tfvars"
terraform -chdir=bootstrap apply -var-file="environments/shared.tfvars"
terraform -chdir=bootstrap output
```

## Configure an environment

Fill `environments/dev.tfvars` with the bootstrap outputs and your
project, organization, billing, and GitHub owner values, then:

```powershell
terraform init `
  -backend-config="bucket=<bootstrap-state-bucket>" `
  -backend-config="prefix=astrafy-bch-analytics/dev"

terraform fmt -check -recursive
terraform validate
terraform plan -input=false -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

Use `prod.tfvars` and the `astrafy-bch-analytics/prod` prefix for
production. `prod` stays a validated configuration until promotion is
approved. `Makefile` targets mirror these commands; there is
intentionally no CI apply and no `make destroy`.

## Workload Identity Federation

The provider maps GitHub's `sub`, `repository`, `repository_owner`,
`ref`, `event_name`, and `actor` claims. The CEL condition permits the
dbt repository on `main` plus owner-initiated pull requests in
development, the infrastructure repository on `main` only, and nothing
else. Two exact principal-set bindings point at the dbt and plan
identities. There is no service-account-key resource and no JSON-key
fallback.

## CI and variables

`terraform.yml` has two jobs. Format and validate run on every relevant
event without credentials. The read-only plan runs on `main` and manual
dispatch once the variables exist: it authenticates with OIDC, reads
versioned state, runs `terraform plan -lock=false`, and keeps a
redacted plan artifact for 14 days. There is no apply step.

Configure these repository **Actions variables** after the first
applies (identifiers, not credentials):

| Variable | Source |
|---|---|
| `TF_ENVIRONMENT` | `dev` or `prod` |
| `TF_STATE_BUCKET` | Bootstrap `state_bucket_name` output |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | Primary `workload_identity.provider` output |
| `GCP_PLAN_SERVICE_ACCOUNT` | Bootstrap `terraform_plan_service_account.email` output |
| `GCP_STATE_PROJECT_ID` | Bootstrap `state_project_id` output |
| `GCP_PROJECT_ID`, `GCP_PROJECT_NAME`, `GCP_ORGANIZATION_ID`, `GCP_BILLING_ACCOUNT_ID` | Matching primary inputs |
| `REPOSITORY_OWNER`, `DBT_REPOSITORY`, `INFRASTRUCTURE_REPOSITORY` | GitHub owner and repository names |

## Local checks

```powershell
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform -chdir=bootstrap init -backend=false
terraform -chdir=bootstrap validate
pre-commit run --all-files
```

State, plan, and credential files are gitignored. Do not bypass those
defaults.
