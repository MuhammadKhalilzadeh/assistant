# Effective Dart Style Guide

This guide covers Dart-specific conventions, formatting rules, and best practices based on the official Effective Dart guidelines.

---

## Naming Conventions

### Identifiers

| Type | Convention | Example |
|------|------------|---------|
| Classes, enums, typedefs | `UpperCamelCase` | `UserProfile`, `HttpClient` |
| Extensions | `UpperCamelCase` | `StringExtension` |
| Libraries, packages | `lowercase_with_underscores` | `my_package`, `user_service` |
| Files | `lowercase_with_underscores` | `user_profile.dart` |
| Variables, parameters | `lowerCamelCase` | `userName`, `itemCount` |
| Functions, methods | `lowerCamelCase` | `fetchData()`, `calculateTotal()` |
| Constants | `lowerCamelCase` | `defaultTimeout`, `maxRetries` |
| Private members | `_lowerCamelCase` | `_cachedValue`, `_fetchData()` |

### Examples

```dart
// ✅ Correct naming
class HttpRequest {}
class UserProfileWidget extends StatelessWidget {}

const int maxLoginAttempts = 3;
const Duration defaultTimeout = Duration(seconds: 30);

void fetchUserData() {}
Future<List<User>> getActiveUsers() async {}

String userName = 'John';
final List<Product> _cachedProducts = [];

// File: user_profile_screen.dart
// Package: my_flutter_app

// ❌ Incorrect naming
class HTTP_Request {}          // Should be UpperCamelCase
class userProfile {}           // Should be UpperCamelCase
const int MAX_RETRIES = 3;     // Should be lowerCamelCase
void FetchData() {}            // Should be lowerCamelCase
String user_name = 'John';     // Should be lowerCamelCase
```

### Abbreviations

Treat abbreviations like words in identifiers.

```dart
// ✅ Correct
class HttpClient {}
class JsonParser {}
String htmlContent;
int dbConnection;
Uri apiUrl;

// ❌ Incorrect
class HTTPClient {}
class JSONParser {}
String HTMLContent;
int DBConnection;
```

### Boolean Naming

Use positive names and question-like prefixes.

```dart
// ✅ Good boolean names
bool isLoading;
bool hasError;
bool canSubmit;
bool shouldRefresh;
bool wasSuccessful;
bool get isEmpty => items.length == 0;

// ❌ Poor boolean names
bool loading;         // Use isLoading
bool error;           // Use hasError
bool notEmpty;        // Use isNotEmpty (avoid negatives)
bool isNotReady;      // Use isReady
```

---

## Code Formatting

### Use `dart format`

Always use the official formatter. Configure your IDE to format on save.

```bash
# Format a file
dart format lib/main.dart

# Format entire project
dart format .

# Check formatting without changing
dart format --output=none --set-exit-if-changed .
```

### Line Length

The default is 80 characters. For Flutter projects, 100 or 120 is common.

```yaml
# analysis_options.yaml
analyzer:
  language:
    strict-casts: true
    strict-raw-types: true

linter:
  rules:
    - lines_longer_than_80_chars  # or disable for Flutter
```

### Import Ordering

Organize imports in sections, separated by blank lines.

```dart
// 1. Dart SDK imports
import 'dart:async';
import 'dart:io';

// 2. Package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 3. Relative imports (your project)
import '../models/user.dart';
import '../services/api_service.dart';
import 'widgets/custom_button.dart';
```

### Prefer Relative Imports

For files within the same package, use relative imports.

```dart
// ✅ Relative imports for same package
import '../models/user.dart';
import 'widgets/button.dart';

// ❌ Avoid absolute imports for same package
import 'package:my_app/models/user.dart';
```

---

## Documentation

### Doc Comments

Use `///` for documentation comments on public APIs.

```dart
/// A user in the system.
///
/// Users can have one of several [UserRole]s that determine
/// their permissions within the application.
class User {
  /// The user's unique identifier.
  final String id;

  /// The user's display name.
  ///
  /// This is shown in the UI and may differ from the username.
  final String displayName;

  /// Creates a new user with the given [id] and [displayName].
  const User({required this.id, required this.displayName});

  /// Returns `true` if this user has admin privileges.
  bool get isAdmin => role == UserRole.admin;
}
```

### When to Document

```dart
// ✅ Document public APIs
/// Fetches the current user from the API.
///
/// Throws [AuthenticationException] if not logged in.
/// Throws [NetworkException] if the request fails.
Future<User> getCurrentUser() async { ... }

// ✅ Document non-obvious behavior
/// Sorts users by name, with admins always appearing first.
List<User> sortUsers(List<User> users) { ... }

// ❌ Don't document the obvious
/// Returns the user's name.  // Unnecessary
String get name => _name;

/// Creates a new UserService.  // Unnecessary
UserService();
```

### Markdown in Doc Comments

```dart
/// Processes the given [data] and returns the result.
///
/// ## Example
///
/// ```dart
/// final result = processor.process({'key': 'value'});
/// print(result.status); // 'success'
/// ```
///
/// ## Parameters
///
/// * [data] - The input data to process
/// * [options] - Optional processing configuration
///
/// ## Throws
///
/// * [InvalidDataException] - If data format is invalid
/// * [ProcessingException] - If processing fails
Result process(Map<String, dynamic> data, {Options? options}) { ... }
```

---

## Best Practices

### Prefer `const` Constructors

Use `const` for compile-time constants to improve performance.

```dart
// ✅ Use const where possible
class AppColors {
  static const primary = Color(0xFF6200EE);
  static const secondary = Color(0xFF03DAC6);
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('Hello'),
    );
  }
}

// ✅ Const constructors
const user = User(id: '1', name: 'John');
const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
```

### Use `final` Over `var`

Prefer immutability. Use `final` for variables that won't be reassigned.

```dart
// ✅ Use final when value won't change
final String name = 'John';
final users = <User>[];  // List itself is final, but can be modified
final now = DateTime.now();

// ✅ Use const for compile-time constants
const int maxRetries = 3;
const timeout = Duration(seconds: 30);

// ❌ Avoid var when final works
var name = 'John';  // If never reassigned, use final
```

### Null Safety Patterns

```dart
// ✅ Use null-aware operators
String displayName = user.nickname ?? user.name;
int length = text?.length ?? 0;
user?.profile?.avatar?.url;

// ✅ Use late for guaranteed initialization
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ✅ Use required for non-null parameters
class User {
  final String id;
  final String name;
  final String? email;  // Optional

  const User({
    required this.id,
    required this.name,
    this.email,
  });
}
```

### Collection Literals

```dart
// ✅ Use collection literals
final names = <String>[];
final scores = <String, int>{};
final uniqueIds = <int>{};

// ❌ Avoid constructor calls
final names = List<String>();
final scores = Map<String, int>();
final uniqueIds = Set<int>();

// ✅ Collection if and for
final widgets = [
  const Header(),
  if (showBody) const Body(),
  for (final item in items) ItemWidget(item: item),
  const Footer(),
];
```

### Cascade Notation

Use cascades for multiple operations on the same object.

```dart
// ✅ Use cascades
final button = TextButton(onPressed: () {}, child: Text('Click'))
  ..style = ButtonStyle(...)
  ..focusNode = myFocusNode;

final paint = Paint()
  ..color = Colors.blue
  ..strokeWidth = 2.0
  ..style = PaintingStyle.stroke;

// StringBuilder pattern
final buffer = StringBuffer()
  ..write('Hello')
  ..write(' ')
  ..write('World');
final greeting = buffer.toString();
```

### Spread Operator

```dart
// ✅ Use spread for combining collections
final allUsers = [...admins, ...regularUsers];
final config = {...defaultConfig, ...userConfig};

// ✅ Spread with null-aware
final items = [
  ...requiredItems,
  ...?optionalItems,  // Only spreads if not null
];
```

### Arrow Functions

Use arrow syntax for single-expression functions.

```dart
// ✅ Arrow for single expressions
bool get isEmpty => items.length == 0;
String greet(String name) => 'Hello, $name!';
int add(int a, int b) => a + b;

// ✅ Arrow for callbacks
onPressed: () => print('Pressed'),
builder: (context) => const MyWidget(),

// ❌ Don't use arrow for multiple statements
// Use block body instead
void complexOperation() {
  validate();
  process();
  save();
}
```

### Type Inference

Let Dart infer types when they're obvious.

```dart
// ✅ Infer when obvious
final name = 'John';              // String is obvious
final users = <User>[];           // Type in generic
final controller = TextEditingController();

// ✅ Annotate when not obvious
Map<String, List<User>> usersByRole = {};
User? currentUser;

// ✅ Always annotate public APIs
String getUserName(int userId) { ... }
Future<List<Order>> getOrders() async { ... }

// ❌ Don't use dynamic unless necessary
dynamic result = api.fetch();  // What type is this?
```

### Enums

Use enhanced enums for related constants with behavior.

```dart
// ✅ Enhanced enums
enum UserRole {
  admin('Administrator', 0xFF6200EE),
  moderator('Moderator', 0xFF03DAC6),
  member('Member', 0xFF757575);

  final String displayName;
  final int colorValue;

  const UserRole(this.displayName, this.colorValue);

  Color get color => Color(colorValue);

  bool get canModerate => this == admin || this == moderator;
}

// Usage
final role = UserRole.admin;
print(role.displayName);  // 'Administrator'
print(role.canModerate);  // true
```

### Extension Methods

Add functionality to existing types without modification.

```dart
extension StringExtension on String {
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
}

extension DateTimeExtension on DateTime {
  String get formatted => '$day/$month/$year';

  bool get isToday {
    final now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }
}

// Usage
'hello'.capitalized;      // 'Hello'
'test@email.com'.isValidEmail;  // true
DateTime.now().formatted;  // '31/1/2024'
```

---

## Analysis Options

Configure analysis for consistent code quality.

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    missing_required_param: error
    missing_return: error
    parameter_assignments: warning

linter:
  rules:
    # Error prevention
    - avoid_dynamic_calls
    - avoid_returning_null_for_future
    - cancel_subscriptions
    - close_sinks

    # Style
    - always_declare_return_types
    - always_put_required_named_parameters_first
    - avoid_bool_literals_in_conditional_expressions
    - avoid_redundant_argument_values
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals

    # Documentation
    - public_member_api_docs  # Enforce docs on public APIs

    # Flutter specific
    - use_key_in_widget_constructors
    - sized_box_for_whitespace
    - use_colored_box
```

---

## Summary

| Category | Key Rules |
|----------|-----------|
| **Naming** | UpperCamelCase for types, lowerCamelCase for members |
| **Files** | lowercase_with_underscores.dart |
| **Formatting** | Use `dart format`, organize imports |
| **Types** | Prefer `final`, use `const` where possible |
| **Null Safety** | Use required, nullable types (?), and null-aware operators |
| **Documentation** | Use `///` for public APIs |

## References

- [Effective Dart](https://dart.dev/effective-dart)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Lints](https://pub.dev/packages/flutter_lints)
