# Screen Structure Patterns

This document defines the standard patterns for screen layout across the app.

## Screen Types

The app has two primary screen types:
1. **Home/Dashboard** - Light background with colored cards
2. **Detail Pages** - Gradient background with glass-effect content

---

## Dashboard Screen Structure

### Home Tab
```dart
SafeArea(
  child: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.backgroundColor,  // #F8FAFC
          AppTheme.surfaceColor,     // #FFFFFF
        ],
      ),
    ),
    child: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(paddingValue),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Feature cards
            CustomTodosCard(...),
            SizedBox(height: paddingValue),
            CustomInboxCard(...),
            SizedBox(height: paddingValue),
            // ... more cards
          ],
        ),
      ),
    ),
  ),
)
```

### Dashboard with Bottom Navigation
```dart
Scaffold(
  body: _getCurrentPage(),
  bottomNavigationBar: CustomBottomNavigationBar(
    currentIndex: _currentIndex,
    onTap: _onTabTapped,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Jarvis'),
    ],
  ),
)
```

---

## Detail Page Structure

All detail pages follow this pattern:

```dart
Scaffold(
  body: SafeArea(
    child: Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,  // or secondaryGradient
      ),
      child: Column(
        children: [
          // Custom AppBar
          _buildAppBar(padding),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  children: [
                    _buildSummaryCard(padding),
                    SizedBox(height: padding),
                    _buildContentList(padding),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: _handleAdd,
    backgroundColor: Colors.white,
    foregroundColor: AppTheme.primaryColor,
    child: const Icon(Icons.add),
  ),
)
```

---

## Custom AppBar Pattern

The app uses a custom Row-based AppBar instead of Material AppBar:

```dart
Widget _buildAppBar(double padding) {
  return Padding(
    padding: EdgeInsets.all(padding),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        const SizedBox(width: 8),
        const Text(
          'Page Title',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Optional: Right side actions
        const Spacer(),
        IconButton(
          onPressed: _handleAction,
          icon: const Icon(Icons.more_vert, color: Colors.white),
        ),
      ],
    ),
  );
}
```

### AppBar Properties
| Property | Value |
|----------|-------|
| Padding | Same as content padding (responsive) |
| Back icon | `Icons.arrow_back`, white |
| Icon-to-title gap | 8px |
| Title font size | 24px |
| Title font weight | Bold |
| Title color | White |

---

## Content Area Layout

### Summary Card (Top of Detail Pages)
```dart
Widget _buildSummaryCard(double padding) {
  return Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Title + Subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today\'s Progress', /* title style */),
                SizedBox(height: 4),
                Text('3 of 5 completed', /* subtitle style */),
              ],
            ),
            // Right: Visual indicator
            _buildProgressCircle(),
          ],
        ),
        const SizedBox(height: 16),
        _buildProgressBar(),
      ],
    ),
  );
}
```

### List Section
```dart
Widget _buildList(List items, double padding) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'All Items',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      ...items.map((item) => _buildListItem(item, padding)),
    ],
  );
}
```

---

## FAB Placement and Styling

Standard FAB configuration:

```dart
Scaffold(
  // ...
  floatingActionButton: FloatingActionButton(
    onPressed: _handleAdd,
    backgroundColor: Colors.white,
    foregroundColor: AppTheme.primaryColor,
    child: const Icon(Icons.add),
  ),
)
```

| Property | Value |
|----------|-------|
| Position | Default (bottom right) |
| Background | White |
| Foreground | `AppTheme.primaryColor` |
| Icon | `Icons.add` (usually) |

---

## Empty State Pattern

When a list has no items:

```dart
Widget _buildEmptyState(double padding) {
  return Container(
    padding: EdgeInsets.all(padding * 2),  // Double padding
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 64,
          color: Colors.white.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'No items yet',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap + to add your first item',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
```

---

## Navigation Transitions

### Default Transition (Fade)
Used when navigating from dashboard to detail pages:

```dart
void _navigateTo(Widget page) {
  NavigationUtils.navigateWithFade(context, page);
}
```

```dart
// Implementation
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => page,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  },
  transitionDuration: const Duration(milliseconds: 300),
)
```

### Alternative Transition (Slide)
Available for horizontal navigation:

```dart
NavigationUtils.navigateWithSlide(context, page);
```

```dart
// Implementation
transitionsBuilder: (context, animation, secondaryAnimation, child) {
  const begin = Offset(1.0, 0.0);
  const end = Offset.zero;
  const curve = Curves.easeInOut;

  var tween = Tween(begin: begin, end: end).chain(
    CurveTween(curve: curve),
  );

  return SlideTransition(
    position: animation.drive(tween),
    child: child,
  );
}
```

### Transition Duration
- Default: 300ms
- Curve: `Curves.easeInOut`

---

## Gradient Selection Guide

| Screen Type | Gradient |
|-------------|----------|
| Productivity (Todos, Calendar, Focus, Habits) | `primaryGradient` |
| Health & Wellness (Weather, Water, Steps, Heart) | `secondaryGradient` |
| General/Mixed | `primaryGradient` |

---

## Screen Checklist

When creating a new screen, ensure:

- [ ] Uses `SafeArea` wrapper
- [ ] Has gradient background (`primaryGradient` or `secondaryGradient`)
- [ ] Uses custom AppBar pattern (not Material AppBar)
- [ ] Uses responsive padding formula
- [ ] Has glass-effect summary card at top (if applicable)
- [ ] Uses glass-effect list items
- [ ] Has white FAB with primary foreground (if add action needed)
- [ ] Has empty state for empty lists
- [ ] Uses `NavigationUtils.navigateWithFade` for navigation
