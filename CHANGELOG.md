# Changelog

All notable changes to this project are documented in this file. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses semantic versioning.

## [Unreleased]

### Added

- Initial repository scaffold and safe local-state defaults.
- Terraform `>= 1.6.6, < 2.0.0` and HashiCorp Google provider `~> 8.3.0` constraints with generated lock files for both stacks.
- Primary dev/prod project, API, BigQuery dataset, dbt service-account, least-privilege IAM, custom dataset-create role, Terraform-managed source-access view, deletion-protection, and remote-backend configuration.
- A separate bootstrap stack with a dedicated state project, private versioned GCS bucket, noncurrent-state lifecycle, read-only CI plan identity, and a EUR 2 budget alert.
- GitHub OIDC Workload Identity Federation with exact repository/ref/event/actor CEL conditions, numeric-project principal sets, and separate dbt and Terraform-plan service-account bindings.
- Non-secret dev/prod/shared tfvars templates that reject unresolved placeholders.
- Outputs for projects, datasets, WIF, service accounts, and backend configuration.
- Make targets, pinned pre-commit hooks, and commit-pinned GitHub Actions for recursive format, both-stack validation, keyless read-only planning, and redacted plan artifacts.
- README bootstrap, environment, WIF, CI-variable, and verification instructions.
- Initial CI quality remains runnable before cloud identifiers and WIF variables are configured; authenticated planning starts only after setup.
- Verified static Terraform CI workflow and live status badge.
- Enabled Billing Budgets, IAM Service Account Credentials, and Service Usage in the appropriate projects so the EUR 2 guardrail, quota project, and keyless token exchange work through Terraform.

### Changed

- README condensed to the stack, commands, CI behavior, and variables.
- `NFR-2` evidence updated: the WIF plan run and the dbt pull-request run
  both authenticated, so the requirement is verified.

### Security

- No service-account key resource, credential variable, real credential, or Terraform state is included.
- CI uses a bootstrap-managed identity with state object-read plus project and billing viewer roles only; planning disables the state lock and no workflow can apply.
- Billing account variables are marked sensitive, public access is blocked on the state bucket, uniform bucket access is enforced, and local credential/state patterns are gitignored.
