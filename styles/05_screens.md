# Screen Structure Patterns

This document defines the standard patterns for screen layout across the app.

## Screen Types

The app has two primary screen types:
1. **Home/Dashboard** - Light pink background with white cards
2. **Detail Pages** - Light pink background with white elevated cards

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
          AppTheme.backgroundColor,  // #FFF5F5 (light pink)
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
            // White feature cards with shadows
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
  backgroundColor: AppTheme.backgroundColor,  // Light pink #FFF5F5
  body: SafeArea(
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
  floatingActionButton: FloatingActionButton(
    onPressed: _handleAdd,
    backgroundColor: AppTheme.primaryColor,  // Red
    foregroundColor: Colors.white,
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
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        ),
        const SizedBox(width: 8),
        Text(
          'Page Title',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Optional: Right side actions
        const Spacer(),
        IconButton(
          onPressed: _handleAction,
          icon: Icon(Icons.more_vert, color: AppTheme.textPrimary),
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
| Back icon | `Icons.arrow_back`, `AppTheme.textPrimary` |
| Icon-to-title gap | 8px |
| Title font size | 24px |
| Title font weight | Bold |
| Title color | `AppTheme.textPrimary` |

---

## Content Area Layout

### Summary Card (Top of Detail Pages)
```dart
Widget _buildSummaryCard(double padding) {
  return Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: AppTheme.cardShadow,
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
                Text('Today\'s Progress',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text('3 of 5 completed',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
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
      Text(
        'All Items',
        style: TextStyle(
          color: AppTheme.textPrimary,
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
    backgroundColor: AppTheme.primaryColor,  // Red
    foregroundColor: Colors.white,
    child: const Icon(Icons.add),
  ),
)
```

| Property | Value |
|----------|-------|
| Position | Default (bottom right) |
| Background | `AppTheme.primaryColor` (red) |
| Foreground | White |
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
          color: AppTheme.textTertiary,
        ),
        const SizedBox(height: 16),
        Text(
          'No items yet',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap + to add your first item',
          style: TextStyle(
            color: AppTheme.textTertiary,
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

## Background Color Guide

| Screen Type | Background |
|-------------|------------|
| All screens | `AppTheme.backgroundColor` (#FFF5F5, light pink) |
| Cards | White with `AppTheme.cardShadow` |
| Dialogs/Sheets | White |

---

## Screen Checklist

When creating a new screen, ensure:

- [ ] Uses `SafeArea` wrapper
- [ ] Has light pink background (`AppTheme.backgroundColor`)
- [ ] Uses custom AppBar pattern (not Material AppBar)
- [ ] Uses responsive padding formula
- [ ] Has white elevated summary card at top (if applicable)
- [ ] Uses white elevated list items with shadows
- [ ] Has red FAB with white foreground (if add action needed)
- [ ] Has empty state for empty lists
- [ ] Uses `NavigationUtils.navigateWithFade` for navigation
- [ ] Uses dark text (`AppTheme.textPrimary`) on light backgrounds
- [ ] Uses red (`AppTheme.primaryColor`) for accents and highlights
