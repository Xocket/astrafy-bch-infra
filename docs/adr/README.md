# Architecture Decision Records

ADRs capture consequential choices at the time they are made. Accepted records are immutable in intent; a later decision supersedes an earlier record rather than silently rewriting history.

| ADR | Decision | Status |
|---|---|---|
| [0001](0001-environment-project-structure.md) | Environment-isolated analytics projects | Accepted |
| [0002](0002-bootstrap-remote-state.md) | Dedicated bootstrap stack and versioned GCS state | Accepted |
| [0003](0003-github-workload-identity.md) | Keyless GitHub Workload Identity Federation | Accepted |
| [0004](0004-bigquery-layout-and-iam.md) | Two datasets and dataset-scoped dbt write access | Accepted |
| [0005](0005-reviewable-gitops-delivery.md) | Reviewed local apply and read-only CI plan | Accepted |

Use `template.md` for new decisions. Valid lifecycle states are `Proposed`, `Accepted`, `Deprecated`, and `Superseded by ADR-NNNN`.
