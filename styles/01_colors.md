# Color System

All colors are defined in `lib/presentation/constants/app_theme.dart`.

## Primary Palette

### Brand Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `primaryColor` | `#6366F1` | 99, 102, 241 | Primary actions, links, focus states |
| `primaryDark` | `#4F46E5` | 79, 70, 229 | Hover states, pressed states |
| `primaryLight` | `#818CF8` | 129, 140, 248 | Backgrounds, disabled states |

### Secondary Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `secondaryColor` | `#EC4899` | 236, 72, 153 | Highlights, badges, accent elements |
| `accentColor` | `#10B981` | 16, 185, 129 | Success, positive actions, health metrics |

## Status Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `successColor` | `#10B981` | Success messages, completed states |
| `warningColor` | `#F59E0B` | Warning messages, caution states |
| `errorColor` | `#EF4444` | Error messages, destructive actions |
| `infoColor` | `#3B82F6` | Informational messages, tips |

## Text Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `textPrimary` | `#1E293B` | Primary text on light backgrounds |
| `textSecondary` | `#64748B` | Secondary text, subtitles, captions |
| `textTertiary` | `#94A3B8` | Disabled text, placeholders |
| `textOnPrimary` | `#FFFFFF` | Text on colored/gradient backgrounds |

## Background Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `backgroundColor` | `#F8FAFC` | Main app background |
| `surfaceColor` | `#FFFFFF` | Cards, dialogs, elevated surfaces |
| `cardColor` | `#FFFFFF` | Card backgrounds |

---

## Gradients

### Primary Gradient
Used for: Feature cards on home, detail page backgrounds, primary action buttons.

```dart
static const LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
  ],
);
```

**When to use:**
- Productivity-related screens (Todos, Calendar, Focus Timer, Habits)
- Primary feature cards
- Main action buttons with gradient option

### Secondary Gradient
Used for: Health and wellness cards, positive metrics.

```dart
static const LinearGradient secondaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF10B981), // Emerald
    Color(0xFF06B6D4), // Cyan
  ],
);
```

**When to use:**
- Weather card
- Health metrics (Water, Steps, Heart Rate)
- Success/completion states

### Dashboard Background Gradient
Used only on home tab for subtle depth:

```dart
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    AppTheme.backgroundColor, // #F8FAFC
    AppTheme.surfaceColor,    // #FFFFFF
  ],
)
```

---

## Opacity Conventions

### Glass Effect (Glassmorphism)
Used on gradient backgrounds for content containers:

| Property | Alpha Value | Usage |
|----------|-------------|-------|
| Background | `0.15` | Card/container backgrounds |
| Border | `0.2` | Subtle borders |
| Border (focused) | `0.5` | Active/focused state borders |
| Text (muted) | `0.7` | Secondary text on dark |
| Text (dimmed) | `0.5` | Placeholder/disabled text |
| Overlay | `0.2` | Button hover states on cards |

### Code Example - Glass Card
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.2),
    ),
  ),
  child: /* content */,
)
```

### Shadow Opacities
| Shadow Type | Primary Alpha | Secondary Alpha |
|-------------|---------------|-----------------|
| Card shadow | `0.05` | `0.02` |
| Elevated shadow | `0.1` | `0.05` |
| Primary glow | `0.3` | - |
| Focus glow | `0.2` | - |

---

## Do's and Don'ts

### DO
```dart
// Use theme tokens
color: AppTheme.primaryColor

// Use semantic colors
color: AppTheme.errorColor // for errors
color: AppTheme.successColor // for success

// Use gradients from theme
gradient: AppTheme.primaryGradient
```

### DON'T
```dart
// Don't hardcode colors
color: Color(0xFF6366F1) // BAD

// Don't use arbitrary colors
color: Colors.red // BAD - use errorColor

// Don't create new gradients
gradient: LinearGradient(colors: [...]) // BAD - use theme gradients
```

---

## Color Pairing Rules

| Background | Text Color | Border Color |
|------------|------------|--------------|
| Light (`backgroundColor`) | `textPrimary` | `grey.shade200` |
| White (`surfaceColor`) | `textPrimary` | `grey.shade200` |
| Primary gradient | `textOnPrimary` (white) | `white.withValues(alpha: 0.2)` |
| Secondary gradient | `textOnPrimary` (white) | `white.withValues(alpha: 0.2)` |
| Glass effect | `textOnPrimary` (white) | `white.withValues(alpha: 0.2)` |
