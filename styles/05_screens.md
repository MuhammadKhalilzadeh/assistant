# Screen Structure Patterns — Ember Dark

This document defines the standard patterns for screen layout across the app.

## Screen Types

The app has two primary screen types:
1. **Home/Dashboard** — Dark ambient gradient background with dark cards
2. **Detail Pages** — Dark scaffold with dark elevated cards

---

## Dashboard Screen Structure

### Home Tab
```dart
SafeArea(
  child: Container(
    decoration: const BoxDecoration(
      gradient: AppTheme.ambientGradient,  // #1C1C20 -> #141416
    ),
    child: Stack(
      children: [
        // Optional: Radial glow blob for ambient effect
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              gradient: AppTheme.glowGradient,
            ),
          ),
        ),
        // Bottom ambient glow
        Positioned(
          bottom: -100,
          left: 0,
          right: 0,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.bottomAmbientGlow,
            ),
          ),
        ),
        // Content
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(paddingValue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dark cards with borders and glow shadows
                CustomTodosCard(...),
                SizedBox(height: paddingValue),
                CustomInboxCard(...),
                SizedBox(height: paddingValue),
                // ... more cards
              ],
            ),
          ),
        ),
      ],
    ),
  ),
)
```

### Dashboard with Bottom Navigation
```dart
Scaffold(
  backgroundColor: AppTheme.backgroundColor,
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
  backgroundColor: AppTheme.backgroundColor,  // #141416
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
  floatingActionButton: Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: AppTheme.primaryGradient,
      boxShadow: AppTheme.neonGlow,
    ),
    child: FloatingActionButton(
      onPressed: _handleAdd,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: const Icon(Icons.add, color: Colors.white),
    ),
  ),
)
```

---

## Custom AppBar Pattern

The app uses a custom Row-based AppBar with contained icon buttons:

```dart
Widget _buildAppBar(double padding) {
  return Padding(
    padding: EdgeInsets.all(padding),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.cardBorderColor),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Page Title',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        // Optional: Right side actions
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.cardBorderColor),
          ),
          child: IconButton(
            onPressed: _handleAction,
            icon: Icon(Icons.more_vert, color: AppTheme.textPrimary),
          ),
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
| Back button | Contained in dark surface with border |
| Back icon | `Icons.arrow_back`, `AppTheme.textPrimary` |
| Icon-to-title gap | 12px |
| Title font size | 24px |
| Title font weight | Bold |
| Title color | `AppTheme.textPrimary` (#F2F0ED) |
| Title letter spacing | -0.3 |

---

## Content Area Layout

### Summary Card (Top of Detail Pages)
```dart
Widget _buildSummaryCard(double padding) {
  return Container(
    padding: EdgeInsets.all(padding),
    decoration: AppTheme.cardDecoration(),
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
                    fontWeight: FontWeight.w600,
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
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 12),
      ...items.map((item) => _buildListItem(item, padding)),
    ],
  );
}
```

---

## Bottom Ambient Glow Pattern

Screens that benefit from a warm glow at the bottom (dashboards, hero screens):

```dart
Stack(
  children: [
    // Main content
    SingleChildScrollView(
      child: /* content */,
    ),
    // Bottom ambient glow (non-interactive, behind content)
    Positioned(
      bottom: -100,
      left: 0,
      right: 0,
      height: 300,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.bottomAmbientGlow,
          ),
        ),
      ),
    ),
  ],
)
```

Use `IgnorePointer` to ensure the glow layer doesn't intercept touch events.

---

## FAB Placement and Styling

Standard FAB configuration with gradient and neon glow:

```dart
Scaffold(
  // ...
  floatingActionButton: Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: AppTheme.primaryGradient,
      boxShadow: AppTheme.neonGlow,
    ),
    child: FloatingActionButton(
      onPressed: _handleAdd,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: const Icon(Icons.add, color: Colors.white),
    ),
  ),
)
```

| Property | Value |
|----------|-------|
| Position | Default (bottom right) |
| Background | `AppTheme.primaryGradient` (orange-to-burnt-orange) |
| Shadow | `AppTheme.neonGlow` (orange 30% + burnt orange 15%) |
| Icon | White `Icons.add` |

---

## Empty State Pattern

When a list has no items — tinted circle icon on dark background:

```dart
Widget _buildEmptyState(double padding) {
  return Container(
    padding: EdgeInsets.all(padding * 2),  // Double padding
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryColor.withValues(alpha: 0.10),
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppTheme.textTertiary,
          ),
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

### Transition Duration
- Default: 300ms
- Curve: `Curves.easeInOut`

---

## Background Color Guide

| Screen Type | Background |
|-------------|------------|
| Dashboard | `AppTheme.ambientGradient` (or `backgroundColor`) |
| Detail pages | `AppTheme.backgroundColor` (#141416) |
| Cards | `AppTheme.cardColor` (#26262C) with border + glow |
| Dialogs/Sheets | `AppTheme.surfaceColor` (#1C1C20) |

---

## Screen Checklist

When creating a new screen, ensure:

- [ ] Uses `SafeArea` wrapper
- [ ] Has dark background (`AppTheme.backgroundColor`)
- [ ] Uses custom AppBar pattern with contained icon buttons
- [ ] Uses responsive padding formula
- [ ] Has dark summary card at top with border and glow (if applicable)
- [ ] Uses dark list items with borders and subtle glow shadows
- [ ] Has gradient FAB with neon glow (if add action needed)
- [ ] Has empty state with tinted circle icon
- [ ] Uses `NavigationUtils.navigateWithFade` for navigation
- [ ] Uses light text (`AppTheme.textPrimary`) on dark backgrounds
- [ ] Uses orange (`AppTheme.primaryColor`) for accents and highlights
- [ ] Considers bottom ambient glow for hero/dashboard screens
