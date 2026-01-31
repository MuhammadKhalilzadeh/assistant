# Clean Code Principles for Flutter/Dart

Clean code is code that is easy to read, understand, and maintain. This guide covers the fundamental principles that lead to clean, professional code.

---

## DRY - Don't Repeat Yourself

**Every piece of knowledge should have a single, unambiguous representation in the system.**

Duplication leads to inconsistencies, bugs, and maintenance nightmares.

### ❌ Don't: Repeated Code

```dart
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(product.name),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final Service service;

  const ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Same decoration duplicated!
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(service.title),
    );
  }
}
```

### ✅ Do: Extract Reusable Components

```dart
// Reusable card widget
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Use the reusable component
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return AppCard(child: Text(product.name));
  }
}

class ServiceCard extends StatelessWidget {
  final Service service;

  const ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return AppCard(child: Text(service.title));
  }
}
```

### Using Mixins for Shared Behavior

```dart
// Mixin for validation logic
mixin ValidationMixin {
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}

// Use mixin in multiple forms
class LoginForm extends StatelessWidget with ValidationMixin {
  @override
  Widget build(BuildContext context) {
    return TextFormField(validator: validateEmail);
  }
}

class RegistrationForm extends StatelessWidget with ValidationMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(validator: validateEmail),
        TextFormField(validator: validatePassword),
      ],
    );
  }
}
```

---

## KISS - Keep It Simple, Stupid

**The simplest solution is usually the best solution.**

Avoid over-engineering. Start simple and add complexity only when truly needed.

### ❌ Don't: Over-Engineered

```dart
// Over-engineered for a simple toggle
abstract class ToggleState {}
class ToggleOn extends ToggleState {}
class ToggleOff extends ToggleState {}

class ToggleBloc extends Bloc<ToggleEvent, ToggleState> {
  ToggleBloc() : super(ToggleOff()) {
    on<TogglePressed>((event, emit) {
      if (state is ToggleOn) {
        emit(ToggleOff());
      } else {
        emit(ToggleOn());
      }
    });
  }
}

class ToggleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ToggleBloc(),
      child: BlocBuilder<ToggleBloc, ToggleState>(
        builder: (context, state) {
          return Switch(
            value: state is ToggleOn,
            onChanged: (_) => context.read<ToggleBloc>().add(TogglePressed()),
          );
        },
      ),
    );
  }
}
```

### ✅ Do: Simple Solution

```dart
// Simple and effective
class ToggleWidget extends StatefulWidget {
  @override
  _ToggleWidgetState createState() => _ToggleWidgetState();
}

class _ToggleWidgetState extends State<ToggleWidget> {
  bool isOn = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isOn,
      onChanged: (value) => setState(() => isOn = value),
    );
  }
}
```

### When Simplicity Matters

```dart
// ❌ Unnecessary abstraction
class StringUtils {
  static String capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
// Usage: StringUtils.capitalize(name)

// ✅ Extension method - simpler API
extension StringExtension on String {
  String get capitalized =>
    isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
// Usage: name.capitalized
```

---

## YAGNI - You Aren't Gonna Need It

**Don't add functionality until it's actually needed.**

Avoid building for hypothetical future requirements.

### ❌ Don't: Speculative Features

```dart
class User {
  final String id;
  final String name;
  final String email;

  // "We might need these later"
  final String? middleName;
  final String? suffix;
  final String? preferredLanguage;
  final String? timezone;
  final Map<String, dynamic>? metadata;
  final List<String>? tags;
  final DateTime? lastLoginAt;
  final int? loginCount;
  final String? referralCode;
  final bool? isVerified;
  final bool? isBetaUser;
  final bool? hasCompletedOnboarding;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.middleName,
    this.suffix,
    this.preferredLanguage,
    this.timezone,
    this.metadata,
    this.tags,
    this.lastLoginAt,
    this.loginCount,
    this.referralCode,
    this.isVerified,
    this.isBetaUser,
    this.hasCompletedOnboarding,
  });
}
```

### ✅ Do: Only What's Needed

```dart
class User {
  final String id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });
}

// Add fields WHEN they become requirements, not before
```

### Configuration Flexibility Anti-Pattern

```dart
// ❌ Don't: Over-configurable for no reason
class ApiClient {
  final String baseUrl;
  final Duration timeout;
  final int maxRetries;
  final Duration retryDelay;
  final bool enableLogging;
  final bool enableCaching;
  final Duration cacheDuration;
  final Map<String, String>? defaultHeaders;
  final bool followRedirects;
  final int maxRedirects;
  // ... 20 more options

  ApiClient({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    // ... endless constructor
  });
}

// ✅ Do: Start with sensible defaults
class ApiClient {
  final String baseUrl;
  final Duration timeout;

  const ApiClient({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
  });
}
```

---

## Clean Code Principles

### Meaningful Naming

Names should reveal intent. If a name requires a comment, it doesn't reveal its intent.

```dart
// ❌ Poor naming
int d; // elapsed time in days
List<int> l1;
void doStuff();
bool flag;

// ✅ Good naming
int elapsedTimeInDays;
List<int> userIds;
void sendWelcomeEmail();
bool isAuthenticated;
```

### Naming Conventions

```dart
// Classes: What it IS (noun)
class UserRepository {}
class PaymentService {}
class AuthenticationBloc {}

// Methods: What it DOES (verb)
void fetchUsers() {}
void calculateTotal() {}
bool isValid() {}
Future<User> getUserById(int id) {}

// Boolean variables: Question form
bool isLoading;
bool hasError;
bool canSubmit;
bool shouldRefresh;

// Collections: Plural nouns
List<User> users;
Map<String, Order> ordersByUserId;
Set<String> selectedCategories;
```

### Functions Do One Thing

A function should do one thing, do it well, and do it only.

```dart
// ❌ Function doing multiple things
Future<void> processOrder(Order order) async {
  // Validate
  if (order.items.isEmpty) throw Exception('Empty order');
  if (order.total <= 0) throw Exception('Invalid total');

  // Calculate totals
  double subtotal = 0;
  for (final item in order.items) {
    subtotal += item.price * item.quantity;
  }
  double tax = subtotal * 0.1;
  double total = subtotal + tax;

  // Save to database
  await database.insert('orders', order.toJson());

  // Send confirmation email
  await emailService.send(
    to: order.customerEmail,
    subject: 'Order Confirmation',
    body: 'Your order total is \$$total',
  );

  // Update inventory
  for (final item in order.items) {
    await inventory.decrease(item.productId, item.quantity);
  }
}

// ✅ Each function does one thing
Future<void> processOrder(Order order) async {
  validateOrder(order);
  final totals = calculateTotals(order);
  await saveOrder(order, totals);
  await sendConfirmationEmail(order, totals);
  await updateInventory(order);
}

void validateOrder(Order order) {
  if (order.items.isEmpty) throw EmptyOrderException();
  if (order.total <= 0) throw InvalidTotalException();
}

OrderTotals calculateTotals(Order order) {
  final subtotal = order.items.fold<double>(
    0,
    (sum, item) => sum + item.price * item.quantity,
  );
  return OrderTotals(
    subtotal: subtotal,
    tax: subtotal * 0.1,
  );
}
```

### Self-Documenting Code

Code should explain itself. Comments are often a sign of unclear code.

```dart
// ❌ Code requiring comments
// Check if user can access premium features
if (u.s == 1 && u.e != null && u.e!.isAfter(DateTime.now())) {
  // Show premium content
}

// ✅ Self-documenting code
bool get canAccessPremium =>
    subscription.isActive &&
    subscription.expiresAt.isAfter(DateTime.now());

if (user.canAccessPremium) {
  showPremiumContent();
}
```

### When Comments Are Appropriate

```dart
// ✅ Explaining WHY (not what)
// Using binary search because the list is guaranteed to be sorted
// and we need O(log n) performance for large datasets
int findUser(List<User> sortedUsers, String id) {
  // Binary search implementation
}

// ✅ Documenting public APIs
/// Fetches the user with the given [id].
///
/// Throws [UserNotFoundException] if no user exists with that ID.
/// Throws [NetworkException] if the network request fails.
Future<User> getUser(int id) async { ... }

// ✅ Warning about consequences
// WARNING: This clears all user data. Cannot be undone.
Future<void> resetAccount() async { ... }

// ✅ TODO with context
// TODO(john): Refactor when API v2 is released (Q3 2024)
```

### Avoid Magic Numbers

```dart
// ❌ Magic numbers
if (password.length < 8) { ... }
await Future.delayed(Duration(milliseconds: 300));
if (retryCount > 3) { ... }

// ✅ Named constants
const int minPasswordLength = 8;
const Duration animationDuration = Duration(milliseconds: 300);
const int maxRetryAttempts = 3;

if (password.length < minPasswordLength) { ... }
await Future.delayed(animationDuration);
if (retryCount > maxRetryAttempts) { ... }
```

### Function Arguments

Fewer arguments are better. Consider using objects for multiple related parameters.

```dart
// ❌ Too many arguments
Widget buildCard(
  String title,
  String subtitle,
  String imageUrl,
  VoidCallback onTap,
  Color backgroundColor,
  Color textColor,
  double borderRadius,
  EdgeInsets padding,
  bool showShadow,
) { ... }

// ✅ Group related arguments
class CardConfig {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onTap;
  final CardStyle style;

  const CardConfig({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onTap,
    this.style = const CardStyle(),
  });
}

class CardStyle {
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final bool showShadow;

  const CardStyle({
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(16),
    this.showShadow = true,
  });
}

Widget buildCard(CardConfig config) { ... }
```

---

## Summary

| Principle | Key Question |
|-----------|--------------|
| **DRY** | Is this logic duplicated elsewhere? |
| **KISS** | Is there a simpler way to do this? |
| **YAGNI** | Do we actually need this right now? |
| **Clean Code** | Can someone understand this without explanation? |

## Refactoring Checklist

- [ ] No duplicated code (DRY)
- [ ] Simplest possible solution (KISS)
- [ ] No speculative features (YAGNI)
- [ ] Meaningful names throughout
- [ ] Functions do one thing
- [ ] No magic numbers
- [ ] Self-documenting code
- [ ] Comments explain "why", not "what"

## References

- Clean Code by Robert C. Martin
- [Effective Dart: Design](https://dart.dev/effective-dart/design)
- The Pragmatic Programmer by Hunt & Thomas
