# ADR-0004: BigQuery layout and dbt IAM

- **Status:** Accepted
- **Date:** 2026-09-24
- **Requirements:** CC-2, CC-3, NFR-2

## Context

dbt must create and replace tables in owned datasets while reading a public source dataset. Broad project-level write access would exceed the challenge's needs.

## Decision

Create only `staging` and `marts` datasets for analytics output. Grant the dbt service account `bigquery.jobUser` on the project and `bigquery.dataEditor` on those two datasets only. Do not grant access to the public source.

## Rationale

Dataset-scoped write permissions allow dbt execution while preventing unrelated project dataset writes. Public BigQuery datasets do not require an explicit viewer grant for public objects.

## Alternatives rejected

- Project-level BigQuery Data Editor: simpler but unnecessarily broad.
- Viewer-only dbt identity: cannot materialize models.
- Additional curated/reference datasets: not required by the accepted model graph.

## Consequences

New output datasets require an intentional Terraform and IAM update. Dataset location must be shared by Terraform and dbt profiles.
