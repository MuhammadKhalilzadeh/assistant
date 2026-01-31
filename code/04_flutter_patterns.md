# Flutter Patterns & Widget Composition

This guide covers Flutter-specific patterns, widget composition strategies, and state management best practices.

---

## Widget Composition

### Stateless vs Stateful

Choose the right widget type based on your needs.

```dart
// ✅ Use StatelessWidget when:
// - Widget only depends on its constructor parameters
// - No internal state that changes over time
class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  const UserAvatar({
    required this.imageUrl,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: NetworkImage(imageUrl),
    );
  }
}

// ✅ Use StatefulWidget when:
// - Widget has mutable internal state
// - Needs to use controllers, animations, or streams
class CounterWidget extends StatefulWidget {
  final int initialValue;

  const CounterWidget({this.initialValue = 0});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.initialValue;
  }

  void _increment() => setState(() => _count++);

  @override
  Widget build(BuildContext context) {
    return Text('Count: $_count');
  }
}
```

### Breaking Down Large Widgets

Split large widgets into smaller, focused components.

```dart
// ❌ Don't: Monolithic widget
class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Column(
        children: [
          // 50+ lines of avatar code
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 3),
            ),
            child: ClipOval(
              child: Image.network(user.avatarUrl, fit: BoxFit.cover),
            ),
          ),
          // 30+ lines of info section
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(user.name, style: TextStyle(fontSize: 24)),
                Text(user.email),
                Text(user.bio),
              ],
            ),
          ),
          // 40+ lines of action buttons
          Row(
            children: [
              ElevatedButton(onPressed: () {}, child: Text('Edit')),
              ElevatedButton(onPressed: () {}, child: Text('Settings')),
            ],
          ),
        ],
      ),
    );
  }
}

// ✅ Do: Composed of smaller widgets
class UserProfileScreen extends StatelessWidget {
  final User user;

  const UserProfileScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Column(
        children: [
          ProfileAvatar(imageUrl: user.avatarUrl),
          ProfileInfo(user: user),
          ProfileActions(userId: user.id),
        ],
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  const ProfileAvatar({
    required this.imageUrl,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 3,
        ),
      ),
      child: ClipOval(
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}
```

### Composition Over Inheritance

Prefer composition using children and slots.

```dart
// ✅ Composable card with slots
class AppCard extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AppCard({
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 16)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    subtitle!,
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 16), trailing!],
          ],
        ),
      ),
    );
  }
}

// Usage
AppCard(
  leading: const Icon(Icons.person),
  title: Text(user.name),
  subtitle: Text(user.email),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => navigateToProfile(user),
)
```

---

## State Management Patterns

### Local State with setState

For simple, widget-local state.

```dart
class ExpandableSection extends StatefulWidget {
  final String title;
  final Widget content;

  const ExpandableSection({
    required this.title,
    required this.content,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  bool _isExpanded = false;

  void _toggle() => setState(() => _isExpanded = !_isExpanded);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(widget.title),
          trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
          onTap: _toggle,
        ),
        if (_isExpanded) widget.content,
      ],
    );
  }
}
```

### Lifting State Up

Share state between widgets by lifting it to a common ancestor.

```dart
// Parent owns the state
class ShoppingCart extends StatefulWidget {
  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  final List<Product> _items = [];

  void _addItem(Product product) {
    setState(() => _items.add(product));
  }

  void _removeItem(Product product) {
    setState(() => _items.remove(product));
  }

  double get _total => _items.fold(0, (sum, item) => sum + item.price);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pass state and callbacks down
        ProductList(onAddToCart: _addItem),
        CartSummary(items: _items, onRemove: _removeItem),
        CartTotal(total: _total),
      ],
    );
  }
}

// Children receive state via props
class CartSummary extends StatelessWidget {
  final List<Product> items;
  final ValueChanged<Product> onRemove;

  const CartSummary({
    required this.items,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.name),
          trailing: IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => onRemove(item),
          ),
        );
      },
    );
  }
}
```

### Provider Pattern

For app-wide or feature-wide state.

```dart
// State class (ChangeNotifier)
class CartNotifier extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);
  double get total => _items.fold(0, (sum, item) => sum + item.price);
  int get itemCount => _items.length;

  void add(Product product) {
    _items.add(product);
    notifyListeners();
  }

  void remove(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

// Provide at appropriate level
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartNotifier(),
      child: const MyApp(),
    ),
  );
}

// Consume in widgets
class CartIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemCount = context.watch<CartNotifier>().itemCount;

    return Badge(
      label: Text('$itemCount'),
      child: const Icon(Icons.shopping_cart),
    );
  }
}

class AddToCartButton extends StatelessWidget {
  final Product product;

  const AddToCartButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.read<CartNotifier>().add(product),
      child: const Text('Add to Cart'),
    );
  }
}
```

### Riverpod Pattern

Modern, compile-safe state management.

```dart
// Define providers
final cartProvider = StateNotifierProvider<CartNotifier, List<Product>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.price);
});

class CartNotifier extends StateNotifier<List<Product>> {
  CartNotifier() : super([]);

  void add(Product product) => state = [...state, product];
  void remove(Product product) => state = state.where((p) => p != product).toList();
  void clear() => state = [];
}

// Consume in widgets
class CartScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => ProductTile(product: items[index]),
          ),
        ),
        Text('Total: \$${total.toStringAsFixed(2)}'),
      ],
    );
  }
}
```

---

## Widget Lifecycle

### initState and dispose

Properly manage resources in StatefulWidgets.

```dart
class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final StreamSubscription<List<Result>> _subscription;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _controller = TextEditingController();
    _focusNode = FocusNode();

    // Subscribe to streams
    _subscription = searchService.results.listen(_onResults);

    // Request focus after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // Dispose in reverse order of initialization
    _subscription.cancel();
    _focusNode.dispose();
    _controller.dispose();

    super.dispose();
  }

  void _onResults(List<Result> results) {
    // Update state with results
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
    );
  }
}
```

### didChangeDependencies

React to inherited widget changes.

```dart
class ThemeAwareWidget extends StatefulWidget {
  @override
  State<ThemeAwareWidget> createState() => _ThemeAwareWidgetState();
}

class _ThemeAwareWidgetState extends State<ThemeAwareWidget> {
  late ThemeData _theme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Called when dependencies change (e.g., Theme, MediaQuery)
    _theme = Theme.of(context);
    _updateColorsBasedOnTheme();
  }

  void _updateColorsBasedOnTheme() {
    // Perform expensive calculations based on theme
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: _theme.primaryColor);
  }
}
```

### didUpdateWidget

React to parent widget rebuilds with new parameters.

```dart
class AnimatedCounter extends StatefulWidget {
  final int value;

  const AnimatedCounter({required this.value});

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _previousValue;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect value change and animate
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = lerpDouble(
          _previousValue.toDouble(),
          widget.value.toDouble(),
          _controller.value,
        )!;
        return Text(value.toStringAsFixed(0));
      },
    );
  }
}
```

---

## Common Patterns

### Builder Pattern

Build widgets based on async state.

```dart
// FutureBuilder for one-time async operations
class UserProfile extends StatelessWidget {
  final int userId;

  const UserProfile({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: userService.getUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return ErrorWidget(error: snapshot.error!);
        }

        final user = snapshot.data!;
        return UserCard(user: user);
      },
    );
  }
}

// StreamBuilder for continuous updates
class MessageList extends StatelessWidget {
  final String chatId;

  const MessageList({required this.chatId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: chatService.getMessages(chatId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final messages = snapshot.data!;
        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) => MessageBubble(
            message: messages[index],
          ),
        );
      },
    );
  }
}
```

### Factory Constructors

Create different widget configurations.

```dart
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool isOutlined;

  const AppButton({
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.isOutlined = false,
  });

  // Factory for primary button
  factory AppButton.primary({
    required String label,
    required VoidCallback onPressed,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  // Factory for secondary button
  factory AppButton.secondary({
    required String label,
    required VoidCallback onPressed,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      backgroundColor: Colors.grey,
      textColor: Colors.black,
    );
  }

  // Factory for outlined button
  factory AppButton.outlined({
    required String label,
    required VoidCallback onPressed,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      isOutlined: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
      ),
      child: Text(label),
    );
  }
}
```

### Immutable Models with copyWith

```dart
class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final UserRole role;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.role = UserRole.member,
  });

  // copyWith for immutable updates
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
    );
  }

  // From JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.values.byName(json['role'] as String),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role.name,
    };
  }
}

// Usage
final updatedUser = user.copyWith(name: 'New Name');
```

### Callback Patterns

```dart
// Simple callback
typedef VoidCallback = void Function();

// Value callback
typedef ValueChanged<T> = void Function(T value);

// Async callback
typedef AsyncCallback = Future<void> Function();

// Example usage
class SearchField extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback? onClear;

  const SearchField({
    required this.onSearch,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: onSearch,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: onClear,
        ),
      ),
    );
  }
}
```

---

## Summary

| Pattern | Use Case |
|---------|----------|
| **StatelessWidget** | UI depends only on constructor params |
| **StatefulWidget** | Widget has mutable internal state |
| **Lifting State** | Share state between sibling widgets |
| **Provider/Riverpod** | App-wide or feature-wide state |
| **FutureBuilder** | One-time async data fetching |
| **StreamBuilder** | Continuous data streams |
| **copyWith** | Immutable model updates |

## References

- [Flutter Widget Lifecycle](https://api.flutter.dev/flutter/widgets/State-class.html)
- [Provider Package](https://pub.dev/packages/provider)
- [Riverpod Package](https://riverpod.dev/)
- [Flutter State Management](https://docs.flutter.dev/development/data-and-backend/state-mgmt)
