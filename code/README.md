# Flutter/Dart Code Best Practices Guide

A comprehensive guide to professional coding standards, SOLID principles, and industry best practices for Flutter/Dart development.

## Quick Reference Card

| Principle | Summary |
|-----------|---------|
| **SRP** | One class = one reason to change |
| **OCP** | Open for extension, closed for modification |
| **LSP** | Subtypes must be substitutable for base types |
| **ISP** | Many specific interfaces > one general interface |
| **DIP** | Depend on abstractions, not concretions |
| **DRY** | Don't Repeat Yourself |
| **KISS** | Keep It Simple, Stupid |
| **YAGNI** | You Aren't Gonna Need It |

## Guide Contents

1. **[SOLID Principles](01_solid_principles.md)** - The five fundamental OOP principles with Dart examples
2. **[Clean Code](02_clean_code.md)** - DRY, KISS, YAGNI, and Clean Code practices
3. **[Dart Style](03_dart_style.md)** - Effective Dart naming, formatting, and conventions
4. **[Flutter Patterns](04_flutter_patterns.md)** - Widget composition and state management
5. **[Architecture](05_architecture.md)** - Clean Architecture, Repository, and Service patterns
6. **[Performance](06_performance.md)** - Optimization techniques and frame budget management
7. **[Testing](07_testing.md)** - Unit, Widget, and Integration testing guidelines

## How to Use This Guide

### For New Team Members
Start with **Clean Code** and **Dart Style** to understand basic conventions, then progress to **SOLID Principles** and **Architecture**.

### For Code Reviews
Reference specific sections when providing feedback. Each section includes Do/Don't examples for clear guidance.

### For Architecture Decisions
Consult **Architecture** and **Flutter Patterns** when designing new features or refactoring existing code.

### For Performance Issues
Check **Performance** section for optimization techniques and common pitfalls.

## Core Philosophy

```
Write code that is:
├── Readable    → Others can understand it
├── Maintainable → Easy to change without breaking
├── Testable    → Can be verified automatically
├── Performant  → Respects the 16ms frame budget
└── Simple      → No unnecessary complexity
```

## References

- [Effective Dart](https://dart.dev/effective-dart)
- [Flutter Performance](https://docs.flutter.dev/perf)
- [Flutter Testing](https://docs.flutter.dev/testing)
- Clean Code by Robert C. Martin
- Flutter Official Documentation
