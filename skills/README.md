# Skills Index

This directory documents all available AI coding skills for this project.
Skills are language-, framework-, and domain-specific rule sets that provide
deep context to AI tools.

## How Skills Work

| Tool | How skills activate |
|------|-------------------|
| **Cursor** | Automatically via `globs` in `.cursor/rules/skills/*.mdc` |
| **Continue** | Manually added to `.continue/config.yaml` `rules:` section |
| **Claude Code** | Via `@` file references in prompts |

## Available Skills

### Backend Languages

| Skill | Cursor Rule | Continue Rule | Key Coverage |
|-------|-------------|---------------|-------------|
| Java | `skills/lang-java.mdc` | `skills/lang-java.md` | Spring Boot, JPA, JUnit 5, Java 21 |
| .NET / C# | `skills/lang-dotnet.mdc` | `skills/lang-dotnet.md` | ASP.NET Core, EF Core, xUnit, C# 12 |
| Python | `skills/lang-python.mdc` | `skills/lang-python.md` | FastAPI, SQLAlchemy, pytest, type hints |
| TypeScript | `skills/lang-typescript.mdc` | *(covered by base rules)* | Strict TS, ESM, Bun/Node.js |
| Go | `skills/lang-go.mdc` | *(add as needed)* | Idiomatic Go, stdlib, concurrency |

### Frontend Frameworks

| Skill | Cursor Rule | Continue Rule | Key Coverage |
|-------|-------------|---------------|-------------|
| React | `skills/fe-react.mdc` | `skills/fe-react.md` | Hooks, React Query, RTL, forms |
| Next.js | `skills/fe-nextjs.mdc` | `skills/fe-nextjs.md` | App Router, Server Components, Server Actions |
| Vue 3 | `skills/fe-vue.mdc` | `skills/fe-vue.md` | Composition API, Pinia, Vue Router |
| Angular | `skills/fe-angular.mdc` | `skills/fe-angular.md` | Standalone, Signals, NgRx, RxJS |

### Mobile Platforms

| Skill | Cursor Rule | Continue Rule | Key Coverage |
|-------|-------------|---------------|-------------|
| iOS | `skills/mobile-ios.mdc` | `skills/mobile-ios.md` | Swift 5.9+, SwiftUI, MVVM, async/await, SwiftData, XCTest / Swift Testing |
| Android | `skills/mobile-android.mdc` | `skills/mobile-android.md` | Kotlin, Jetpack Compose, Hilt, Room, Coroutines + Flow, Material 3 |
| Kotlin Multiplatform | `skills/mobile-kmp.mdc` | `skills/mobile-kmp.md` | KMP shared logic, Ktor, kotlinx.serialization, SQLDelight, Koin, Compose Multiplatform, SKIE |
| Flutter | `skills/mobile-flutter.mdc` | `skills/mobile-flutter.md` | Dart 3, Riverpod, GoRouter, Freezed, drift, EAS / Fastlane |
| React Native | `skills/mobile-reactnative.mdc` | `skills/mobile-reactnative.md` | Expo, TypeScript strict, React Navigation, Zustand, TanStack Query, EAS |

### Security

| Skill | Cursor Rule | Continue Rule | Key Coverage |
|-------|-------------|---------------|-------------|
| Security SAST | `skills/security-sast.mdc` | `skills/security-sast.md` | OWASP Top 10 patterns per language, injection, crypto, path traversal, secret detection, mobile storage |

> **Recommendation:** Enable `security-sast` for all production projects alongside your language skill. It activates on all common source file extensions.

### Infrastructure & DevOps

| Skill | Cursor Rule | Continue Rule | Key Coverage |
|-------|-------------|---------------|-------------|
| Docker | `skills/devops-docker.mdc` | *(add as needed)* | Dockerfile, Compose, security, optimization |
| CI/CD | `skills/devops-cicd.mdc` | *(add as needed)* | GitHub Actions, quality gates, deployment |
| Microservices | `skills/be-microservices.mdc` | *(add as needed)* | Service design, communication, observability |
| Database Migrations | `skills/db-migrations.mdc` | `skills/db-migrations.md` | Flyway, Liquibase, Alembic, Django, Prisma, Drizzle, Goose, golang-migrate, Atlas, EF Core, Room, drift, SQLDelight — DDL/DML patterns, seed data, drift detection |

## Activating Skills in Continue

By default, only the base rules are active in Continue. To add a language skill,
edit `.continue/config.yaml`:

```yaml
rules:
  # Base rules (always active)
  - .continue/rules/01-coding-standards.md
  - .continue/rules/02-architecture.md
  - .continue/rules/03-testing.md
  - .continue/rules/04-security.md

  # Backend — activate one:
  # - .continue/rules/skills/lang-java.md
  # - .continue/rules/skills/lang-dotnet.md
  # - .continue/rules/skills/lang-python.md

  # Frontend — activate one or more:
  # - .continue/rules/skills/fe-react.md
  # - .continue/rules/skills/fe-nextjs.md
  # - .continue/rules/skills/fe-vue.md
  # - .continue/rules/skills/fe-angular.md

  # Mobile — activate one:
  # - .continue/rules/skills/mobile-ios.md
  # - .continue/rules/skills/mobile-android.md
  # - .continue/rules/skills/mobile-kmp.md
  # - .continue/rules/skills/mobile-flutter.md
  # - .continue/rules/skills/mobile-reactnative.md

  # Database (activate if your project uses a relational or mobile DB):
  # - .continue/rules/skills/db-migrations.md
```

## Using Skills in Claude Code

Reference a skill file directly in a prompt for targeted guidance:

```
# In Claude Code chat:
@.cursor/rules/skills/lang-java.mdc — given these standards, review my UserService
@.cursor/rules/skills/fe-react.mdc — generate a UserProfile component following our patterns
```

## Adding New Skills

To add a skill for a new language or framework:

1. Create `.cursor/rules/skills/<name>.mdc` — full detailed Cursor rule
2. Create `.continue/rules/skills/<name>.md` — condensed Continue rule
3. Add to this README index
4. Activate in `.continue/config.yaml` for your project

### Skill file template

**.cursor/rules/skills/lang-example.mdc:**
```
---
description: Example language standards — [key frameworks and tools]
globs: ["**/*.ext", "**/config-file.*"]
alwaysApply: false
---

# Example Language Standards

## Code Style
...

## Naming Conventions
...

## Architecture
...

## Testing
...
```
