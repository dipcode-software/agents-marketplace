---
name: validate-dependency
version: 0.1.0
description: >
  This skill should be used when the user asks to "validate a dependency",
  "check if this library is safe to use", "review a package before adding it",
  "audit a dependency", "check the license of a package", "is this library
  maintained", "evaluate a third-party library", "vet this dependency",
  "can I use this package commercially", "check dependency health", "should I
  use this library", "is this package secure", "dependency risk assessment",
  or mentions assessing the trustworthiness, license compliance, security
  posture, or maintenance status of a third-party package or library before
  adopting it.
---

# Validate Dependency

Evaluate a third-party dependency across two dimensions before adoption:
**trustworthiness** (maintenance health, security posture, community adoption)
and **license compliance** (commercial use compatibility).

## When to Use

Run this validation before adding any new third-party dependency to a project,
or when re-evaluating an existing dependency (e.g., after a security advisory or
before a major version upgrade).

## Workflow

### Step 1: Identify the Dependency

Determine the package name, ecosystem, and the source repository from:

1. **User input** — name, URL, or package specifier (e.g., `requests`, `lodash@4`, `github.com/org/repo`)
2. **Project context** — a dependency listed in `requirements.txt`, `pyproject.toml`, `package.json`, `go.mod`, `Cargo.toml`, `Gemfile`, `pom.xml`, or similar manifest

Resolve the canonical source repository (typically GitHub/GitLab) and the
package registry page (PyPI, npm, crates.io, etc.) for the dependency.

### Step 2: Assess Trustworthiness

Collect the following signals. Use web searches and registry/repository pages to
gather data. Present findings in a structured table.

#### 2.1 Maintenance Health

| Signal | How to check | Warning threshold |
|---|---|---|
| Last release date | Registry page or GitHub releases | > 12 months without a release |
| Last commit date | Repository commit history | > 6 months without commits |
| Open issues count | Repository issues tab | High count with no triage activity |
| Open issues trend | Compare open vs. closed over recent months | Growing backlog with few closures |
| Release cadence | Release history | Irregular or stalled after active period |
| Bus factor | Contributors page | Single maintainer with no recent co-contributors |

#### 2.2 Community Adoption

| Signal | How to check | Positive indicator |
|---|---|---|
| Downloads / installs | Registry stats (PyPI, npm, crates.io, etc.) | Consistent or growing download trend |
| Dependents count | Registry "used by" or GitHub dependents | Used by well-known projects |
| GitHub stars & forks | Repository page | Relative to the ecosystem norm |
| Stack Overflow presence | Web search | Active Q&A community |

#### 2.3 Security & Quality

| Signal | How to check | Warning threshold |
|---|---|---|
| Known vulnerabilities | Search CVE databases, GitHub Security Advisories, Snyk, OSV | Any unpatched CVE |
| Security policy | `SECURITY.md` or repository security tab | Absent — no responsible disclosure process |
| CI/CD presence | Repository actions/pipelines | No automated testing |
| Dependency tree depth | Registry dependency list | Excessively deep or wide tree — larger supply-chain surface |
| Typosquatting risk | Verify exact package name on registry | Similar names with different authors |

#### 2.4 Performance Considerations

| Signal | How to check | Warning threshold |
|---|---|---|
| Bundle / install size | Registry page or `bundlephobia.com` (JS), install footprint | Unusually large relative to functionality provided |
| Transitive dependencies | Count of pulled-in sub-dependencies | Excessive sub-dependency count for a simple task |
| Known performance issues | Search repo issues for "slow", "performance", "memory" labels | Unresolved issues with significant impact |

### Step 3: Validate License Compliance

Verify the dependency can be used in a **commercial / proprietary** project.

#### 3.1 Identify the License

- Check the `LICENSE` or `COPYING` file at the repository root
- Cross-check with the registry metadata (PyPI classifiers, npm `license` field, etc.)
- When dual-licensed, identify which license applies to commercial use

#### 3.2 Classify the License

Refer to the license compatibility reference for classification:

- **`references/license-compatibility.md`** — License categories, commercial
  compatibility matrix, and common edge cases

Quick classification:

| Category | Examples | Commercial use |
|---|---|---|
| Permissive | MIT, Apache-2.0, BSD-2/3-Clause, ISC, Unlicense | Safe |
| Weak copyleft | LGPL-2.1, LGPL-3.0, MPL-2.0 | Safe if used as a library (not modified/statically linked) |
| Strong copyleft | GPL-2.0, GPL-3.0, AGPL-3.0 | Incompatible — derivative work must be open-sourced |
| Non-commercial | CC-BY-NC, custom "non-commercial" clauses | Incompatible |
| No license | No LICENSE file found | Incompatible — all rights reserved by default |

#### 3.3 Check for License Anomalies

- **Transitive license contamination** — scan key dependencies for copyleft licenses that may propagate
- **License file vs. metadata mismatch** — flag if the registry says MIT but the repo has GPL
- **Custom or modified licenses** — flag for manual legal review

### Step 4: Produce the Validation Report

Present a structured report with a clear verdict.

```
## Dependency Validation: <package-name>

### Summary

| Dimension           | Status | Notes                        |
|---------------------|--------|------------------------------|
| Maintenance         | ...    | ...                          |
| Community adoption  | ...    | ...                          |
| Security            | ...    | ...                          |
| Performance         | ...    | ...                          |
| License compliance  | ...    | ...                          |

### Verdict: APPROVED / CAUTION / REJECTED

<Brief justification and any conditions or follow-up actions>

### Trust Assessment
<Detailed findings from Step 2>

### License Assessment
<Detailed findings from Step 3>

### Recommendations
<Any mitigation actions, alternatives to consider, or conditions for approval>
```

**Status values:**

- **Pass** — no concerns
- **Caution** — minor risks; acceptable with noted conditions
- **Fail** — blocking issue found

**Verdict logic:**

- **APPROVED** — all dimensions Pass or Caution with acceptable mitigations
- **CAUTION** — one or more Caution items that warrant team discussion
- **REJECTED** — any Fail in security or license compliance, or multiple Fails elsewhere

### Step 5: Suggest Alternatives (if rejected)

When a dependency is rejected, search for alternative packages that serve the
same purpose and run a lighter-weight comparison (maintenance health + license)
on the top 2–3 candidates.

## Additional Resources

### Reference Files

- **`references/license-compatibility.md`** — Detailed license classification,
  commercial compatibility matrix, dual-licensing guidance, and transitive
  contamination rules

### Example Files

- **`examples/sample-report.md`** — Completed validation report for
  `python-dateutil`, demonstrating the expected output format and level of detail
