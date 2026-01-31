# Flutter Performance Best Practices

This guide covers performance optimization techniques to ensure your Flutter app runs smoothly at 60fps (or 120fps on supported devices).

---

## The Frame Budget

Flutter aims for 60 frames per second (fps), giving you approximately **16 milliseconds** to build and render each frame.

```
16ms Frame Budget
├── Build Phase    (~8ms max)
│   └── Widget tree construction
├── Layout Phase   (~4ms)
│   └── Size and position calculations
├── Paint Phase    (~2ms)
│   └── Drawing commands
└── Composite      (~2ms)
    └── GPU rendering
```

### Monitoring Performance

```dart
// Enable performance overlay
MaterialApp(
  showPerformanceOverlay: true,
  // ...
);

// Use DevTools
// Run: flutter run --profile
// Then open DevTools from VS Code or browser
```

---

## Build Method Optimization

The `build()` method is called frequently. Keep it fast and efficient.

### ❌ Don't: Heavy Computation in Build

```dart
class ExpensiveWidget extends StatelessWidget {
  final List<Item> items;

  const ExpensiveWidget({required this.items});

  @override
  Widget build(BuildContext context) {
    // ❌ Expensive computation on every build
    final sortedItems = items.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final filteredItems = sortedItems
        .where((item) => item.isActive)
        .toList();

    final groupedItems = <String, List<Item>>{};
    for (final item in filteredItems) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView(
      children: groupedItems.entries.map((entry) {
        return Column(
          children: entry.value.map((item) => ItemTile(item: item)).toList(),
        );
      }).toList(),
    );
  }
}
```

### ✅ Do: Compute Outside Build

```dart
class EfficientWidget extends StatefulWidget {
  final List<Item> items;

  const EfficientWidget({required this.items});

  @override
  State<EfficientWidget> createState() => _EfficientWidgetState();
}

class _EfficientWidgetState extends State<EfficientWidget> {
  late Map<String, List<Item>> _groupedItems;

  @override
  void initState() {
    super.initState();
    _processItems();
  }

  @override
  void didUpdateWidget(EfficientWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _processItems();
    }
  }

  void _processItems() {
    final sortedItems = widget.items.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final filteredItems = sortedItems.where((item) => item.isActive);

    _groupedItems = {};
    for (final item in filteredItems) {
      _groupedItems.putIfAbsent(item.category, () => []).add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Build only constructs widgets
    return ListView(
      children: _groupedItems.entries.map((entry) {
        return Column(
          children: entry.value.map((item) => ItemTile(item: item)).toList(),
        );
      }).toList(),
    );
  }
}
```

### Avoid Creating Objects in Build

```dart
// ❌ Creates new objects on every build
@override
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(  // New object every build
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
        ),
      ],
    ),
    child: child,
  );
}

// ✅ Use const or static objects
class AppStyles {
  static const cardDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    boxShadow: [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 8,
      ),
    ],
  );
}

@override
Widget build(BuildContext context) {
  return Container(
    decoration: AppStyles.cardDecoration,
    child: child,
  );
}
```

---

## Widget Optimization

### Use const Constructors

`const` widgets are created once and reused.

```dart
// ❌ Rebuilds every time parent rebuilds
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Static Title'),  // Rebuilds unnecessarily
      DynamicContent(data: data),
    ],
  );
}

// ✅ const widgets skip rebuild
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      const Text('Static Title'),  // Never rebuilds
      DynamicContent(data: data),
    ],
  );
}

// ✅ Make widgets const-constructible
class StaticHeader extends StatelessWidget {
  const StaticHeader({super.key});  // const constructor

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('Header'),
    );
  }
}
```

### Use Keys for Lists

Keys help Flutter identify widgets when their position changes.

```dart
// ❌ Without keys - poor performance when reordering
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemTile(item: items[index]);
  },
);

// ✅ With keys - efficient updates
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return ItemTile(
      key: ValueKey(item.id),  // Unique key
      item: item,
    );
  },
);
```

### RepaintBoundary

Isolate frequently changing widgets to prevent unnecessary repaints.

```dart
// Animation causes entire screen to repaint
class AnimatedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Header(),
        const Content(),
        AnimatedWidget(),  // Repaints everything
      ],
    );
  }
}

// ✅ Isolate the animated widget
class OptimizedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Header(),
        const Content(),
        RepaintBoundary(  // Isolates repaints
          child: AnimatedWidget(),
        ),
      ],
    );
  }
}
```

### Minimize Widget Depth

Deep widget trees are more expensive to traverse.

```dart
// ❌ Unnecessary nesting
Container(
  child: Padding(
    padding: EdgeInsets.all(8),
    child: Center(
      child: Container(
        decoration: BoxDecoration(...),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Hello'),
        ),
      ),
    ),
  ),
);

// ✅ Flatten where possible
Container(
  padding: const EdgeInsets.all(24),  // Combined padding
  alignment: Alignment.center,
  decoration: BoxDecoration(...),
  child: const Text('Hello'),
);
```

---

## List Performance

### Use ListView.builder for Long Lists

```dart
// ❌ Creates all widgets upfront
ListView(
  children: items.map((item) => ItemWidget(item: item)).toList(),
);

// ✅ Lazily creates visible widgets only
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(item: items[index]),
);

// ✅ Separated lists with headers
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (context, index) => const Divider(),
  itemBuilder: (context, index) => ItemWidget(item: items[index]),
);
```

### Specify itemExtent for Fixed Height Items

```dart
// ❌ Flutter calculates each item's height
ListView.builder(
  itemCount: 1000,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
);

// ✅ Fixed height = faster scrolling
ListView.builder(
  itemCount: 1000,
  itemExtent: 56.0,  // ListTile default height
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
);
```

### Lazy Loading / Pagination

```dart
class PaginatedList extends StatefulWidget {
  @override
  State<PaginatedList> createState() => _PaginatedListState();
}

class _PaginatedListState extends State<PaginatedList> {
  final List<Item> _items = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final newItems = await api.fetchItems(offset: _items.length);

    setState(() {
      _items.addAll(newItems);
      _isLoading = false;
      _hasMore = newItems.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return ItemTile(item: _items[index]);
      },
    );
  }
}
```

---

## Memory Management

### Dispose Controllers and Streams

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final TextEditingController _textController;
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final StreamSubscription<Event> _subscription;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController();
    _animationController = AnimationController(vsync: this);
    _subscription = eventStream.listen(_onEvent);
  }

  @override
  void dispose() {
    // ✅ Always dispose in reverse order
    _subscription.cancel();
    _animationController.dispose();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onEvent(Event event) {
    // Handle event
  }

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _textController);
  }
}
```

### Avoid Memory Leaks

```dart
// ❌ Closure captures 'this', preventing garbage collection
class LeakyWidget extends StatefulWidget {
  @override
  State<LeakyWidget> createState() => _LeakyWidgetState();
}

class _LeakyWidgetState extends State<LeakyWidget> {
  @override
  void initState() {
    super.initState();
    // This closure keeps reference to state even after dispose
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});  // Crash if widget is disposed!
    });
  }
}

// ✅ Properly manage timers
class SafeWidget extends StatefulWidget {
  @override
  State<SafeWidget> createState() => _SafeWidgetState();
}

class _SafeWidgetState extends State<SafeWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {  // Check if still mounted
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();  // Cancel timer
    super.dispose();
  }
}
```

### Image Caching

```dart
// ✅ Use cached_network_image package
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  memCacheHeight: 200,  // Limit memory cache size
);

// ✅ Precache important images
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(AssetImage('assets/hero.png'), context);
}

// ✅ Clear cache when needed
class ImageCacheManager {
  static void clearCache() {
    imageCache.clear();
    imageCache.clearLiveImages();
  }
}
```

---

## String Operations

### Use StringBuffer for Concatenation

```dart
// ❌ Creates many intermediate strings
String buildMessage(List<String> items) {
  String result = '';
  for (final item in items) {
    result += item + ', ';  // Creates new string each iteration
  }
  return result;
}

// ✅ StringBuffer is more efficient
String buildMessage(List<String> items) {
  final buffer = StringBuffer();
  for (final item in items) {
    buffer.write(item);
    buffer.write(', ');
  }
  return buffer.toString();
}

// ✅ Or use join for simple cases
String buildMessage(List<String> items) {
  return items.join(', ');
}
```

---

## Async Operations

### Use Isolates for Heavy Computation

```dart
import 'dart:isolate';

// ❌ Heavy computation on main isolate blocks UI
Future<List<ProcessedItem>> processItems(List<Item> items) async {
  return items.map((item) => heavyProcessing(item)).toList();
}

// ✅ Use compute for expensive operations
Future<List<ProcessedItem>> processItems(List<Item> items) async {
  return compute(_processInIsolate, items);
}

List<ProcessedItem> _processInIsolate(List<Item> items) {
  return items.map((item) => heavyProcessing(item)).toList();
}

// ✅ For JSON parsing
Future<List<User>> parseUsers(String jsonString) async {
  return compute(_parseUsersJson, jsonString);
}

List<User> _parseUsersJson(String jsonString) {
  final list = jsonDecode(jsonString) as List;
  return list.map((json) => User.fromJson(json)).toList();
}
```

### Debounce and Throttle

```dart
class SearchField extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const SearchField({required this.onSearch});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  Timer? _debounce;

  void _onChanged(String value) {
    // Cancel previous timer
    _debounce?.cancel();

    // Start new timer
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(onChanged: _onChanged);
  }
}
```

---

## Performance Checklist

### Build Phase
- [ ] No heavy computation in `build()`
- [ ] Using `const` constructors where possible
- [ ] Not creating new objects every build
- [ ] Widget tree is reasonably flat

### Lists
- [ ] Using `ListView.builder` for long lists
- [ ] Using `itemExtent` for fixed-height items
- [ ] Using proper keys for list items
- [ ] Implementing pagination for large datasets

### Memory
- [ ] Disposing controllers in `dispose()`
- [ ] Canceling subscriptions and timers
- [ ] Using `mounted` check before `setState`
- [ ] Caching images appropriately

### Rendering
- [ ] Using `RepaintBoundary` for animated sections
- [ ] Avoiding `Opacity` widget (use `AnimatedOpacity`)
- [ ] Not using `ClipPath` excessively

### Async
- [ ] Using `compute` for heavy processing
- [ ] Debouncing search inputs
- [ ] Not blocking main isolate

## References

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools)
- [Understanding Isolates](https://dart.dev/language/isolates)
- [Widget Rebuilds Explained](https://docs.flutter.dev/perf/rendering-performance)
