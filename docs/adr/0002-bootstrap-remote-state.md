# ADR-0002: Bootstrap remote Terraform state

- **Status:** Accepted
- **Date:** 2026-09-24
- **Requirements:** CC-4, NFR-3, NFR-4

## Context

The primary stack creates a new project, while its remote backend must exist before Terraform can initialize that project. A bucket cannot bootstrap itself.

## Decision

Use a separate bootstrap stack to create a dedicated state project, one private versioned GCS bucket, and a read-only CI plan identity. The bootstrap stack keeps local, gitignored state; primary states use environment-specific prefixes.

## Rationale

This makes the dependency order explicit and keeps the challenge project under Terraform control. Versioning and public-access prevention reduce state-loss and disclosure risk.

## Alternatives rejected

- Local state for all environments: avoids bootstrap complexity but weakens collaboration and recovery.
- Store state in an analytics project: creates a circular dependency and mixes runtime data with control-plane state.

## Consequences

The bootstrap state must be preserved securely. Bucket deletion is intentionally disabled, and archived object versions expire only after the configured retention period.
