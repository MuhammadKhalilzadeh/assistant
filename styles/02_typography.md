# Typography

All typography is defined in the `textTheme` within `lib/presentation/constants/app_theme.dart`. The app uses Material 3 typography scale with custom adjustments.

## Font Size Scale

| Style Name | Size | Weight | Letter Spacing | Default Color |
|------------|------|--------|----------------|---------------|
| `displayLarge` | 57px | 400 | -0.25 | textPrimary |
| `displayMedium` | 45px | 400 | 0 | textPrimary |
| `displaySmall` | 36px | 400 | 0 | textPrimary |
| `headlineLarge` | 32px | 600 | 0 | textPrimary |
| `headlineMedium` | 28px | 600 | 0 | textPrimary |
| `headlineSmall` | 24px | 600 | 0 | textPrimary |
| `titleLarge` | 22px | 600 | 0 | textPrimary |
| `titleMedium` | 16px | 500 | 0.15 | textPrimary |
| `titleSmall` | 14px | 500 | 0.1 | textPrimary |
| `bodyLarge` | 16px | 400 | 0.5 | textPrimary |
| `bodyMedium` | 14px | 400 | 0.25 | textPrimary |
| `bodySmall` | 12px | 400 | 0.4 | textSecondary |
| `labelLarge` | 14px | 500 | 0.1 | textPrimary |
| `labelMedium` | 12px | 500 | 0.5 | textPrimary |
| `labelSmall` | 11px | 500 | 0.5 | textSecondary |

---

## Font Weight Usage

| Weight | Value | Usage |
|--------|-------|-------|
| Regular | `FontWeight.w400` | Body text, descriptions |
| Medium | `FontWeight.w500` | Labels, titles, emphasized body |
| SemiBold | `FontWeight.w600` | Headings, important titles |
| Bold | `FontWeight.w700` | Hero text, extra emphasis |

---

## Typography Hierarchy

### Page Titles (Custom AppBar)
```dart
Text(
  'Tasks',
  style: TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
)
```

### Section Headers
```dart
Text(
  'Today\'s Progress',
  style: TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
)
```

### Card Titles
```dart
// On gradient backgrounds - responsive
final titleFontSize = (maxWidth * 0.055).clamp(16.0, 22.0);

Text(
  'Todos',
  style: TextStyle(
    color: Colors.white,
    fontSize: titleFontSize,
    fontWeight: FontWeight.bold,
  ),
)
```

### Card Subtitles
```dart
// On gradient backgrounds - responsive
final subtitleFontSize = (maxWidth * 0.038).clamp(12.0, 16.0);

Text(
  '3 tasks remaining',
  style: TextStyle(
    color: Colors.white,
    fontSize: subtitleFontSize,
    fontWeight: FontWeight.w400,
  ),
)
```

### Body Text
```dart
// Using theme
Text(
  'Description here',
  style: Theme.of(context).textTheme.bodyMedium,
)
```

### Labels
```dart
// Text field labels on gradient
Text(
  'Email',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    fontWeight: FontWeight.w500,
    color: Colors.white,
    fontSize: 16,
  ),
)
```

---

## Responsive Font Sizing

Cards use responsive font sizing based on container width:

```dart
// Title - scales from 16 to 22px
final titleFontSize = (maxWidth * 0.055).clamp(16.0, 22.0);

// Subtitle - scales from 12 to 16px
final subtitleFontSize = (maxWidth * 0.038).clamp(12.0, 16.0);

// Badge text - scales from 12 to 16px
final badgeFontSize = (maxWidth * 0.035).clamp(12.0, 16.0);
```

---

## Color Pairing Rules

### On Light Backgrounds
```dart
// Primary text
style: TextStyle(color: AppTheme.textPrimary)

// Secondary text
style: TextStyle(color: AppTheme.textSecondary)

// Disabled/placeholder
style: TextStyle(color: AppTheme.textTertiary)
```

### On Gradient/Dark Backgrounds
```dart
// Primary text
style: TextStyle(color: Colors.white)

// Secondary text
style: TextStyle(color: Colors.white.withValues(alpha: 0.8))

// Muted text
style: TextStyle(color: Colors.white.withValues(alpha: 0.7))

// Placeholder/disabled
style: TextStyle(color: Colors.white.withValues(alpha: 0.5))
```

---

## Do's and Don'ts

### DO
```dart
// Use theme text styles
style: Theme.of(context).textTheme.bodyLarge

// Extend with copyWith for modifications
style: Theme.of(context).textTheme.headlineMedium?.copyWith(
  fontWeight: FontWeight.w700,
)

// Use semantic colors
style: TextStyle(color: AppTheme.textSecondary)

// Use responsive sizing in cards
final fontSize = (maxWidth * 0.055).clamp(16.0, 22.0);
```

### DON'T
```dart
// Don't hardcode font sizes arbitrarily
style: TextStyle(fontSize: 17) // BAD - use scale values

// Don't use Colors.black for text
style: TextStyle(color: Colors.black) // BAD - use textPrimary

// Don't mix styling approaches
style: TextStyle(
  fontSize: 16,
  color: Colors.grey, // BAD - use textSecondary
)
```

---

## Special Cases

### Strikethrough (Completed Items)
```dart
Text(
  todo.title,
  style: TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
  ),
)
```

### Letter Spacing for Buttons
```dart
Text(
  'Sign In',
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  ),
)
```

### Title with Negative Spacing
```dart
// AppBar title uses negative letter spacing
titleTextStyle: TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: textPrimary,
  letterSpacing: -0.5,
)
```
