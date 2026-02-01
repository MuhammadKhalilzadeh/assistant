# Component Styling

This document covers the styling rules for all reusable components in the app.

## Buttons

### CustomButton
Location: `lib/presentation/widgets/buttons/custom_button.dart`

#### Default Style (Red Background)
```dart
CustomButton(
  text: 'Sign In',
  onPressed: () {},
)
```
- Background: `AppTheme.primaryColor` (Red #D32F2F)
- Text: `AppTheme.textOnPrimary` (white)
- Border radius: `AppTheme.borderRadiusMedium` (12px)
- Padding: 24px horizontal, 16px vertical
- Font: 16px, weight 600, 0.5 letter spacing
- Shadow: Primary color at 0.3 alpha, 8px blur

#### Gradient Style
```dart
CustomButton(
  text: 'Get Started',
  useGradient: true,
  onPressed: () {},
)
```
- Background: `AppTheme.primaryGradient` (Red gradient)
- Text: `AppTheme.textOnPrimary` (white)

#### With Icon
```dart
CustomButton(
  text: 'Add Task',
  icon: Icons.add,
  onPressed: () {},
)
```
- Icon size: 20px
- Gap between icon and text: `AppTheme.spacingSM` (8px)

#### Loading State
```dart
CustomButton(
  text: 'Saving',
  isLoading: true,
)
```
- Shows 20x20 CircularProgressIndicator
- Stroke width: 2px

#### Press Animation
- Duration: 150ms
- Scale: 1.0 → 0.95
- Curve: `Curves.easeInOut`

---

## Text Fields

### CustomTextField
Location: `lib/presentation/widgets/textfields/custom_text_field.dart`

Designed for use on light backgrounds with clean styling.

#### Default Style
```dart
CustomTextField(
  label: 'Email',
  hint: 'Enter your email',
  prefixIcon: Icons.email,
)
```

#### Styling Details
| Property | Value |
|----------|-------|
| Background | `AppTheme.surfaceColor` (white) |
| Border (default) | `Colors.grey.shade200`, 1px |
| Border (focused) | `AppTheme.primaryColor` (red), 2px |
| Border radius | `AppTheme.borderRadiusMedium` (12px) |
| Text color | `AppTheme.textPrimary` |
| Hint color | `AppTheme.textTertiary` |
| Label color | `AppTheme.textPrimary` |
| Icon color | `AppTheme.textSecondary` |
| Content padding | 16px horizontal & vertical |
| Font size | 16px |

#### Focus Animation
- Duration: 300ms
- Focus shadow: Primary color at 0.1 alpha, 8px blur, 2px Y offset

---

## Cards

### White Elevated Cards
15 card variants located in `lib/presentation/widgets/cards/`

#### Common Properties
| Property | Value |
|----------|-------|
| Border radius | 20px (default) |
| Background | White (`AppTheme.cardColor`) |
| Shadow | `AppTheme.cardShadow` |
| Text | Dark (`AppTheme.textPrimary`) |
| Accent | Red (`AppTheme.primaryColor`) |

#### Card Structure Template
```dart
Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: enabled ? onTap : null,
    borderRadius: BorderRadius.circular(borderRadius),
    child: Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(responsivePadding.clamp(16.0, 24.0)),
        child: /* content */,
      ),
    ),
  ),
)
```

#### Card Layout Pattern
```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    // Left: Icon with container
    _buildIcon(),
    SizedBox(width: constraints.maxWidth * 0.04),
    // Center: Title + Subtitle
    Expanded(child: _buildTextSection()),
    SizedBox(width: constraints.maxWidth * 0.04),
    // Right: Action button or badge
    _buildAction(),
  ],
)
```

### Icon Container Styles

#### Bordered Icon (Todos, Calendar, etc.)
```dart
Container(
  padding: EdgeInsets.all(iconSize * 0.3),
  decoration: BoxDecoration(
    border: Border.all(color: AppTheme.primaryColor, width: borderWidth),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Icon(icon, color: AppTheme.primaryColor, size: iconSize),
)
```

#### Filled Icon Container
```dart
Container(
  padding: EdgeInsets.all(padding),
  decoration: BoxDecoration(
    color: AppTheme.primaryColor.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(containerRadius),
  ),
  child: Icon(icon, color: AppTheme.primaryColor, size: iconSize),
)
```

### Add Button Style (on cards)
```dart
Container(
  width: buttonSize,
  height: buttonSize,
  decoration: BoxDecoration(
    color: AppTheme.primaryColor.withValues(alpha: 0.1),
    shape: BoxShape.circle,
  ),
  child: Icon(Icons.add, color: AppTheme.primaryColor, size: iconSize),
)
```

### Badge/Pill Style
```dart
Container(
  padding: EdgeInsets.symmetric(
    horizontal: horizontalPadding,  // 10-16px
    vertical: verticalPadding,      // 6-10px
  ),
  decoration: BoxDecoration(
    color: AppTheme.primaryColor,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'H:28° L:18°',
    style: TextStyle(
      color: Colors.white,
      fontSize: badgeFontSize,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

---

## Summary Cards (inside detail pages)

White elevated card for displaying aggregated information:

```dart
Container(
  padding: EdgeInsets.all(padding),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: AppTheme.cardShadow,
  ),
  child: /* content */,
)
```

---

## List Item Cards

For todo items, message items, etc.:

```dart
Container(
  margin: const EdgeInsets.only(bottom: 12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: AppTheme.cardShadow,
  ),
  child: ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
    // ...
  ),
)
```

---

## Checkbox Style

Custom circular checkbox on light backgrounds:

```dart
Container(
  width: 28,
  height: 28,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: isCompleted
        ? AppTheme.successColor  // Green for completed
        : Colors.transparent,
    border: Border.all(
      color: isCompleted ? AppTheme.successColor : AppTheme.textTertiary,
      width: 2,
    ),
  ),
  child: isCompleted
      ? Icon(Icons.check, color: Colors.white, size: 18)
      : null,
)
```

---

## Progress Indicators

### Linear Progress
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: LinearProgressIndicator(
    value: progress,
    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
    minHeight: 8,
  ),
)
```

### Circular Progress (Loading)
```dart
SizedBox(
  height: 20,
  width: 20,
  child: CircularProgressIndicator(
    strokeWidth: 2,
    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
  ),
)
```

### Percentage Circle
```dart
Container(
  width: 60,
  height: 60,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: AppTheme.primaryColor.withValues(alpha: 0.1),
  ),
  child: Center(
    child: Text(
      '75%',
      style: TextStyle(
        color: AppTheme.primaryColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
)
```

---

## Bottom Navigation Bar

Location: `lib/presentation/widgets/bottom_navigation_bar/custom_bottom_navigation_bar.dart`

```dart
Container(
  decoration: BoxDecoration(
    color: AppTheme.surfaceColor,
    boxShadow: AppTheme.cardShadow,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(AppTheme.borderRadiusLarge),  // 16px
      topRight: Radius.circular(AppTheme.borderRadiusLarge),
    ),
  ),
)
```

| Property | Value |
|----------|-------|
| Background | `AppTheme.surfaceColor` (white) |
| Selected color | `AppTheme.primaryColor` (red) |
| Unselected color | `AppTheme.textSecondary` |
| Selected label | 12px, weight 600 |
| Unselected label | 12px, weight 400 |
| Elevation | 0 (uses boxShadow instead) |
| Corner radius | 16px top corners only |
| Selected indicator | Red pill background |

---

## FAB (Floating Action Button)

Standard FAB styling:
```dart
FloatingActionButton(
  onPressed: onPressed,
  backgroundColor: Colors.white,
  foregroundColor: AppTheme.primaryColor,
  child: const Icon(Icons.add),
)
```

| Property | Value |
|----------|-------|
| Background | White |
| Icon color | `AppTheme.primaryColor` |
| Default icon | `Icons.add` |

---

## Dialogs

Standard AlertDialog:
```dart
AlertDialog(
  title: const Text('Add Task'),
  content: /* form fields */,
  actions: [
    TextButton(child: Text('Cancel')),
    FilledButton(child: Text('Add')),
  ],
)
```
