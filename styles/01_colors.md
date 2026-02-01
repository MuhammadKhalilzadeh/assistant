# Color System

All colors are defined in `lib/presentation/constants/app_theme.dart`.

## Primary Palette

### Brand Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `primaryColor` | `#D32F2F` | 211, 47, 47 | Primary actions, links, focus states, buttons |
| `primaryDark` | `#B71C1C` | 183, 28, 28 | Hover states, pressed states |
| `primaryLight` | `#EF5350` | 239, 83, 80 | Backgrounds, disabled states |

### Secondary Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `secondaryColor` | `#FF8A80` | 255, 138, 128 | Highlights, badges, accent elements |
| `accentColor` | `#FF5252` | 255, 82, 82 | Secondary actions, accent highlights |

## Status Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `successColor` | `#10B981` | Success messages, completed states, checkmarks |
| `warningColor` | `#F59E0B` | Warning messages, caution states |
| `errorColor` | `#EF4444` | Error messages, destructive actions |
| `infoColor` | `#3B82F6` | Informational messages, tips |

**Note:** Status colors are kept as universal UX colors for clarity.

## Text Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `textPrimary` | `#1E293B` | Primary text on light backgrounds |
| `textSecondary` | `#64748B` | Secondary text, subtitles, captions |
| `textTertiary` | `#94A3B8` | Disabled text, placeholders |
| `textOnPrimary` | `#FFFFFF` | Text on colored/red backgrounds |

## Background Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `backgroundColor` | `#FFF5F5` | Main app background (light pink tint) |
| `surfaceColor` | `#FFFFFF` | Cards, dialogs, elevated surfaces |
| `cardColor` | `#FFFFFF` | Card backgrounds |

---

## Gradients

### Primary Gradient
Used for: Headers, accent sections, primary action buttons.

```dart
static const LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFD32F2F), // Red 700
    Color(0xFFE53935), // Red 600
  ],
);
```

**When to use:**
- Header backgrounds (sparingly)
- Primary action buttons with gradient option
- Accent highlights

### Secondary Gradient
Used for: Subtle background tints, light accent areas.

```dart
static const LinearGradient secondaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFFFEBEE), // Red 50
    Color(0xFFFFCDD2), // Red 100
  ],
);
```

**When to use:**
- Subtle background variations
- Light accent sections
- Background gradients for cards (optional)

### Dashboard Background
Used only on home tab for subtle depth:

```dart
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    AppTheme.backgroundColor, // #FFF5F5
    AppTheme.surfaceColor,    // #FFFFFF
  ],
)
```

---

## Card Styling (New Pattern)

### White Elevated Card
The primary card pattern - white background with subtle shadow:

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: AppTheme.cardShadow,
  ),
  child: /* content */,
)

// Or use helper
AppTheme.elevatedCard(child: /* content */)
```

### Card Decoration Helper
```dart
decoration: AppTheme.cardDecoration()
// or
decoration: AppTheme.elevatedCardDecoration
```

---

## Shadow Conventions

### Card Shadow (Standard)
| Property | Value |
|----------|-------|
| Primary shadow | `0.05` alpha, 10px blur, 4px Y offset |
| Secondary shadow | `0.02` alpha, 4px blur, 2px Y offset |

### Elevated Shadow (Prominent)
| Property | Value |
|----------|-------|
| Primary shadow | `0.1` alpha, 20px blur, 8px Y offset |
| Secondary shadow | `0.05` alpha, 8px blur, 4px Y offset |

---

## Do's and Don'ts

### DO
```dart
// Use theme tokens
color: AppTheme.primaryColor

// Use semantic colors
color: AppTheme.errorColor // for errors
color: AppTheme.successColor // for success (keep green)

// Use white cards with shadow
decoration: AppTheme.cardDecoration()

// Use dark text on light backgrounds
color: AppTheme.textPrimary
```

### DON'T
```dart
// Don't hardcode colors
color: Color(0xFFD32F2F) // BAD - use AppTheme.primaryColor

// Don't use purple/indigo (old theme)
color: Color(0xFF6366F1) // BAD - old theme color

// Don't use glass effect on light backgrounds
color: Colors.white.withValues(alpha: 0.15) // BAD - use solid white

// Don't use white text on light backgrounds
color: Colors.white // BAD on light background - use textPrimary
```

---

## Color Pairing Rules

| Background | Text Color | Border/Accent Color |
|------------|------------|---------------------|
| Light (`backgroundColor`) | `textPrimary` | `grey.shade200` or `primaryColor` |
| White (`surfaceColor`) | `textPrimary` | `grey.shade200` or `primaryColor` |
| Red gradient | `textOnPrimary` (white) | `white.withValues(alpha: 0.3)` |
| Card (white) | `textPrimary` | `grey.shade200` |

---

## Feature-Specific Color Decisions

| Feature | Color | Rationale |
|---------|-------|-----------|
| Success/Complete | Green `#10B981` | Universal UX - green = success |
| Progress indicators | Red `primaryColor` | Brand consistency |
| Selected states | Red `primaryColor` | Brand consistency |
| Warnings | Amber `#F59E0B` | Universal warning color |
| Errors | Red `#EF4444` | Universal error color |
| Info | Blue `#3B82F6` | Maintains visual hierarchy |
