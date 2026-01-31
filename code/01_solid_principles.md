# SOLID Principles in Flutter/Dart

SOLID principles are five fundamental object-oriented design principles that help create maintainable, scalable, and testable code.

---

## S - Single Responsibility Principle (SRP)

**A class should have only one reason to change.**

Each class or widget should focus on a single responsibility. Mixing concerns makes code harder to maintain and test.

### ❌ Don't: Mixed Responsibilities

```dart
class UserProfileWidget extends StatefulWidget {
  @override
  _UserProfileWidgetState createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  User? user;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  // Widget is doing: UI + API calls + JSON parsing + caching
  Future<void> _fetchUser() async {
    final response = await http.get(Uri.parse('api/user/1'));
    final json = jsonDecode(response.body);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_user', response.body);
    setState(() {
      user = User(
        name: json['name'],
        email: json['email'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(user?.name ?? 'Loading...');
  }
}
```

### ✅ Do: Separated Responsibilities

```dart
// Data layer - handles API communication
class UserApiService {
  Future<Map<String, dynamic>> fetchUserData(int id) async {
    final response = await http.get(Uri.parse('api/user/$id'));
    return jsonDecode(response.body);
  }
}

// Domain layer - business logic
class UserRepository {
  final UserApiService _api;
  final UserCacheService _cache;

  UserRepository(this._api, this._cache);

  Future<User> getUser(int id) async {
    final data = await _api.fetchUserData(id);
    await _cache.saveUser(data);
    return User.fromJson(data);
  }
}

// Presentation layer - only UI
class UserProfileWidget extends StatelessWidget {
  final User user;

  const UserProfileWidget({required this.user});

  @override
  Widget build(BuildContext context) {
    return Text(user.name);
  }
}
```

**Why It Matters:**
- Each class can be tested independently
- Changes to API don't affect UI code
- Caching logic can be modified without touching other layers

---

## O - Open/Closed Principle (OCP)

**Software entities should be open for extension but closed for modification.**

Design classes that can be extended without modifying their source code.

### ❌ Don't: Modifying Existing Code

```dart
class PaymentProcessor {
  void processPayment(String type, double amount) {
    if (type == 'credit_card') {
      // Credit card logic
      print('Processing credit card: \$$amount');
    } else if (type == 'paypal') {
      // PayPal logic
      print('Processing PayPal: \$$amount');
    } else if (type == 'crypto') {
      // Adding new payment = modifying this class
      print('Processing crypto: \$$amount');
    }
  }
}
```

### ✅ Do: Extension Through Abstraction

```dart
// Define a contract
abstract class PaymentMethod {
  Future<bool> process(double amount);
}

// Implement specific methods
class CreditCardPayment implements PaymentMethod {
  @override
  Future<bool> process(double amount) async {
    print('Processing credit card: \$$amount');
    return true;
  }
}

class PayPalPayment implements PaymentMethod {
  @override
  Future<bool> process(double amount) async {
    print('Processing PayPal: \$$amount');
    return true;
  }
}

// Adding new payment = adding new class (no modification needed)
class CryptoPayment implements PaymentMethod {
  @override
  Future<bool> process(double amount) async {
    print('Processing crypto: \$$amount');
    return true;
  }
}

// Processor works with any payment method
class PaymentProcessor {
  Future<bool> processPayment(PaymentMethod method, double amount) {
    return method.process(amount);
  }
}
```

**Why It Matters:**
- New features don't risk breaking existing functionality
- Easier to add new payment methods
- Each payment method can be tested in isolation

---

## L - Liskov Substitution Principle (LSP)

**Objects of a superclass should be replaceable with objects of its subclasses without breaking the application.**

Subclasses must honor the contract established by their parent class.

### ❌ Don't: Breaking Parent Contract

```dart
class Bird {
  void fly() {
    print('Flying...');
  }
}

class Penguin extends Bird {
  @override
  void fly() {
    throw Exception('Penguins cannot fly!'); // Breaks contract!
  }
}

void makeBirdFly(Bird bird) {
  bird.fly(); // Crashes with Penguin
}
```

### ✅ Do: Proper Abstraction

```dart
abstract class Bird {
  void move();
}

abstract class FlyingBird extends Bird {
  void fly();

  @override
  void move() => fly();
}

abstract class WalkingBird extends Bird {
  void walk();

  @override
  void move() => walk();
}

class Eagle extends FlyingBird {
  @override
  void fly() => print('Eagle soaring...');
}

class Penguin extends WalkingBird {
  @override
  void walk() => print('Penguin waddling...');
}

// Works with any bird
void makeBirdMove(Bird bird) {
  bird.move(); // Always works
}
```

### Flutter Example: Widget Contracts

```dart
// Base button contract
abstract class AppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const AppButton({required this.onPressed, required this.label});
}

// All buttons can be used interchangeably
class PrimaryButton extends AppButton {
  const PrimaryButton({required super.onPressed, required super.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}

class SecondaryButton extends AppButton {
  const SecondaryButton({required super.onPressed, required super.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}
```

**Why It Matters:**
- Code using base class works with all subclasses
- No runtime surprises from substitution
- Enables polymorphism

---

## I - Interface Segregation Principle (ISP)

**Clients should not be forced to depend on interfaces they don't use.**

Create small, focused interfaces rather than large, monolithic ones.

### ❌ Don't: Fat Interface

```dart
abstract class Worker {
  void work();
  void eat();
  void sleep();
  void attendMeeting();
  void writeReport();
}

// Robot forced to implement methods it can't use
class Robot implements Worker {
  @override
  void work() => print('Working...');

  @override
  void eat() => throw UnimplementedError(); // Robots don't eat!

  @override
  void sleep() => throw UnimplementedError(); // Robots don't sleep!

  @override
  void attendMeeting() => print('Attending...');

  @override
  void writeReport() => print('Generating report...');
}
```

### ✅ Do: Segregated Interfaces

```dart
abstract class Workable {
  void work();
}

abstract class Eatable {
  void eat();
}

abstract class Sleepable {
  void sleep();
}

abstract class Meetable {
  void attendMeeting();
}

// Human implements all relevant interfaces
class Human implements Workable, Eatable, Sleepable, Meetable {
  @override
  void work() => print('Working...');

  @override
  void eat() => print('Eating...');

  @override
  void sleep() => print('Sleeping...');

  @override
  void attendMeeting() => print('Attending...');
}

// Robot only implements what it can do
class Robot implements Workable, Meetable {
  @override
  void work() => print('Working...');

  @override
  void attendMeeting() => print('Attending...');
}
```

### Flutter Example: Repository Interfaces

```dart
// Instead of one large repository interface
// ❌ abstract class UserRepository {
//   Future<User> getUser(int id);
//   Future<void> saveUser(User user);
//   Future<void> deleteUser(int id);
//   Future<List<User>> searchUsers(String query);
//   Future<void> uploadAvatar(int id, File file);
// }

// ✅ Segregated interfaces
abstract class UserReader {
  Future<User> getUser(int id);
  Future<List<User>> searchUsers(String query);
}

abstract class UserWriter {
  Future<void> saveUser(User user);
  Future<void> deleteUser(int id);
}

abstract class AvatarManager {
  Future<void> uploadAvatar(int id, File file);
}

// Implement only what you need
class UserDisplayService implements UserReader {
  @override
  Future<User> getUser(int id) async { /* ... */ }

  @override
  Future<List<User>> searchUsers(String query) async { /* ... */ }
}
```

**Why It Matters:**
- Classes only depend on methods they actually use
- Easier to implement and mock for testing
- Changes to one interface don't affect unrelated classes

---

## D - Dependency Inversion Principle (DIP)

**High-level modules should not depend on low-level modules. Both should depend on abstractions.**

Depend on interfaces/abstract classes, not concrete implementations.

### ❌ Don't: Direct Dependency

```dart
class HttpUserService {
  Future<User> fetchUser(int id) async {
    // HTTP implementation details
    final response = await http.get(Uri.parse('api/user/$id'));
    return User.fromJson(jsonDecode(response.body));
  }
}

class UserController {
  // Directly depends on HTTP implementation
  final HttpUserService _service = HttpUserService();

  Future<User> loadUser(int id) => _service.fetchUser(id);
}
```

### ✅ Do: Depend on Abstraction

```dart
// Abstraction
abstract class UserService {
  Future<User> fetchUser(int id);
}

// HTTP implementation
class HttpUserService implements UserService {
  @override
  Future<User> fetchUser(int id) async {
    final response = await http.get(Uri.parse('api/user/$id'));
    return User.fromJson(jsonDecode(response.body));
  }
}

// Mock implementation for testing
class MockUserService implements UserService {
  @override
  Future<User> fetchUser(int id) async {
    return User(id: id, name: 'Test User');
  }
}

// Depends on abstraction, injected via constructor
class UserController {
  final UserService _service;

  UserController(this._service);

  Future<User> loadUser(int id) => _service.fetchUser(id);
}

// Usage with dependency injection (GetIt example)
final getIt = GetIt.instance;

void setupDependencies() {
  // Register abstraction with implementation
  getIt.registerSingleton<UserService>(HttpUserService());
}

// In production
final controller = UserController(getIt<UserService>());

// In tests
final testController = UserController(MockUserService());
```

### Flutter Provider Example

```dart
// Abstract service
abstract class AuthService {
  Future<User?> getCurrentUser();
  Future<void> signIn(String email, String password);
  Future<void> signOut();
}

// Concrete implementation
class FirebaseAuthService implements AuthService {
  @override
  Future<User?> getCurrentUser() async { /* Firebase impl */ }

  @override
  Future<void> signIn(String email, String password) async { /* ... */ }

  @override
  Future<void> signOut() async { /* ... */ }
}

// Provide abstraction
void main() {
  runApp(
    Provider<AuthService>(
      create: (_) => FirebaseAuthService(),
      child: MyApp(),
    ),
  );
}

// Consume abstraction
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Depends on abstraction, not FirebaseAuthService
    final authService = context.read<AuthService>();

    return ElevatedButton(
      onPressed: () => authService.signIn(email, password),
      child: Text('Sign In'),
    );
  }
}
```

**Why It Matters:**
- Easy to swap implementations (Firebase → Supabase)
- Enables unit testing with mocks
- Reduces coupling between layers
- Supports multiple implementations (dev/prod/test)

---

## Summary

| Principle | Key Question |
|-----------|--------------|
| **SRP** | Does this class have more than one reason to change? |
| **OCP** | Can I add new behavior without modifying existing code? |
| **LSP** | Can I substitute any subclass without breaking code? |
| **ISP** | Are classes forced to implement methods they don't use? |
| **DIP** | Am I depending on concrete classes or abstractions? |

## References

- [SOLID Principles in Dart](https://dart.dev/guides/language/effective-dart)
- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Dependency Injection with GetIt](https://pub.dev/packages/get_it)
