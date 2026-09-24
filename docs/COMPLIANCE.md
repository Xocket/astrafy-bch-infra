# Compliance Evidence

This is the infrastructure repository's living evidence matrix. The canonical identifiers are defined in `docs/REQUIREMENTS.md` and the companion dbt repository.

| Requirement | Implementation | Verification | Status |
|---|---|---|---|
| `CC-1` | `google_project.this` in `main.tf` | Live dev project `astrafy-thc-006-xocket` applied; organization/project/billing outputs inspected | Verified |
| `CC-2` | `google_bigquery_dataset.this` and Terraform-managed source-access view | Live US `staging`/`marts` datasets and view metadata queried | Verified |
| `CC-3` | dbt service account, custom dataset-create/get role, `jobUser`, and dataset-scoped `dataEditor` bindings | IAM policy inspection plus successful live dbt run | Verified |
| `CC-4` | Bootstrap and primary stacks manage state, APIs, datasets, source view, WIF, IAM, and budget | Bootstrap/primary plans and applies completed; state bucket and budget verified | Verified |
| `CC-9` | GitHub OIDC pool/provider and exact numeric principal-set bindings | WIF resources and bindings inspected; infrastructure read-only plan authenticated successfully in [run 36054422871](https://github.com/Xocket/astrafy-bch-infra/actions/runs/36054422871) | Verified |
| `CC-11` | Independent `astrafy-bch-infra` repository | Public repository URL and history reviewed | Verified |
| `GEN-3` | Terraform validation and read-only planning workflow | `terraform validate`, pre-commit, and authenticated plan [run 36054422871](https://github.com/Xocket/astrafy-bch-infra/actions/runs/36054422871) | Verified |
| `NFR-1` | Partition-aware dbt workload, 100/50 GiB dbt caps, and EUR 2 alert budget | Approximately 958 GiB live DAG measured; budget and caps verified; no free-tier guarantee | Verified |
| `NFR-2` | Dataset-scoped dbt IAM and keyless CI | IAM review completed; authenticated plan [run 36054422871](https://github.com/Xocket/astrafy-bch-infra/actions/runs/36054422871) and dbt run [36054350409](https://github.com/Xocket/astrafy-bch-dbt/actions/runs/36054350409) both used WIF | Verified |
| `NFR-3` | Terraform/provider locks and pinned CI actions | `terraform fmt`, `validate`, pre-commit | Verified locally |
| `NFR-4` | State and credential ignores; no key resource | Secret scan and Git history review | Verified locally |

## Evidence rule

A status changes from **Implemented** to **Verified** only when the evidence is reproducible and non-secret. Local provider schema validation proves syntax and provider compatibility; it does not prove cloud permissions or successful creation.
