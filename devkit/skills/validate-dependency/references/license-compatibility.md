# License Compatibility Reference

Detailed classification of open-source licenses and their compatibility with
commercial / proprietary software projects.

## License Categories

### Permissive Licenses (Commercial-Safe)

These licenses impose minimal restrictions. Code can be used, modified, and
distributed in proprietary projects with attribution.

| License | SPDX ID | Key obligations |
|---|---|---|
| MIT License | MIT | Include copyright notice and license text |
| Apache License 2.0 | Apache-2.0 | Include notice, state changes, patent grant |
| BSD 2-Clause | BSD-2-Clause | Include copyright notice |
| BSD 3-Clause | BSD-3-Clause | Include copyright notice, no endorsement clause |
| ISC License | ISC | Include copyright notice |
| The Unlicense | Unlicense | None — public domain dedication |
| Creative Commons Zero | CC0-1.0 | None — public domain dedication |
| zlib License | Zlib | Include notice in source distributions |
| Boost Software License | BSL-1.0 | Include notice in source distributions |

### Weak Copyleft Licenses (Conditionally Safe)

Modifications to the licensed component must be shared, but proprietary code
that merely links to or uses the component as a library is not affected.

| License | SPDX ID | Safe usage pattern | Risk pattern |
|---|---|---|---|
| LGPL 2.1 | LGPL-2.1-only | Dynamic linking, unmodified library | Static linking, modifying library source |
| LGPL 3.0 | LGPL-3.0-only | Dynamic linking, unmodified library | Static linking, modifying library source |
| Mozilla Public License 2.0 | MPL-2.0 | Using unmodified files | Modifying MPL-licensed files (changes must be shared) |
| Eclipse Public License 2.0 | EPL-2.0 | Using as a library | Distributing modified EPL modules |
| Common Development and Distribution License | CDDL-1.0 | Using as a library | Modifying CDDL-licensed files |

**Key rule for weak copyleft:** if the dependency is used as-is (imported as a
package, dynamically linked), it is generally safe for commercial use. If the
source code of the dependency itself is modified and distributed, those
modifications must be released under the same license.

### Strong Copyleft Licenses (Commercial-Incompatible)

Any work that incorporates or links to code under these licenses may be
considered a derivative work and must be distributed under the same license —
effectively requiring the entire project to be open-sourced.

| License | SPDX ID | Impact |
|---|---|---|
| GPL 2.0 | GPL-2.0-only | Derivative works must be GPL-2.0 |
| GPL 3.0 | GPL-3.0-only | Derivative works must be GPL-3.0, includes patent provisions |
| AGPL 3.0 | AGPL-3.0-only | Like GPL-3.0 but also triggered by network use (SaaS) |
| European Union Public License | EUPL-1.2 | Similar to GPL; strong copyleft with broad scope |

**AGPL special case:** AGPL extends copyleft to server-side use. If a
dependency is AGPL-licensed and the application is served over a network (web
app, API), the entire application source may need to be disclosed. This is the
most restrictive common license for SaaS/commercial use.

### Non-Commercial / Restricted Licenses

Explicitly prohibit commercial use or impose restrictions incompatible with
proprietary software.

| License | SPDX ID | Restriction |
|---|---|---|
| Creative Commons BY-NC | CC-BY-NC-4.0 | No commercial use |
| Creative Commons BY-NC-SA | CC-BY-NC-SA-4.0 | No commercial use + share-alike |
| Server Side Public License | SSPL-1.0 | Requires open-sourcing the entire service stack |
| Business Source License | BUSL-1.1 | Commercial use restricted until change date |
| Elastic License 2.0 | Elastic-2.0 | No competing SaaS offerings |
| Commons Clause | N/A (modifier) | No selling the software as a service |

### No License

When a repository has **no LICENSE file**, all rights are reserved by default
under copyright law. The code cannot be legally used, modified, or distributed.
Treat as **incompatible** and do not adopt.

## Dual Licensing

Some projects offer dual licensing (e.g., GPL + Commercial). In this case:

- Identify which license applies to the intended use
- Commercial licenses typically require purchasing a separate license
- If only the copyleft license is free, the dependency is not commercially safe
  without purchasing the commercial license

Common dual-license patterns:

| Pattern | Example | Commercial path |
|---|---|---|
| GPL + Commercial | MySQL, Qt | Purchase commercial license |
| AGPL + Commercial | MongoDB (historical) | Purchase commercial license |
| MIT + Apache-2.0 | Rust compiler | Use either — both are permissive |

## Transitive License Contamination

A dependency's own dependencies may carry licenses more restrictive than the
direct dependency. This is called transitive contamination.

**Assessment process:**

1. List direct dependencies of the package (from its manifest)
2. Check licenses of the top-level direct dependencies
3. Flag any strong copyleft license in the tree
4. Pay special attention to compile-time / bundled dependencies (not just
   runtime) — these are more likely to trigger copyleft provisions

**Common safe patterns:**
- Development-only dependencies (test frameworks, linters) do not affect
  distribution and are generally exempt
- Optional / peer dependencies that are not included in the default install

**Red flags:**
- A permissive package that pulls in a GPL dependency at runtime
- Vendored (copied) copyleft code inside a permissive package

## Quick Decision Flowchart

```
Is there a LICENSE file?
├── No → REJECTED (no license = all rights reserved)
└── Yes
    ├── Permissive (MIT, Apache-2.0, BSD, ISC)? → APPROVED
    ├── Weak copyleft (LGPL, MPL-2.0)?
    │   ├── Used as unmodified library? → APPROVED (with conditions)
    │   └── Source will be modified? → CAUTION (modifications must be shared)
    ├── Strong copyleft (GPL, AGPL)?
    │   └── REJECTED (incompatible with proprietary use)
    ├── Non-commercial / restricted (CC-BY-NC, SSPL, BUSL)?
    │   └── REJECTED
    └── Unknown / custom license?
        └── CAUTION (flag for legal review)
```
