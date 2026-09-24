# Requirements and Traceability

The canonical requirement identifiers and ambiguity register live in the companion dbt repository:

- Repository: `astrafy-bch-dbt`
- Document: `docs/REQUIREMENTS.md`

This repository owns the infrastructure-facing subset of that contract:

| IDs | Ownership |
|---|---|
| `CC-1`–`CC-4` | Terraform project, BigQuery datasets, service account/IAM, and Terraform-managed supporting resources |
| `CC-9` | Workload Identity Federation used by CI |
| `CC-11` | Terraform deliverable repository |
| `GEN-2`, `GEN-3` | Ecosystem tools, CI/CD, and infrastructure as code |
| `NFR-1`–`NFR-4` | Cost guardrails, least privilege, reproducibility, and secret/state exclusion |

The dbt repository owns `CC-5`–`CC-8`, `CC-10`, and `CC-12` while linking back to the infrastructure evidence here. Requirement statuses are updated only after live verification; a successful static validation is not presented as a cloud apply.
