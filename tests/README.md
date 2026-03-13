# longmem tests

Automated tests for longmem template integrity.

## Usage

```bash
bash tests/run-all.sh
```

Run from the repo root.

## Tests

- **test-integrity.sh** — Cross-reference and consistency checks (File Map, orphans, links)
- **test-hashes.sh** — Template drift detection via SHA256 baseline
- **test-smoke.sh** — Activation and sync verification in a temp clone

## Requirements

bash, git. No other dependencies.

## When to run

Before committing changes. Before releases. After modifying any `.longmem/` file.
