# ADR 0003: Terragrunt layout

## Status

Accepted, 2026-10-30

## Context

Three environments need the same modules with different inputs. Backend and provider blocks must not be copied into every unit.

## Decision

- One `root.hcl` generates the backend and provider blocks for every unit.
- One `env.hcl` per environment holds the environment name, labels and the module version pin.
- One directory per unit under `live/<env>/<unit>/` with a `terragrunt.hcl` that reads both files and declares `dependency` blocks where a unit needs another unit's outputs.
- AWS units use the emulator backend. Azure and GCP units validate only, because no real account is used.

## Consequences

- A backend change is one edit in `root.hcl`.
- `terragrunt run --all` orders units by their dependency blocks.
- Azure and GCP units never reach plan, so their live wiring is checked by `validate` and policy only.
