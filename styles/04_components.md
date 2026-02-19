# Component Styling — Nexus Dark

This document covers the styling rules for all reusable components in the app.

## Buttons

### CustomButton
Location: `lib/presentation/widgets/buttons/custom_button.dart`

#### Primary Style (Gradient)
```dart
CustomButton(
  text: 'Get Started',
  useGradient: true,
  onPressed: () {},
)
```
- Background: `AppTheme.primaryGradient` (blue-to-violet)
- Text: `AppTheme.textOnPrimary` (white)
- Border radius: `AppTheme.borderRadiusMedium` (12px)
- Shadow: `AppTheme.glowShadow` (blue glow)
- Padding: 24px horizontal, 16px vertical
- Font: 16px, weight 600, 0.5 letter spacing

#### Default Style (Solid Blue)
```dart
CustomButton(
  text: 'Sign In',
  onPressed: () {},
)
```
- Background: `AppTheme.primaryColor` (#5B8DEF)
- Text: `AppTheme.textOnPrimary` (white)
- Shadow: Primary color at 0.3 alpha, 8px blur

#### Secondary Style (Outline)
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
    border: Border.all(color: AppTheme.primaryColor, width: 1.5),
  ),
  child: Text('Cancel', style: TextStyle(color: AppTheme.primaryColor)),
)
```

#### Ghost Style (Text Only)
```dart
TextButton(
  onPressed: () {},
  child: Text('Skip', style: TextStyle(color: AppTheme.textSecondary)),
)
```

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
- Scale: 1.0 -> 0.95
- Curve: `Curves.easeInOut`

---

## Text Fields

### CustomTextField
Location: `lib/presentation/widgets/textfields/custom_text_field.dart`

Designed for use on dark backgrounds with clean styling.

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
| Background | `AppTheme.surfaceColor` (#111827) |
| Border (default) | `AppTheme.cardBorderColor` (#243044), 1px |
| Border (focused) | `AppTheme.activeBorderColor` (#5B8DEF), 1.5px |
| Border radius | `AppTheme.borderRadiusMedium` (12px) |
| Text color | `AppTheme.textPrimary` (#F1F5F9) |
| Hint color | `AppTheme.textTertiary` (#4B5563) |
| Label color | `AppTheme.textSecondary` (#94A3B8) |
| Icon color | `AppTheme.textSecondary` |
| Content padding | 16px horizontal & vertical |
| Font size | 16px |

#### Focus Animation
- Duration: 300ms
- Focus shadow: Blue glow (`primaryColor` at 0.15 alpha, 8px blur)

---

## Cards

### Dark Elevated Cards
15 card variants located in `lib/presentation/widgets/cards/`

#### Common Properties
| Property | Value |
|----------|-------|
| Border radius | 16px (`borderRadiusCard`) |
| Background | Dark navy (`AppTheme.cardColor` #1A2332) |
| Border | `AppTheme.cardBorderColor` (#243044), 1px |
| Shadow | `AppTheme.cardShadow` (blue glow + black) |
| Text | Light (`AppTheme.textPrimary` #F1F5F9) |
| Accent | Blue (`AppTheme.primaryColor` #5B8DEF) |

#### Card Structure Template
```dart
Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: enabled ? onTap : null,
    borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
    child: Ink(
      decoration: AppTheme.cardDecoration(),
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
    color: AppTheme.primaryColor.withValues(alpha: 0.15),
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
    color: AppTheme.primaryColor.withValues(alpha: 0.15),
    shape: BoxShape.circle,
  ),
  child: Icon(Icons.add, color: AppTheme.primaryColor, size: iconSize),
)
```

### Badge/Chip Style
Tinted background with colored text (not solid color blocks):
```dart
Container(
  padding: EdgeInsets.symmetric(
    horizontal: horizontalPadding,  // 10-16px
    vertical: verticalPadding,      // 6-10px
  ),
  decoration: BoxDecoration(
    color: AppTheme.primaryColor.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'H:28 L:18',
    style: TextStyle(
      color: AppTheme.primaryColor,
      fontSize: badgeFontSize,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

---

## Summary Cards (inside detail pages)

Dark elevated card for displaying aggregated information:

```dart
Container(
  padding: EdgeInsets.all(padding),
  decoration: AppTheme.cardDecoration(),
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
    color: AppTheme.cardColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppTheme.cardBorderColor, width: 1),
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

Custom circular checkbox on dark backgrounds:

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
    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
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
    color: AppTheme.primaryColor.withValues(alpha: 0.15),
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

Flat top edge with border line on dark background:

```dart
Container(
  decoration: BoxDecoration(
    color: AppTheme.surfaceColor,
    border: Border(
      top: BorderSide(color: AppTheme.dividerColor, width: 1),
    ),
  ),
)
```

| Property | Value |
|----------|-------|
| Background | `AppTheme.surfaceColor` (#111827) |
| Top border | `AppTheme.dividerColor` (#1E293B), 1px |
| Selected color | `AppTheme.primaryColor` (#5B8DEF) |
| Unselected color | `AppTheme.textSecondary` (#94A3B8) |
| Selected label | 12px, weight 600 |
| Unselected label | 12px, weight 400 |
| Elevation | 0 |
| Corner radius | None (flat top edge) |
| Selected indicator | Blue pill background |

---

## FAB (Floating Action Button)

Gradient background with neon glow:
```dart
Container(
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: AppTheme.primaryGradient,
    boxShadow: AppTheme.neonGlow,
  ),
  child: FloatingActionButton(
    onPressed: onPressed,
    backgroundColor: Colors.transparent,
    elevation: 0,
    child: const Icon(Icons.add, color: Colors.white),
  ),
)
```

| Property | Value |
|----------|-------|
| Background | `AppTheme.primaryGradient` (blue-to-violet) |
| Shadow | `AppTheme.neonGlow` (blue 40% + violet 20%) |
| Icon color | White |
| Default icon | `Icons.add` |

---

## Dialogs

Standard AlertDialog with dark surface:
```dart
AlertDialog(
  backgroundColor: AppTheme.surfaceColor,
  title: Text('Add Task', style: TextStyle(color: AppTheme.textPrimary)),
  content: /* form fields */,
  actions: [
    TextButton(child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
    FilledButton(child: Text('Add')),
  ],
)
```
