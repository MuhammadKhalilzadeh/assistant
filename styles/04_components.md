# Component Styling

This document covers the styling rules for all reusable components in the app.

## Buttons

### CustomButton
Location: `lib/presentation/widgets/buttons/custom_button.dart`

#### Default Style (White Background)
```dart
CustomButton(
  text: 'Sign In',
  onPressed: () {},
)
```
- Background: `AppTheme.surfaceColor` (white)
- Text: `AppTheme.primaryColor` (indigo)
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
- Background: `AppTheme.primaryGradient`
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

Designed for use on gradient backgrounds with glassmorphism effect.

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
| Background | `Colors.white.withValues(alpha: 0.15)` |
| Border (default) | `Colors.white.withValues(alpha: 0.2)`, 1px |
| Border (focused) | `Colors.white.withValues(alpha: 0.5)`, 2px |
| Border radius | `AppTheme.borderRadiusMedium` (12px) |
| Text color | `Colors.white` |
| Hint color | `Colors.white.withValues(alpha: 0.7)` |
| Label color | `Colors.white` |
| Icon color | `Colors.white.withValues(alpha: 0.9)` |
| Content padding | 16px horizontal & vertical |
| Font size | 16px |

#### Focus Animation
- Duration: 300ms
- Focus shadow: White at 0.2 alpha, 8px blur, 2px Y offset

---

## Cards

### Glass Effect Cards (on gradients)
15 card variants located in `lib/presentation/widgets/cards/`

#### Common Properties
| Property | Value |
|----------|-------|
| Border radius | 20px (default) |
| Background | Gradient (primary or secondary) |
| Shadow | `AppTheme.cardShadow` |
| Foreground | White text and icons |

#### Card Structure Template
```dart
Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: enabled ? onTap : null,
    borderRadius: BorderRadius.circular(borderRadius),
    child: Ink(
      decoration: BoxDecoration(
        gradient: backgroundColor == null
            ? AppTheme.primaryGradient  // or secondaryGradient
            : null,
        color: backgroundColor,
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
    border: Border.all(color: fgColor, width: borderWidth),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Icon(icon, color: fgColor, size: iconSize),
)
```

#### Filled Icon Container (Weather)
```dart
Container(
  padding: EdgeInsets.all(padding),
  decoration: BoxDecoration(
    color: fgColor,  // White
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
    color: fgColor.withValues(alpha: 0.2),  // White 20%
    shape: BoxShape.circle,
  ),
  child: Icon(Icons.add, color: fgColor, size: iconSize),
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
    color: fgColor,  // White
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'H:28° L:18°',
    style: TextStyle(
      color: bgColor,  // Gradient color
      fontSize: badgeFontSize,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

---

## Summary Cards (inside detail pages)

Glass-effect card for displaying aggregated information:

```dart
Container(
  padding: EdgeInsets.all(padding),
  decoration: BoxDecoration(
    color: Colors.white.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
    color: Colors.white.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
  ),
  child: ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
    // ...
  ),
)
```

---

## Checkbox Style

Custom circular checkbox on gradient backgrounds:

```dart
Container(
  width: 28,
  height: 28,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: isCompleted
        ? Colors.white
        : Colors.white.withValues(alpha: 0.2),
    border: Border.all(
      color: Colors.white,
      width: 2,
    ),
  ),
  child: isCompleted
      ? Icon(Icons.check, color: AppTheme.primaryColor, size: 18)
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
    backgroundColor: Colors.white.withValues(alpha: 0.2),
    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
    valueColor: AlwaysStoppedAnimation<Color>(buttonTextColor),
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
    color: Colors.white.withValues(alpha: 0.2),
  ),
  child: Center(
    child: Text(
      '75%',
      style: TextStyle(
        color: Colors.white,
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
| Selected color | `AppTheme.primaryColor` |
| Unselected color | `AppTheme.textSecondary` |
| Selected label | 12px, weight 600 |
| Unselected label | 12px, weight 400 |
| Elevation | 0 (uses boxShadow instead) |
| Corner radius | 16px top corners only |

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
