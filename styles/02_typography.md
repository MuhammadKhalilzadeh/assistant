# Typography — Nexus Dark

All typography is defined in the `textTheme` within `lib/presentation/constants/app_theme.dart`. The app uses Material 3 typography scale with custom adjustments for the dark theme.

## Font Size Scale

| Style Name | Size | Weight | Letter Spacing | Default Color |
|------------|------|--------|----------------|---------------|
| `displayLarge` | 57px | 400 | -0.3 | textPrimary |
| `displayMedium` | 45px | 400 | -0.3 | textPrimary |
| `displaySmall` | 36px | 400 | -0.3 | textPrimary |
| `headlineLarge` | 32px | 600 | -0.3 | textPrimary |
| `headlineMedium` | 28px | 600 | -0.3 | textPrimary |
| `headlineSmall` | 24px | 600 | -0.3 | textPrimary |
| `titleLarge` | 22px | 600 | -0.3 | textPrimary |
| `titleMedium` | 16px | 500 | 0.15 | textPrimary |
| `titleSmall` | 14px | 500 | 0.1 | textPrimary |
| `bodyLarge` | 16px | 400 | 0.5 | textPrimary |
| `bodyMedium` | 14px | 400 | 0.25 | textPrimary |
| `bodySmall` | 12px | 400 | 0.4 | textSecondary |
| `labelLarge` | 14px | 500 | 0.1 | textPrimary |
| `labelMedium` | 12px | 500 | 0.5 | textPrimary |
| `labelSmall` | 11px | 500 | 0.5 | textSecondary |

**Note:** All headline and display styles use `-0.3` letter spacing for a modern, tight feel on dark backgrounds.

---

## Font Weight Usage

| Weight | Value | Usage |
|--------|-------|-------|
| Regular | `FontWeight.w400` | Body text, descriptions |
| Medium | `FontWeight.w500` | Labels, titles, emphasized body |
| SemiBold | `FontWeight.w600` | Headings, card titles, important titles |
| Bold | `FontWeight.w700` | Hero text, extra emphasis (use sparingly) |

**Note:** Card titles use `w600` (semibold) instead of `w700` (bold) for a cleaner look on dark backgrounds.

---

## Typography Hierarchy

### Page Titles (Custom AppBar)
```dart
Text(
  'Tasks',
  style: TextStyle(
    color: AppTheme.textPrimary,  // #F1F5F9 light text
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
  ),
)
```

### Section Headers
```dart
Text(
  'Today\'s Progress',
  style: TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  ),
)
```

### Card Titles
```dart
// On dark cards - responsive
final titleFontSize = (maxWidth * 0.055).clamp(16.0, 22.0);

Text(
  'Todos',
  style: TextStyle(
    color: AppTheme.textPrimary,
    fontSize: titleFontSize,
    fontWeight: FontWeight.w600,  // SemiBold, not bold
  ),
)
```

### Card Subtitles
```dart
// On dark cards - responsive
final subtitleFontSize = (maxWidth * 0.038).clamp(12.0, 16.0);

Text(
  '3 tasks remaining',
  style: TextStyle(
    color: AppTheme.textSecondary,
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
// Text field labels on dark background
Text(
  'Email',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    fontWeight: FontWeight.w500,
    color: AppTheme.textPrimary,
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

### On Dark Backgrounds (Standard)
```dart
// Primary text
style: TextStyle(color: AppTheme.textPrimary) // #F1F5F9

// Secondary text
style: TextStyle(color: AppTheme.textSecondary) // #94A3B8

// Disabled/placeholder
style: TextStyle(color: AppTheme.textTertiary) // #4B5563
```

### On Gradient Backgrounds (Blue/Violet)
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

## Gradient Text Effect

For hero numbers, important values, or decorative headings:

```dart
AppTheme.gradientText(
  child: Text(
    '2,450',
    style: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
    ),
  ),
)
```

This applies the primary gradient (blue-to-violet) as a text color via ShaderMask.

---

## Glow Text Effect

For glowing numbers/values that signal active or live data:

```dart
Text(
  '25:00',
  style: TextStyle(
    color: AppTheme.primaryColor,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    shadows: AppTheme.textGlow,  // Blue glow at 60% opacity, 12px blur
  ),
)
```

---

## Do's and Don'ts

### DO
```dart
// Use theme text styles
style: Theme.of(context).textTheme.bodyLarge

// Extend with copyWith for modifications
style: Theme.of(context).textTheme.headlineMedium?.copyWith(
  fontWeight: FontWeight.w600,
)

// Use semantic colors
style: TextStyle(color: AppTheme.textSecondary)

// Use responsive sizing in cards
final fontSize = (maxWidth * 0.055).clamp(16.0, 22.0);

// Use -0.3 letter spacing for headlines
letterSpacing: -0.3
```

### DON'T
```dart
// Don't hardcode font sizes arbitrarily
style: TextStyle(fontSize: 17) // BAD - use scale values

// Don't use dark text colors (old theme)
style: TextStyle(color: Color(0xFF1E293B)) // BAD - invisible on dark bg

// Don't use Colors.black for text
style: TextStyle(color: Colors.black) // BAD - use textPrimary

// Don't use w700 for card titles
fontWeight: FontWeight.w700 // BAD for cards - use w600
```

---

## Special Cases

### Strikethrough (Completed Items)
```dart
Text(
  todo.title,
  style: TextStyle(
    color: AppTheme.textSecondary,  // Muted for completed
    fontSize: 16,
    fontWeight: FontWeight.w500,
    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
    decorationColor: AppTheme.textTertiary,
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

### Title with Tight Spacing
```dart
// AppBar title uses tight letter spacing
titleTextStyle: TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: textPrimary,
  letterSpacing: -0.3,
)
```
