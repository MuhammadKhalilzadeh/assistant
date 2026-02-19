# Color System — Nexus Dark v2

All colors are defined in `lib/presentation/constants/app_theme.dart`.

## Primary Palette

### Brand Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `primaryColor` | `#6B9EFF` | 107, 158, 255 | Nexus Blue — primary actions, links, focus states, buttons |
| `primaryDark` | `#4A7DE0` | 74, 125, 224 | Hover states, pressed states |
| `primaryLight` | `#8BB3FF` | 139, 179, 255 | Light variant, disabled primary states |

### Secondary Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `secondaryColor` | `#7C5CFC` | 124, 92, 252 | Nexus Violet — highlights, badges, accent elements |
| `accentColor` | `#00D4AA` | 0, 212, 170 | Nexus Cyan — special highlights, success-like accents |

## Status Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `successColor` | `#10B981` | Success messages, completed states, checkmarks |
| `warningColor` | `#F59E0B` | Warning messages, caution states |
| `errorColor` | `#EF4444` | Error messages, destructive actions |
| `infoColor` | `#6B9EFF` | Informational messages (matches primary) |

**Note:** Status colors are universal UX colors, unchanged across themes.

## Text Colors

| Token | Hex | Contrast on Card | WCAG | Usage |
|-------|-----|-----------------|------|-------|
| `textPrimary` | `#F0F1F4` | ~12.9:1 | AAA | Primary text on dark backgrounds |
| `textSecondary` | `#A0A8B4` | ~5.9:1 | AA | Secondary text, subtitles, captions |
| `textTertiary` | `#757A85` | ~3.2:1 | AA large | Disabled text, placeholders, hints |
| `textOnPrimary` | `#FFFFFF` | — | — | Text on colored/gradient backgrounds |

## Background Colors — Layered Dark Surfaces

| Token | Hex | Layer | Usage |
|-------|-----|-------|-------|
| `backgroundColor` | `#15161A` | Background (deepest) | Main app background |
| `surfaceColor` | `#1D1E24` | Surface (mid) | Elevated surfaces, dialogs, bottom sheets |
| `cardColor` | `#282A32` | Card surface (top) | Card backgrounds |
| `cardBorderColor` | `#3D4050` | Border | Card and component borders |

Each layer has ~2x luminance jump from the previous for clear visual separation.

## Divider & Border Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `dividerColor` | `#2E3038` | Dividers, separators |
| `activeBorderColor` | `#6B9EFF` | Focused/active element borders |
| `glassBorderColor` | `white @ 12%` | Glass effect borders |

## Overlay Colors

| Token | Value | Usage |
|-------|-------|-------|
| `overlayLight` | `white @ 7%` | Subtle hover/pressed state overlay |
| `overlayMedium` | `white @ 12%` | More visible overlay for selection states |

## Glow Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `primaryGlow` | `#6B9EFF` | Blue glow for primary elements |
| `secondaryGlow` | `#7C5CFC` | Violet glow for secondary elements |
| `accentGlow` | `#00D4AA` | Cyan glow for accent elements |

## Shimmer Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `shimmerBase` | `#282A32` | Shimmer loading base color |
| `shimmerHighlight` | `#3D4050` | Shimmer loading highlight color |

---

## Gradients

### Primary Gradient (Blue-to-Violet)
Used for: CTAs, hero sections, primary action buttons.

```dart
static const LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF6B9EFF), // Nexus Blue
    Color(0xFF7C5CFC), // Nexus Violet
  ],
);
```

### Secondary Gradient (Subtle Card Surface)
Used for: Card surface variation, subtle depth.

```dart
static const LinearGradient secondaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF282A32), // Card surface
    Color(0xFF242630), // Subtle variation
  ],
);
```

### Ambient Gradient (Full-Screen Background)
Used for: Dashboard background depth.

```dart
static const LinearGradient ambientGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF1D1E24), // Surface depth
    Color(0xFF15161A), // Background
  ],
);
```

### Accent Gradient (Cyan-to-Blue)
Used for: Special highlights, accent decorations.

```dart
static const LinearGradient accentGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF00D4AA), // Nexus Cyan
    Color(0xFF6B9EFF), // Nexus Blue
  ],
);
```

### Glow Gradient (Radial)
Used for: Ambient background glow blobs.

```dart
static RadialGradient get glowGradient => RadialGradient(
  colors: [
    primaryColor.withValues(alpha: 0.12), // Center
    Colors.transparent,                    // Edge
  ],
);
```

---

## Shadow System — Glow-Based

### Card Shadow (Standard)
| Property | Value |
|----------|-------|
| Blue glow | `#6B9EFF` at 6% opacity, 12px blur, zero offset |
| Black base | `black` at 25% opacity, 8px blur, 2px Y offset |

### Elevated Shadow (Prominent)
| Property | Value |
|----------|-------|
| Blue glow | `#6B9EFF` at 12% opacity, 24px blur, zero offset |
| Black base | `black` at 35% opacity, 16px blur, 4px Y offset |

### Glow Shadow (Interactive)
| Property | Value |
|----------|-------|
| Blue glow | `#6B9EFF` at 25% opacity, 20px blur, zero offset |

### Neon Glow (FABs, Active States)
| Property | Value |
|----------|-------|
| Blue glow | `#6B9EFF` at 40% opacity, 20px blur, zero offset |
| Violet glow | `#7C5CFC` at 20% opacity, 30px blur, zero offset |

---

## Card Styling

### Dark Card with Glow
The primary card pattern — dark surface with border and glow shadow:

```dart
Container(
  decoration: BoxDecoration(
    color: AppTheme.cardColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppTheme.cardBorderColor, width: 1),
    boxShadow: AppTheme.cardShadow,
  ),
  child: /* content */,
)

// Or use helpers
AppTheme.elevatedCard(child: /* content */)
decoration: AppTheme.cardDecoration()
decoration: AppTheme.elevatedCardDecoration
```

### Glow Card (Interactive)
```dart
decoration: AppTheme.glowCardDecoration()
// Blue border + glow shadow for focused/active cards
```

### Gradient Card
```dart
decoration: AppTheme.gradientCardDecoration()
// Blue-tinted surface gradient
```

---

## Do's and Don'ts

### DO
```dart
// Use theme tokens
color: AppTheme.primaryColor

// Use semantic colors
color: AppTheme.errorColor // for errors
color: AppTheme.successColor // for success

// Use dark cards with border and glow
decoration: AppTheme.cardDecoration()

// Use light text on dark backgrounds
color: AppTheme.textPrimary
```

### DON'T
```dart
// Don't hardcode colors
color: Color(0xFF6B9EFF) // BAD - use AppTheme.primaryColor

// Don't use old red/light theme colors
color: Color(0xFFD32F2F) // BAD - old theme color

// Don't use white/light backgrounds for cards
color: Colors.white // BAD - use AppTheme.cardColor

// Don't use dark text on dark backgrounds
color: Color(0xFF1E293B) // BAD - invisible on dark, use textPrimary
```

---

## Color Pairing Rules

| Background | Text Color | Border/Accent Color |
|------------|------------|---------------------|
| Background (`backgroundColor`) | `textPrimary` | `dividerColor` or `cardBorderColor` |
| Surface (`surfaceColor`) | `textPrimary` | `cardBorderColor` |
| Card (`cardColor`) | `textPrimary` | `cardBorderColor` or `activeBorderColor` |
| Blue gradient | `textOnPrimary` (white) | `white @ 20%` |
| Violet gradient | `textOnPrimary` (white) | `white @ 20%` |

---

## Feature-Specific Color Decisions

| Feature | Color | Rationale |
|---------|-------|-----------|
| Success/Complete | Green `#10B981` | Universal UX — green = success |
| Progress indicators | Blue `primaryColor` | Brand consistency |
| Selected states | Blue `primaryColor` | Brand consistency |
| Warnings | Amber `#F59E0B` | Universal warning color |
| Errors | Red `#EF4444` | Universal error color |
| Info | Blue `#6B9EFF` | Matches primary for cohesion |
| Active/Focus glow | Blue `#6B9EFF` | AI intelligence signal |
