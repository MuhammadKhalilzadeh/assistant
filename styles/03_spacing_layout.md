# Spacing & Layout

All spacing tokens are defined in `lib/presentation/constants/app_theme.dart`.

## Spacing Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `spacingXS` | 4px | Tight gaps, icon margins |
| `spacingSM` | 8px | Label gaps, small component spacing |
| `spacingMD` | 16px | Default padding, standard gaps |
| `spacingLG` | 24px | Section spacing, button padding |
| `spacingXL` | 32px | Large section gaps |
| `spacingXXL` | 48px | Page-level major sections |

---

## Responsive Padding Formula

The app uses a responsive padding formula for screen-level padding:

```dart
final screenWidth = MediaQuery.of(context).size.width;
final padding = (screenWidth * 0.04).clamp(16.0, 24.0);
```

This ensures:
- Minimum padding of 16px on small screens
- Maximum padding of 24px on large screens
- Proportional scaling on medium screens

---

## Screen Layout Structure

### Standard Screen Template
```dart
Scaffold(
  body: SafeArea(
    child: Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Column(
        children: [
          // Custom AppBar
          _buildAppBar(padding),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  children: [
                    // Content here
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
)
```

### Home Tab Layout
```dart
SafeArea(
  child: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.backgroundColor,
          AppTheme.surfaceColor,
        ],
      ),
    ),
    child: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(paddingValue),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cards with SizedBox(height: paddingValue) between them
          ],
        ),
      ),
    ),
  ),
)
```

---

## Card Internal Padding

### Standard Cards
Cards use responsive padding matching the screen padding:

```dart
Padding(
  padding: EdgeInsets.all(responsivePadding.clamp(16.0, 24.0)),
  child: /* content */,
)
```

Where `responsivePadding = screenWidth * 0.05`

### Glass Cards (on gradients)
```dart
Container(
  padding: EdgeInsets.all(padding),  // Same as screen padding
  decoration: BoxDecoration(
    color: Colors.white.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
  ),
)
```

---

## List Item Spacing

### Card List (Home Screen)
```dart
Column(
  children: [
    CustomTodosCard(...),
    SizedBox(height: paddingValue),  // Same as screen padding
    CustomInboxCard(...),
    SizedBox(height: paddingValue),
    // ...
  ],
)
```

### Todo/List Items
```dart
Container(
  margin: const EdgeInsets.only(bottom: 12),
  // ...
)
```

### ListTile Content Padding
```dart
ListTile(
  contentPadding: EdgeInsets.symmetric(
    horizontal: padding,
    vertical: 8,
  ),
)
```

---

## Section Spacing

### Section Header to Content
```dart
Column(
  children: [
    Text('All Tasks', style: ...),
    const SizedBox(height: 12),
    // List items
  ],
)
```

### Within Summary Cards
```dart
Column(
  children: [
    // Title and subtitle
    const SizedBox(height: 16),
    // Progress bar
  ],
)
```

---

## Component-Specific Spacing

### Buttons
```dart
padding: const EdgeInsets.symmetric(
  horizontal: AppTheme.spacingLG,  // 24px
  vertical: AppTheme.spacingMD,    // 16px
)
```

### Text Fields
```dart
contentPadding: const EdgeInsets.symmetric(
  horizontal: AppTheme.spacingMD,  // 16px
  vertical: AppTheme.spacingMD,    // 16px
)
```

### Icon + Text in Cards
```dart
Row(
  children: [
    _buildIcon(),
    SizedBox(width: constraints.maxWidth * 0.04),  // ~4% of card width
    Expanded(child: _buildText()),
  ],
)
```

### Text + Label Gap
```dart
Column(
  children: [
    Text('Label'),
    const SizedBox(height: AppTheme.spacingSM),  // 8px
    TextField(),
  ],
)
```

---

## Empty State Layout

```dart
Container(
  padding: EdgeInsets.all(padding * 2),  // Double the normal padding
  child: Column(
    children: [
      Icon(size: 64),
      const SizedBox(height: 16),
      Text('Primary message'),
      const SizedBox(height: 8),
      Text('Secondary message'),
    ],
  ),
)
```

---

## Safe Area Handling

Always wrap full-screen content with SafeArea:
```dart
Scaffold(
  body: SafeArea(
    child: /* content */,
  ),
)
```

For gradient backgrounds that should extend behind status bar:
```dart
Scaffold(
  body: SafeArea(
    child: Container(
      decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
      child: /* content */,
    ),
  ),
)
```

---

## Do's and Don'ts

### DO
```dart
// Use theme spacing tokens
SizedBox(height: AppTheme.spacingMD)

// Use responsive padding
final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

// Use consistent card gaps
SizedBox(height: paddingValue)

// Wrap with SafeArea
SafeArea(child: content)
```

### DON'T
```dart
// Don't use arbitrary values
SizedBox(height: 15) // BAD

// Don't use fixed padding on full screens
Padding(padding: EdgeInsets.all(20)) // BAD - not responsive

// Don't skip SafeArea
Scaffold(body: content) // BAD - might overlap status bar
```

---

## Responsive Sizing Formulas

| Element | Formula | Min | Max |
|---------|---------|-----|-----|
| Screen padding | `screenWidth * 0.04` | 16px | 24px |
| Card padding | `screenWidth * 0.05` | 16px | 24px |
| Icon size (large) | `maxWidth * 0.1` | 28px | 40px |
| Icon size (small) | `maxWidth * 0.08` | 20px | 32px |
| Button size | `maxWidth * 0.12` | 40px | 56px |
| Icon inside button | `maxWidth * 0.06` | 20px | 28px |
| Icon container radius | `iconSize * 0.25` | 8px | 12px |
| Gap between elements | `maxWidth * 0.04` | - | - |
| Vertical text spacing | `maxWidth * 0.015` | 4px | 8px |
