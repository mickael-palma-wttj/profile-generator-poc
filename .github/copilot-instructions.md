# Ruby Coding Guidelines for Copilot

When writing, refactoring, or analyzing Ruby code in this repository, adhere to the following principles, rules, and patterns.

## Core Principles

- **Clean Code**: Prioritize readability and maintainability.
- **Single Responsibility Principle (SRP)**: Each class and method should have exactly one responsibility.
- **Don't Repeat Yourself (DRY)**: Extract duplicate logic into reusable methods or modules.
- **Keep It Simple, Stupid (KISS)**: Avoid over-engineering; choose the simplest solution that works.
- **You Aren't Gonna Need It (YAGNI)**: Do not implement features or abstractions until they are actually needed.

## Sandi Metz's Rules (Strict Adherence)

1. **Method Length**: Keep methods under **10 lines** of code.
2. **Class Size**: Keep classes under **100 lines** of code.
3. **Parameter Lists**: Use no more than **4 parameters** per method. Use keyword arguments or configuration objects for more.
4. **Dependencies**: Limit the number of instance variables and dependencies. Use Dependency Injection.

## Code Style & Organization

- **Frozen String Literals**: Always add `# frozen_string_literal: true` at the top of every Ruby file.
- **Naming**: Use clear, intention-revealing names. Avoid abbreviations.
  - Classes: `PascalCase`
  - Methods/Variables: `snake_case`
  - Constants: `SCREAMING_SNAKE_CASE`
- **Comments**: Prefer self-documenting code over comments. Use comments only for "why", not "what".
- **Error Handling**: Handle specific exceptions. Avoid rescuing `Exception` or `StandardError` without cause.
- **State**: Avoid global state. Minimize mutable state.

## Design Patterns

Prefer the following patterns to organize business logic:

- **Service Objects**: For single-action business operations (e.g., `GenerateProfile`, `OpenAIClient`).
- **Value Objects**: For immutable domain concepts with equality logic (e.g., `Company`, `ProfileSection`).
- **Interactors/Use Cases**: For orchestrating complex flows involving multiple services.
- **Factory/Builder**: For complex object construction.
- **Result Objects**: Return success/failure objects instead of raising exceptions for flow control.

## Refactoring Workflow

When asked to refactor code, follow this structure:

1. **Identify Issues**: Point out violations of the rules above (e.g., "Method `process` is 25 lines long").
2. **Apply Patterns**: Suggest the appropriate pattern (e.g., "Extract to Service Object").
3. **Show Changes**: Provide the "Before" and "After" code.
4. **Explain**: Justify the change based on the principles (e.g., "Improves SRP and testability").

## Testing

- Ensure all new logic is testable.
- Prefer dependency injection to make mocking easier.
- Write code that is easy to test in isolation.
