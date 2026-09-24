# ADR-0003: GitHub Workload Identity Federation

- **Status:** Accepted
- **Date:** 2026-09-24
- **Requirements:** CC-9, NFR-2

## Context

CI must authenticate as the Terraform-provisioned service account without storing a long-lived JSON key.

## Decision

Create a GitHub OIDC workload identity pool and provider. Restrict attributes by owner, repository, event, actor, and allowed refs, then bind exact principal sets to the dbt and read-only Terraform plan service accounts. Development pull-request execution is limited to the configured repository owner so an untrusted fork cannot use the write-capable dbt identity.

## Rationale

Workload Identity Federation removes static credentials from GitHub and supports least-privilege, repository-specific access.

## Alternatives rejected

- Service-account JSON key in GitHub Secrets: simpler to debug but creates a durable credential and rotation burden.
- Long-lived Google Cloud access token: operationally fragile and unsuitable for automation.

## Consequences

OIDC trust configuration must exactly match repository names and event refs. Pull requests from forks receive no repository secrets from GitHub, and CI remains read-only with respect to cloud infrastructure.
