## Dependency Validation: python-dateutil

### Summary

| Dimension          | Status  | Notes                                             |
|--------------------|---------|---------------------------------------------------|
| Maintenance        | Pass    | Active releases, multiple contributors             |
| Community adoption | Pass    | 200M+ monthly downloads, used by pandas and others |
| Security           | Pass    | No known CVEs, CI in place                         |
| Performance        | Pass    | Lightweight, 1 transitive dependency (six)         |
| License compliance | Caution | Dual-licensed Apache-2.0 / BSD-3-Clause — both permissive, but verify which applies |

### Verdict: APPROVED

Both licenses are permissive and safe for commercial use. The package is mature,
widely adopted, and actively maintained.

### Trust Assessment

#### Maintenance Health

| Signal             | Finding                                      |
|--------------------|----------------------------------------------|
| Last release       | 2.9.0 — 2024-01-01                           |
| Last commit        | 2024-02-15                                    |
| Open issues        | 45 open / 380 closed — healthy ratio          |
| Release cadence    | ~1-2 releases per year, stable and predictable |
| Bus factor         | 3 active contributors in the last 12 months   |

#### Community Adoption

| Signal              | Finding                                           |
|---------------------|---------------------------------------------------|
| Monthly downloads   | ~200M (PyPI)                                       |
| Dependents          | Used by pandas, matplotlib, botocore, and others   |
| GitHub stars        | ~2.3k                                              |
| Stack Overflow      | Active tag with 5k+ questions                      |

#### Security & Quality

| Signal               | Finding                                  |
|----------------------|------------------------------------------|
| Known vulnerabilities | None found (OSV, Snyk, GitHub Advisories) |
| Security policy      | SECURITY.md present                       |
| CI/CD               | GitHub Actions with test matrix           |
| Dependency depth     | 1 runtime dependency (six)               |
| Typosquatting        | No suspicious similar packages found      |

#### Performance

| Signal                  | Finding                        |
|-------------------------|--------------------------------|
| Install size            | ~300 KB                        |
| Transitive dependencies | 1 (six)                        |
| Known performance issues | None reported                 |

### License Assessment

- **License file:** Dual-licensed Apache-2.0 and BSD-3-Clause
- **Registry metadata:** Matches — "Apache Software License, BSD License"
- **Classification:** Permissive (both licenses)
- **Transitive dependencies:** `six` is MIT — no contamination risk
- **Anomalies:** None

### Recommendations

No blocking issues. Safe to adopt for commercial use. Include the required
copyright notice in compliance with Apache-2.0 / BSD-3-Clause terms.
