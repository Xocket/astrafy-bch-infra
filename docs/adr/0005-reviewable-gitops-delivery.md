# ADR-0005: Reviewed applies and read-only CI plans

- **Status:** Accepted
- **Date:** 2026-09-24
- **Requirements:** GEN-3, NFR-2, NFR-3

## Context

The challenge values a visible engineering journey. Fully autonomous CI apply would increase credential scope and make consequential project changes difficult to review.

## Decision

Run format and provider validation on relevant pull requests. After bootstrap and the initial local apply, run an authenticated read-only Terraform plan on `main` or manual dispatch and retain its redacted text artifact. Apply changes only through a reviewed local command.

## Rationale

This preserves GitOps reviewability while preventing the plan identity from mutating cloud infrastructure.

## Alternatives rejected

- CI apply on merge: faster, but grants write-capable credentials and hides operational review.
- No cloud CI plan: safer, but provides no repeatable evidence against drift.

## Consequences

Promotion includes a human-reviewed local apply followed by a CI plan. The plan identity intentionally has viewer access and the workflow disables state locking and contains no apply step.
