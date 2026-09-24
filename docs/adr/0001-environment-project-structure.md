# ADR-0001: Environment-isolated analytics projects

- **Status:** Accepted
- **Date:** 2026-09-24
- **Requirements:** CC-1, NFR-2

## Context

The challenge requires a new Google Cloud project, while repeatable delivery benefits from separating development and production state and credentials.

## Decision

Maintain one `dev` project and an independently managed `prod` project, selected through explicit variable files and separate remote-state prefixes. A shared bootstrap project owns remote state only.

## Rationale

Project isolation prevents a production dataset or service account from being reachable through development CI. The approach still creates real infrastructure through Terraform and keeps the challenge implementation auditable.

## Alternatives rejected

- One shared project: simpler, but weaker blast-radius control.
- A folder per environment: stronger hierarchy, but unnecessary for this submission and dependent on organization structure.

## Consequences

Bootstrap and environment variables must be maintained carefully. Only the environment being evaluated needs a live apply; the other remains a validated configuration until promotion is justified.
