# Documentation Generation Standards

## Core Principles
- Every public function/method/class must have a doc comment
- Comments explain WHY and HOW, not WHAT (code explains what)
- Include: purpose, parameters, return value, errors thrown, usage example
- Toolchain generates static HTML from comments — never manual HTML

## Code-Level Format by Language

### TypeScript/JavaScript (TSDoc)
```typescript
/**
 * Short summary (one line).
 *
 * Longer explanation if needed.
 *
 * @param paramName - Description of the parameter
 * @returns Description of return value
 * @throws {ErrorType} When this error occurs
 *
 * @example
 * ```ts
 * const result = await myFunction(args);
 * ```
 */
```
Tool: TypeDoc → `npx typedoc --out docs/api src/`

### Python (Google-style docstring)
```python
"""Short summary.

Longer explanation if needed.

Args:
    param_name: Description.

Returns:
    Description of return value.

Raises:
    ExceptionType: When this occurs.

Example:
    >>> result = my_function(args)
"""
```
Tool: Sphinx + autodoc → `sphinx-build -b html docs/source docs/build`

### Java (JavaDoc)
```java
/**
 * Short summary.
 *
 * @param paramName description
 * @return description
 * @throws ExceptionType when this occurs
 */
```
Tool: `mvn javadoc:javadoc` → `target/site/apidocs/`

### Kotlin (KDoc)
```kotlin
/**
 * Short summary.
 *
 * @param paramName description
 * @return description
 * @throws ExceptionType when this occurs
 */
```
Tool: Dokka → `./gradlew dokkaHtml`

### Go (GoDoc)
```go
// FunctionName does X. It returns an error wrapping [ErrNotFound]
// if Y condition occurs.
//
// Example:
//
//	result, err := FunctionName(ctx, args)
```
Tool: pkg.go.dev (automatic on push to GitHub)

### C# (XML Doc Comments)
```csharp
/// <summary>Short summary.</summary>
/// <param name="paramName">Description.</param>
/// <returns>Description.</returns>
/// <exception cref="ExType">When this occurs.</exception>
```
Tool: DocFX 2.x → `docfx build`

### Swift (DocC)
```swift
/// Short summary.
///
/// - Parameters:
///   - paramName: description
/// - Returns: description
/// - Throws: ``ErrorType`` when this occurs
```
Tool: `xcodebuild docbuild`

### Dart/Flutter (Dartdoc)
```dart
/// Short summary.
///
/// Throws [ExceptionType] when this occurs.
///
/// Example:
/// ```dart
/// final result = await myFunction(args);
/// ```
```
Tool: `dart doc` → `doc/api/`

---

## OpenAPI Requirements
- Every endpoint needs: `operationId`, `summary`, `tags`, `security`, full response schemas
- Document ALL status codes (200, 400, 401, 403, 404, 422, 429, 500)
- Include `example` values on every schema property
- Reuse error shapes via `$ref: '#/components/responses/NotFound'`
- Validate spec: `npx @redocly/cli lint openapi.json`

## Architecture Diagrams
- Use Mermaid for inline diagrams (renders on GitHub, Docusaurus, GitLab)
- Use C4 model levels: Context (stakeholders) → Container (architects) → Component (devs)
- Every diagram needs a title and labeled arrows
- Diagrams stored in `docs/architecture/` as `.md` with embedded Mermaid

## Documentation Commands
| Command | Purpose |
|---------|---------|
| `/doc-api` | Generate/update OpenAPI spec + ReDoc output |
| `/doc-site` | Scaffold or rebuild documentation website |
| `/doc-changelog` | Generate CHANGELOG.md from git history |
| `/doc-schema` | Generate database ERD + table reference |
| `/docs <file>` | Generate docs for a specific file or feature |
