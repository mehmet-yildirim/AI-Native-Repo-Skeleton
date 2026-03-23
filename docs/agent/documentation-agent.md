# Documentation Agent — Architecture & Tool Guide

This document defines the documentation generation strategy for AI-native projects:
what to generate, which tools to use per stack, how to wire everything into CI/CD,
and how AI agents (including Initium's slash commands) fit into the workflow.

---

## Documentation Matrix — Audience × Format

Every documentation artefact targets a specific audience. Define both before generating.

| Type | Audience | Format | Trigger | Tool |
|------|----------|--------|---------|------|
| API Reference | API consumers, integrators | OpenAPI 3.x + Swagger/ReDoc UI | On spec change | SpringDoc, FastAPI built-in, tsoa, swaggo |
| Code docs | Developers reading/maintaining code | JSDoc/TSDoc, docstrings, GoDoc | On PR | TypeDoc, Sphinx, Javadoc, Dartdoc, DocC |
| Architecture | Developers, architects | Mermaid / C4 / PlantUML in Markdown | On design change | Mermaid, Structurizr DSL, PlantUML |
| Developer guide | Onboarding developers | Markdown site | On feature complete | Docusaurus 3, MkDocs Material, VitePress |
| Changelog | All developers, release managers | Markdown | On git tag | git-cliff, release-please |
| DB schema | Developers, DBAs | ERD + table descriptions | Post-migration | SchemaSpy, tbls, DBML |
| SDK clients | Third-party developers | Language-idiomatic code | On OpenAPI change | Speakeasy, Hey API, openapi-generator |
| Stakeholder summary | Executives, product managers | Markdown → PDF | On release | AI-generated from technical docs |
| `llms.txt` | AI tools, LLMs | Plain text manifest | On deploy | Custom script |

---

## Tool Recommendations by Stack

### API Reference (OpenAPI 3.x)

| Stack | Tool | Config | Auto? |
|-------|------|--------|-------|
| **Java / Spring Boot** | `springdoc-openapi-starter-webmvc-ui` 2.x | Annotations: `@Operation`, `@Schema` | ✓ (zero-config) |
| **Kotlin / Spring** | Same as Java | Same | ✓ |
| **Python / FastAPI** | Built-in | Python type hints | ✓ (zero-config) |
| **Python / Django** | `drf-spectacular` | `@extend_schema` decorator | ✓ with decorators |
| **.NET / ASP.NET Core** | `Swashbuckle.AspNetCore` | XML doc comments | ✓ |
| **TypeScript / Node** | `tsoa` (code-first) or `zod-to-openapi` | Decorators or Zod schemas | ✓ with setup |
| **TypeScript / NestJS** | `@nestjs/swagger` | Decorators: `@ApiProperty` | ✓ |
| **Go** | `swaggo/swag` | Comment annotations | ✓ with `swag init` |
| **iOS / Swift** | n/a — use REST spec | — | — |
| **Android / Kotlin** | n/a — consume spec | — | — |
| **Flutter / Dart** | n/a — consume spec | — | — |

**Output:** Always produce a single `openapi.json` / `openapi.yaml` at the repo root.
Multiple services: merge with `redocly join` or the Speakeasy merge command.

### Code-Level Documentation

| Stack | Tool | Command | Output |
|-------|------|---------|--------|
| TypeScript/JS | `typedoc` | `npx typedoc` | `docs/api/` (HTML) |
| Python | `sphinx` + `autodoc` | `sphinx-build -b html` | `docs/build/html/` |
| Java | `javadoc` (Maven plugin) | `mvn javadoc:javadoc` | `target/site/apidocs/` |
| Kotlin | `dokka` | `./gradlew dokkaHtml` | `build/dokka/html/` |
| .NET / C# | `DocFX` 2.x | `docfx build` | `_site/` |
| Go | `pkgsite` / go.dev | `go doc ./...` | Hosted at pkg.go.dev |
| Swift | `DocC` (Xcode) | `xcodebuild docbuild` | `.doccarchive` |
| Dart/Flutter | `dartdoc` | `dart doc` | `doc/api/` |

### Architecture Diagrams

**Mermaid** — recommended for all teams (renders natively on GitHub, Docusaurus, GitLab):
```
Simple + widely supported + renders in markdown previews
```

**Structurizr DSL** — for teams needing formal C4 model:
```
C4-native, workspace.dsl → JSON / SVG / PNG
structurizr-cli export -workspace workspace.dsl -format svg
```

**PlantUML** — for complex UML sequences, state diagrams, class diagrams:
```
docker run --rm -v $(pwd):/data plantuml/plantuml:latest -Tsvg /data/diagrams/*.puml
```

### Documentation Sites

| Tool | Best for | Hosting | Key feature |
|------|---------|---------|------------|
| **Docusaurus 3** | Product/API docs with versioning | Vercel, Netlify, GitHub Pages | React MDX, built-in versioning, i18n |
| **MkDocs Material** | Python-heavy teams, enterprise | ReadTheDocs, self-hosted | Fast, Mermaid native, no JS needed |
| **VitePress** | Vue-heavy teams | Any static host | Fastest build, Vue components in docs |
| **Mintlify** | API-first products | Mintlify hosted | Zero-config, AI search built-in |

### Changelog / Release Notes

**`git-cliff`** — recommended for all polyglot repos:
```bash
# Install
cargo install git-cliff  # or: brew install git-cliff

# Generate
git-cliff --output CHANGELOG.md

# Since last tag
git-cliff v1.0.0..HEAD --output CHANGELOG.md
```

Requires [conventional commits](https://www.conventionalcommits.org/) format.
Configure via `cliff.toml` at repo root.

**`release-please`** — if you want fully automated GitHub releases:
```yaml
# .github/workflows/release-please.yml
uses: google-github-actions/release-please-action@v4
with:
  release-type: node  # or: python, rust, simple
```

### Database Schema Docs

**SchemaSpy** (best for auto-extraction from live DB):
```bash
docker run --rm -v "$(pwd)/docs/database:/output" schemaspy/schemaspy:latest \
  -t pgsql -host localhost -port 5432 -db myapp -u postgres -p $DB_PASS
```

**DBML** (best for documentation-first approach):
```bash
npm install -g @dbml/cli
dbml2html schema.dbml -o docs/database/schema.html
```

**tbls** (Go binary, fastest, Markdown output):
```bash
tbls doc postgres://user:pass@localhost:5432/mydb docs/database/
```

### SDK Generation

**Speakeasy** — idiomatic SDKs in 6+ languages from your OpenAPI spec:
```bash
speakeasy generate sdk -s openapi.json
```
Produces: TypeScript, Python, Go, Java, C#, PHP — each language-idiomatic.

**Hey API** — TypeScript-only, lighter weight:
```bash
npx @hey-api/openapi-ts -i openapi.json -o src/generated -c axios
```
Produces: typed client + Zod schemas + TanStack Query hooks.

---

## CI/CD Documentation Pipeline

Add this workflow to `.github/workflows/docs.yml`:

```yaml
name: Documentation

on:
  push:
    branches: [main]
    paths: ['src/**', 'docs/**', 'openapi.*', 'CHANGELOG.md', 'cliff.toml']
  release:
    types: [created]

jobs:
  # ── API Reference ──────────────────────────────────────────────────────────
  api-docs:
    name: Generate API Reference
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # TODO: uncomment for your stack
      # Spring Boot
      # - run: mvn springdoc-openapi-maven-plugin:generate -DskipTests

      # FastAPI (Python)
      # - run: |
      #     pip install -e ".[dev]"
      #     python -c "from app.main import app; import json; open('openapi.json','w').write(json.dumps(app.openapi()))"

      # TypeScript / tsoa
      # - run: npm ci && npm run openapi:generate

      # Go / swag
      # - run: go install github.com/swaggo/swag/cmd/swag@latest && swag init

      - name: Validate OpenAPI spec
        run: npx @redocly/cli lint openapi.json

      - name: Bundle for docs site
        run: npx @redocly/cli bundle openapi.json -o docs/static/openapi-bundled.json

      - uses: actions/upload-artifact@v4
        with:
          name: openapi-spec
          path: openapi.json

  # ── Code Documentation ─────────────────────────────────────────────────────
  code-docs:
    name: Generate Code Docs
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # TypeScript
      # - run: npm ci && npm run docs:generate  # TypeDoc

      # Python
      # - run: pip install sphinx sphinx-rtd-theme && sphinx-build -b html docs/source docs/build/html

      # Java
      # - run: mvn javadoc:javadoc -DskipTests

      - uses: actions/upload-artifact@v4
        with:
          name: code-docs
          path: |
            docs/build/html/
            target/site/apidocs/
            doc/api/

  # ── Documentation Site ─────────────────────────────────────────────────────
  docs-site:
    name: Build Documentation Site
    runs-on: ubuntu-latest
    needs: [api-docs, code-docs]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v4
        with:
          name: openapi-spec

      # TODO: uncomment for Docusaurus 3
      # - run: cd docs-site && npm ci && npm run build
      # TODO: or MkDocs Material
      # - run: pip install mkdocs-material && mkdocs build

      - uses: actions/upload-artifact@v4
        with:
          name: docs-site
          path: docs-site/build/

  # ── Changelog ──────────────────────────────────────────────────────────────
  changelog:
    name: Update Changelog
    runs-on: ubuntu-latest
    if: github.event_name == 'release'
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - run: |
          cargo install git-cliff
          git-cliff --output CHANGELOG.md
      - run: |
          git config user.name "docs-bot"
          git config user.email "bot@noreply.local"
          git add CHANGELOG.md
          git commit -m "docs: update changelog for ${{ github.ref_name }}"
          git push origin main

  # ── Schema Docs ────────────────────────────────────────────────────────────
  schema-docs:
    name: Generate Schema Docs
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    # services: postgres: ...  (add your DB service here)
    steps:
      - uses: actions/checkout@v4
      # - run: |
      #     docker run --rm -v "$(pwd)/docs/database:/output" \
      #       --network host schemaspy/schemaspy:latest \
      #       -t pgsql -host localhost -db myapp -u postgres -p $DB_PASS
      - uses: actions/upload-artifact@v4
        with:
          name: schema-docs
          path: docs/database/
```

---

## Documentation as Code — Principles

### 1. Docs live next to code
```
src/payments/
├── payment.service.ts      # source
├── payment.service.test.ts # tests
└── payment.service.md      # module-level docs (why, not what)
```

### 2. Every PR must update relevant docs
Add to your PR template checklist:
```
- [ ] API docs updated if endpoints changed
- [ ] Architecture docs updated if design changed
- [ ] CHANGELOG.md entry added (or auto-generated via git-cliff)
```

### 3. Docs staleness gate in CI
```bash
#!/usr/bin/env bash
# scripts/check-docs-staleness.sh
# Fail CI if a source file changed without a docs update in the same PR
CHANGED_SRC=$(git diff origin/main --name-only | grep "^src/" | grep -v "\.test\.")
CHANGED_DOCS=$(git diff origin/main --name-only | grep "^docs/")
if [ -n "$CHANGED_SRC" ] && [ -z "$CHANGED_DOCS" ]; then
  echo "WARNING: source code changed but no documentation was updated."
  echo "Consider running /doc-code or /doc-api to update affected docs."
fi
```

### 4. llms.txt — Make docs AI-readable
Generate a [`llms.txt`](https://llmstxt.org/) file for AI tools consuming your docs:

```bash
# scripts/generate-llms-txt.sh
cat > llms.txt << 'EOF'
# <Project Name>

> <One-line description>

## API Reference
- [OpenAPI Spec](/openapi.json): Machine-readable API specification
- [API Docs](/docs/api): Human-readable reference

## Key Resources
- [Architecture](/docs/architecture/overview.md): System design
- [Getting Started](/docs/onboarding.md): Developer setup guide
- [Domain Glossary](/docs/context/domain-glossary.md): Business terms
- [Changelog](/CHANGELOG.md): Release history

## Source
- [GitHub](https://github.com/org/repo)
EOF
```

Place `llms.txt` at your docs site root and repo root.

---

## Stakeholder Documentation Strategy

Produce multiple audiences from the same source using audience-specific views:

```
docs/
├── _audience/
│   ├── developers.md     → full technical detail
│   ├── architects.md     → patterns, decisions, trade-offs
│   └── executives.md     → business impact, timelines, KPIs
└── context/
    └── project-brief.md  → authoritative source of truth
```

### AI-generated stakeholder summary

Use `/docs-stakeholder` to generate an executive-friendly summary from technical content.
The agent reads architecture docs, CHANGELOG, and release notes, then produces:
- Business impact summary
- Feature highlights (non-technical)
- Risk and mitigation summary
- Timeline view

---

## AI Documentation — Best Practices

### What AI generates well
- Initial docstrings from function signatures (verified against tests)
- Non-technical summaries from technical architecture docs
- "Getting started" guides from working code examples
- FAQ sections from support history

### What AI must NOT generate alone
- Security or compliance documentation (requires human domain expertise)
- Deprecation notices (risk of incorrect signalling)
- SLA / contractual specifications
- Anything that states behavioral guarantees not validated by tests

### Validation pattern
```
AI generates → human reviews → test examples run in CI → merge
```

Never merge AI-generated docs that haven't been validated against actual behavior.

---

## Slash Command Reference

| Command | Purpose |
|---------|---------|
| `/doc-api` | Detect stack → generate OpenAPI spec → validate → output to `openapi.json` |
| `/doc-code <path>` | Generate/update code-level docs (JSDoc, docstrings, GoDoc, JavaDoc) for a module |
| `/doc-site` | Scaffold or regenerate the documentation website |
| `/doc-changelog` | Generate `CHANGELOG.md` from git history using git-cliff conventions |
| `/doc-schema` | Generate database schema documentation (ERD + table descriptions) |
| `/docs <file>` | (existing) Generate documentation for a specific file or feature |
