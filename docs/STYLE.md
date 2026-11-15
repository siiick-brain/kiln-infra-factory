# Writing style

## Audience

Infrastructure engineers, security engineers, platform engineers and technical reviewers.

## Principles

- Write direct technical English in active voice.
- Define a term at first use. Use the term from [GLOSSARY.md](GLOSSARY.md) after that.
- Keep paragraphs short. Write in the present tense.
- State facts and measurements only. Do not use marketing language.
- Every result names its command, date and artifact.
- Use one status word per claim: Verified, Not verified, Planned or Not deployed.

## Punctuation

- Do not use em dashes or en dashes.
- Do not put a comma before "and". Write "a, b and c".
- Join full clauses with a period or with "so". Never write "and," in prose.
- Avoid a comma before "or".
- These rules do not apply to commands, code, quoted text or identifiers.

## Format

- Dates use ISO 8601, for example 2026-11-15.
- Headings use sentence case.
- Link text describes the target. Do not write "click here".
- Commit titles follow Conventional Commits, for example `feat(pki): add OCSP responder`.

## Enforcement

`scripts/check-style.ps1` runs before every commit with `-Staged` and in CI over the whole tree.
It prints one line per finding and exits 1 on any FAIL.
Exceptions live in `.style-allow`, one per line as `path-glob|exact text`, each with a comment that gives the reason.
