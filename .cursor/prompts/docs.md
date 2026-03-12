Generate clear, accurate documentation for the specified code or feature.

Read the relevant source files first to ensure the documentation is accurate and up to date.

## Documentation to Generate

Based on what is requested, produce the appropriate documentation type:

### API Reference (for functions, classes, modules)
Generate doc comments in the appropriate format for the language:
- **TypeScript/JavaScript**: JSDoc (`/** ... */`)
- **Python**: Google-style or NumPy-style docstrings
- **Go**: GoDoc comments

Include for each public function/method:
- **Purpose**: What it does and why it exists
- **Parameters**: Name, type, description, required/optional, default value
- **Returns**: Type and description
- **Throws/Raises**: Error types and when they occur
- **Example**: A practical, runnable usage example
- **Notes**: Performance characteristics, thread safety, deprecation notices

### Architecture Document (for a module, service, or system)
- **Overview**: What problem this solves and how
- **Key concepts**: Important abstractions and how they relate
- **Data flow**: How data moves through the system (with ASCII diagram if helpful)
- **Configuration**: Required environment variables and options
- **Extension points**: How to customize or extend behavior
- **Limitations**: Known limitations and when NOT to use this

### User-Facing Guide (for CLI commands, configuration, workflows)
- **Purpose**: What this enables and who should use it
- **Prerequisites**: What must be set up first
- **Quick start**: Minimal working example
- **Full reference**: All options with descriptions
- **Common patterns**: Practical examples for typical use cases
- **Troubleshooting**: Common errors and how to fix them

## Quality Standards
- Documentation must be accurate — read the code, do not guess
- Use concrete examples, not abstract descriptions
- Write for the reader's level (developer using an internal API vs. end user)
- Keep it current — documentation that diverges from code is worse than none

---

**Document** (specify file, module, or feature + documentation type):
