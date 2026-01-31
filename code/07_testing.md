# Testing Guidelines for Flutter

This guide covers best practices for unit tests, widget tests, and integration tests in Flutter applications.

---

## The Testing Pyramid

```
        /\
       /  \      Integration Tests
      /    \     (Few, slow, expensive)
     /──────\
    /        \   Widget Tests
   /          \  (Medium amount, moderate speed)
  /────────────\
 /              \ Unit Tests
/________________\ (Many, fast, cheap)
```

| Type | Speed | Scope | Quantity |
|------|-------|-------|----------|
| Unit | Fast | Single function/class | Many |
| Widget | Medium | Single widget | Medium |
| Integration | Slow | Full app flow | Few |

---

## Unit Tests

Test individual functions, classes, and business logic in isolation.

### Basic Structure (Arrange-Act-Assert)

```dart
import 'package:test/test.dart';

void main() {
  group('Calculator', () {
    late Calculator calculator;

    setUp(() {
      // Arrange - set up test dependencies
      calculator = Calculator();
    });

    test('adds two numbers correctly', () {
      // Act - perform the action
      final result = calculator.add(2, 3);

      // Assert - verify the result
      expect(result, equals(5));
    });

    test('subtracts two numbers correctly', () {
      final result = calculator.subtract(5, 3);
      expect(result, equals(2));
    });

    test('throws when dividing by zero', () {
      expect(
        () => calculator.divide(10, 0),
        throwsA(isA<DivisionByZeroException>()),
      );
    });
  });
}
```

### Testing Async Code

```dart
void main() {
  group('UserRepository', () {
    late UserRepository repository;
    late MockApiService mockApi;

    setUp(() {
      mockApi = MockApiService();
      repository = UserRepository(mockApi);
    });

    test('getUser returns user from API', () async {
      // Arrange
      when(mockApi.fetchUser(1)).thenAnswer(
        (_) async => UserModel(id: 1, name: 'John'),
      );

      // Act
      final user = await repository.getUser(1);

      // Assert
      expect(user.name, equals('John'));
      verify(mockApi.fetchUser(1)).called(1);
    });

    test('getUser throws when API fails', () async {
      when(mockApi.fetchUser(any)).thenThrow(NetworkException());

      expect(
        () => repository.getUser(1),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
```

### Mocking Dependencies

Using `mocktail` package:

```dart
import 'package:mocktail/mocktail.dart';

// Create mock classes
class MockUserService extends Mock implements UserService {}
class MockLogger extends Mock implements Logger {}

void main() {
  late AuthController controller;
  late MockUserService mockUserService;
  late MockLogger mockLogger;

  setUp(() {
    mockUserService = MockUserService();
    mockLogger = MockLogger();
    controller = AuthController(
      userService: mockUserService,
      logger: mockLogger,
    );
  });

  test('login succeeds with valid credentials', () async {
    // Arrange
    when(() => mockUserService.authenticate('user', 'pass'))
        .thenAnswer((_) async => User(id: '1', name: 'User'));

    // Act
    final result = await controller.login('user', 'pass');

    // Assert
    expect(result, isTrue);
    verify(() => mockUserService.authenticate('user', 'pass')).called(1);
    verify(() => mockLogger.info(any())).called(1);
  });

  test('login fails with invalid credentials', () async {
    when(() => mockUserService.authenticate(any(), any()))
        .thenThrow(InvalidCredentialsException());

    final result = await controller.login('user', 'wrong');

    expect(result, isFalse);
    verify(() => mockLogger.error(any())).called(1);
  });
}
```

### Testing Streams

```dart
void main() {
  group('MessageStream', () {
    late MessageService service;

    setUp(() {
      service = MessageService();
    });

    test('emits messages in order', () {
      final messages = ['Hello', 'World', 'Test'];

      expect(
        service.messageStream,
        emitsInOrder([
          'Hello',
          'World',
          'Test',
          emitsDone,
        ]),
      );

      for (final message in messages) {
        service.addMessage(message);
      }
      service.close();
    });

    test('emits error on failure', () {
      expect(
        service.messageStream,
        emitsError(isA<MessageException>()),
      );

      service.emitError(MessageException('Test error'));
    });
  });
}
```

---

## Widget Tests

Test individual widgets in isolation with mock dependencies.

### Basic Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CounterWidget', () {
    testWidgets('displays initial count', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: CounterWidget(initialValue: 5),
        ),
      );

      // Assert
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('increments count when button pressed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CounterWidget(initialValue: 0),
        ),
      );

      // Verify initial state
      expect(find.text('0'), findsOneWidget);

      // Act - tap increment button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();  // Rebuild after state change

      // Assert
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('decrements count when minus button pressed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CounterWidget(initialValue: 5),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('4'), findsOneWidget);
    });
  });
}
```

### Finding Widgets

```dart
testWidgets('finding widgets examples', (tester) async {
  await tester.pumpWidget(MyApp());

  // By text
  expect(find.text('Submit'), findsOneWidget);

  // By type
  expect(find.byType(ElevatedButton), findsNWidgets(2));

  // By key
  expect(find.byKey(const Key('submit_button')), findsOneWidget);

  // By icon
  expect(find.byIcon(Icons.home), findsOneWidget);

  // By widget predicate
  expect(
    find.byWidgetPredicate(
      (widget) => widget is Text && widget.data!.contains('Welcome'),
    ),
    findsOneWidget,
  );

  // Descendant finder
  expect(
    find.descendant(
      of: find.byType(Card),
      matching: find.text('Title'),
    ),
    findsOneWidget,
  );
});
```

### Interacting with Widgets

```dart
testWidgets('widget interactions', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: MyForm()));

  // Enter text
  await tester.enterText(find.byType(TextField), 'Hello World');
  await tester.pump();

  // Tap
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();

  // Long press
  await tester.longPress(find.byType(ListTile));
  await tester.pump();

  // Drag
  await tester.drag(find.byType(Dismissible), const Offset(500, 0));
  await tester.pumpAndSettle();  // Wait for animations

  // Scroll
  await tester.scrollUntilVisible(
    find.text('Item 50'),
    500.0,
    scrollable: find.byType(Scrollable),
  );
});
```

### Testing with Providers

```dart
testWidgets('widget with provider', (tester) async {
  final mockRepository = MockUserRepository();
  when(() => mockRepository.getUser(1))
      .thenAnswer((_) async => User(id: 1, name: 'Test User'));

  await tester.pumpWidget(
    MaterialApp(
      home: Provider<UserRepository>.value(
        value: mockRepository,
        child: const UserProfileScreen(userId: 1),
      ),
    ),
  );

  // Wait for async operations
  await tester.pumpAndSettle();

  expect(find.text('Test User'), findsOneWidget);
});
```

### Testing Animations

```dart
testWidgets('animation test', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: AnimatedScreen()));

  // Trigger animation
  await tester.tap(find.byType(FloatingActionButton));

  // Pump specific duration
  await tester.pump(const Duration(milliseconds: 100));
  // Widget should be mid-animation

  // Complete all animations
  await tester.pumpAndSettle();
  // All animations complete
});
```

---

## Integration Tests

Test complete user flows across multiple screens.

### Setup

```yaml
# pubspec.yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  flutter_test:
    sdk: flutter
```

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('complete login flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Submit
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify navigation to home
      expect(find.text('Welcome'), findsOneWidget);
    });

    testWidgets('add item to cart', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find product
      await tester.tap(find.text('Product A'));
      await tester.pumpAndSettle();

      // Add to cart
      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      // Navigate to cart
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Verify item in cart
      expect(find.text('Product A'), findsOneWidget);
      expect(find.text('\$19.99'), findsOneWidget);
    });
  });
}
```

### Running Integration Tests

```bash
# Run on connected device/emulator
flutter test integration_test

# Run specific test file
flutter test integration_test/login_test.dart

# Run with coverage
flutter test integration_test --coverage
```

---

## Testing Best Practices

### Descriptive Test Names

```dart
// ❌ Vague test names
test('test1', () { ... });
test('works correctly', () { ... });
test('handles error', () { ... });

// ✅ Descriptive test names
test('getUser returns user with matching id from API', () { ... });
test('getUser throws UserNotFoundException when user does not exist', () { ... });
test('getUser returns cached user when network is unavailable', () { ... });
```

### Test One Thing Per Test

```dart
// ❌ Testing multiple things
test('user operations', () {
  final user = User(name: 'John');
  expect(user.name, 'John');

  user.updateName('Jane');
  expect(user.name, 'Jane');

  expect(() => user.updateName(''), throwsException);
});

// ✅ Separate tests
test('User has correct initial name', () {
  final user = User(name: 'John');
  expect(user.name, 'John');
});

test('updateName changes user name', () {
  final user = User(name: 'John');
  user.updateName('Jane');
  expect(user.name, 'Jane');
});

test('updateName throws when name is empty', () {
  final user = User(name: 'John');
  expect(() => user.updateName(''), throwsArgumentError);
});
```

### Group Related Tests

```dart
void main() {
  group('UserRepository', () {
    group('getUser', () {
      test('returns user when API call succeeds', () { ... });
      test('throws when user not found', () { ... });
      test('returns cached user on network failure', () { ... });
    });

    group('createUser', () {
      test('creates user and returns id', () { ... });
      test('throws on duplicate email', () { ... });
    });

    group('deleteUser', () {
      test('deletes user by id', () { ... });
      test('throws when user not found', () { ... });
    });
  });
}
```

### Use setUp and tearDown

```dart
void main() {
  late Database database;
  late UserRepository repository;

  setUpAll(() async {
    // Run once before all tests
    database = await Database.initialize(':memory:');
  });

  setUp(() async {
    // Run before each test
    await database.clear();
    repository = UserRepository(database);
  });

  tearDown(() async {
    // Run after each test
    await database.clear();
  });

  tearDownAll(() async {
    // Run once after all tests
    await database.close();
  });

  test('creates user', () async {
    await repository.create(User(name: 'John'));
    final users = await repository.getAll();
    expect(users.length, 1);
  });
}
```

### Test Edge Cases

```dart
group('EmailValidator', () {
  test('returns true for valid email', () {
    expect(isValidEmail('user@example.com'), isTrue);
  });

  test('returns false for email without @', () {
    expect(isValidEmail('userexample.com'), isFalse);
  });

  test('returns false for email without domain', () {
    expect(isValidEmail('user@'), isFalse);
  });

  test('returns false for empty string', () {
    expect(isValidEmail(''), isFalse);
  });

  test('handles email with subdomain', () {
    expect(isValidEmail('user@mail.example.com'), isTrue);
  });

  test('handles email with plus sign', () {
    expect(isValidEmail('user+tag@example.com'), isTrue);
  });
});
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze

      - name: Run unit and widget tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info
```

### Running Tests Locally

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/user_test.dart

# Run tests matching pattern
flutter test --name "UserRepository"

# Run in verbose mode
flutter test --reporter expanded
```

---

## Test Coverage

### Generating Coverage Reports

```bash
# Generate coverage data
flutter test --coverage

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html
```

### Coverage Goals

| Layer | Target Coverage |
|-------|-----------------|
| Business Logic | 80-100% |
| Repositories | 70-90% |
| UI/Widgets | 50-70% |
| Integration | Key flows |

---

## Summary

| Test Type | What to Test | Tools |
|-----------|--------------|-------|
| **Unit** | Functions, classes, business logic | `test`, `mocktail` |
| **Widget** | Individual UI components | `flutter_test` |
| **Integration** | Complete user flows | `integration_test` |

## Testing Checklist

- [ ] Unit tests for all business logic
- [ ] Widget tests for reusable components
- [ ] Integration tests for critical user flows
- [ ] Edge cases covered
- [ ] Descriptive test names
- [ ] Tests are independent (no shared state)
- [ ] Mocks used for external dependencies
- [ ] CI pipeline runs tests automatically

## References

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Test-Driven Development](https://en.wikipedia.org/wiki/Test-driven_development)
