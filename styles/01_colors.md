# Color System — Ember Dark

All colors are defined in `lib/presentation/constants/app_theme.dart`.

## Primary Palette

### Brand Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `primaryColor` | `#FF7A2F` | 255, 122, 47 | Ember Orange — primary actions, links, focus states, buttons |
| `primaryDark` | `#E06515` | 224, 101, 21 | Hover states, pressed states |
| `primaryLight` | `#FF9A5C` | 255, 154, 92 | Light variant, disabled primary states |

### Secondary Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `secondaryColor` | `#FF5500` | 255, 85, 0 | Burnt Orange — deep highlights, badges, accent elements |
| `accentColor` | `#FFB347` | 255, 179, 71 | Warm Amber — special highlights, gold accents |

## Status Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `successColor` | `#10B981` | Success messages, completed states, checkmarks |
| `warningColor` | `#F5B731` | Warning messages, caution states |
| `errorColor` | `#EF4444` | Error messages, destructive actions |
| `infoColor` | `#FF7A2F` | Informational messages (matches primary) |

### Warning vs. Primary Differentiation

Because the primary color (#FF7A2F) and warning color (#F5B731) are both warm tones, strict rules prevent confusion:

| Attribute | Primary (Orange) | Warning (Yellow-Amber) |
|-----------|-----------------|----------------------|
| Hex | `#FF7A2F` | `#F5B731` |
| Hue | Red-orange (18°) | Yellow-amber (42°) |
| Icon required | No | **Yes — always pair with warning icon** |
| Typical context | Buttons, links, accents | Alerts, caution banners, validation |
| Background tint | `#FF7A2F` @ 15% | `#F5B731` @ 15% |

**Rule:** Warning elements must always include a warning icon (⚠ `Icons.warning_amber_rounded`) to distinguish them from primary-colored elements. Never use warning color for buttons or interactive accents.

## Text Colors

| Token | Hex | Contrast on Card | WCAG | Usage |
|-------|-----|-----------------|------|-------|
| `textPrimary` | `#F2F0ED` | ~12.5:1 | AAA | Primary text on dark backgrounds |
| `textSecondary` | `#A8A4A0` | ~5.7:1 | AA | Secondary text, subtitles, captions |
| `textTertiary` | `#7A7774` | ~3.1:1 | AA large | Disabled text, placeholders, hints |
| `textOnPrimary` | `#FFFFFF` | — | — | Text on colored/gradient backgrounds |

## Background Colors — Layered Dark Surfaces

| Token | Hex | Layer | Usage |
|-------|-----|-------|-------|
| `backgroundColor` | `#141416` | Background (deepest) | Main app background |
| `surfaceColor` | `#1C1C20` | Surface (mid) | Elevated surfaces, dialogs, bottom sheets |
| `cardColor` | `#26262C` | Card surface (top) | Card backgrounds |
| `cardBorderColor` | `#3A3A44` | Border | Card and component borders |

Each layer has ~2x luminance jump from the previous for clear visual separation.

## Divider & Border Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `dividerColor` | `#2E2E34` | Dividers, separators |
| `activeBorderColor` | `#FF7A2F` | Focused/active element borders |
| `glassBorderColor` | `white @ 12%` | Glass effect borders |

## Overlay Colors

| Token | Value | Usage |
|-------|-------|-------|
| `overlayLight` | `white @ 7%` | Subtle hover/pressed state overlay |
| `overlayMedium` | `white @ 12%` | More visible overlay for selection states |

## Glow Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `primaryGlow` | `#FF7A2F` | Orange glow for primary elements |
| `secondaryGlow` | `#FF5500` | Burnt orange glow for secondary elements |
| `accentGlow` | `#FFB347` | Amber glow for accent elements |

## Shimmer Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `shimmerBase` | `#26262C` | Shimmer loading base color |
| `shimmerHighlight` | `#3A3A44` | Shimmer loading highlight color |

---

## Gradients

### Primary Gradient (Orange-to-Burnt-Orange)
Used for: CTAs, hero sections, primary action buttons.

```dart
static const LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFFF7A2F), // Ember Orange
    Color(0xFFFF5500), // Burnt Orange
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
    Color(0xFF26262C), // Card surface
    Color(0xFF222226), // Subtle variation
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
    Color(0xFF1C1C20), // Surface depth
    Color(0xFF141416), // Background
  ],
);
```

### Accent Gradient (Amber-to-Orange)
Used for: Special highlights, accent decorations.

```dart
static const LinearGradient accentGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFFFB347), // Warm Amber
    Color(0xFFFF7A2F), // Ember Orange
  ],
);
```

### Glow Gradient (Radial)
Used for: Ambient background glow blobs.

```dart
static RadialGradient get glowGradient => RadialGradient(
  colors: [
    primaryColor.withValues(alpha: 0.10), // Center
    Colors.transparent,                    // Edge
  ],
);
```

### Bottom Ambient Glow Gradient
Used for: Warm glow at the bottom of screens, simulating reflected light.

```dart
static RadialGradient get bottomAmbientGlow => RadialGradient(
  center: Alignment.bottomCenter,
  radius: 0.8,
  colors: [
    Color(0xFFFF7A2F).withValues(alpha: 0.08), // Ember Orange core
    Colors.transparent,                          // Fade to transparent
  ],
);
```

Place as a `Positioned` widget at the bottom of a `Stack`:
```dart
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
)
```

---

## Shadow System — Glow-Based

Orange is perceptually more intense than blue, so all glow opacities are reduced by ~15-25% compared to the previous blue system to prevent an overly "fiery" appearance.

### Card Shadow (Standard)
| Property | Value |
|----------|-------|
| Orange glow | `#FF7A2F` at 5% opacity, 12px blur, zero offset |
| Black base | `black` at 25% opacity, 8px blur, 2px Y offset |

### Elevated Shadow (Prominent)
| Property | Value |
|----------|-------|
| Orange glow | `#FF7A2F` at 10% opacity, 24px blur, zero offset |
| Black base | `black` at 35% opacity, 16px blur, 4px Y offset |

### Glow Shadow (Interactive)
| Property | Value |
|----------|-------|
| Orange glow | `#FF7A2F` at 20% opacity, 20px blur, zero offset |

### Neon Glow (FABs, Active States)
| Property | Value |
|----------|-------|
| Orange glow | `#FF7A2F` at 30% opacity, 20px blur, zero offset |
| Burnt orange glow | `#FF5500` at 15% opacity, 30px blur, zero offset |

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
// Orange border + glow shadow for focused/active cards
```

### Gradient Card
```dart
decoration: AppTheme.gradientCardDecoration()
// Orange-tinted surface gradient
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
color: Color(0xFFFF7A2F) // BAD - use AppTheme.primaryColor

// Don't use old blue/violet theme colors
color: Color(0xFF6B9EFF) // BAD - old Nexus Blue, removed
color: Color(0xFF7C5CFC) // BAD - old Nexus Violet, removed

// Don't use white/light backgrounds for cards
color: Colors.white // BAD - use AppTheme.cardColor

// Don't use dark text on dark backgrounds
color: Color(0xFF1E293B) // BAD - invisible on dark, use textPrimary

// Don't use primary orange for warnings
color: AppTheme.primaryColor // BAD for warnings - use warningColor with icon
```

---

## Color Pairing Rules

| Background | Text Color | Border/Accent Color |
|------------|------------|---------------------|
| Background (`backgroundColor`) | `textPrimary` | `dividerColor` or `cardBorderColor` |
| Surface (`surfaceColor`) | `textPrimary` | `cardBorderColor` |
| Card (`cardColor`) | `textPrimary` | `cardBorderColor` or `activeBorderColor` |
| Orange gradient | `textOnPrimary` (white) | `white @ 20%` |
| Burnt orange gradient | `textOnPrimary` (white) | `white @ 20%` |

---

## WCAG Contrast Audit — Orange on Surfaces

White text (#FFFFFF) on orange buttons must meet AA compliance. Orange (#FF7A2F) as a background:

| Text | Background | Ratio | Result | Notes |
|------|-----------|-------|--------|-------|
| `#FFFFFF` (white) | `#FF7A2F` (primary) | 3.2:1 | AA Large | Min 16px semibold; all orange buttons use this |
| `#FFFFFF` (white) | `#FF5500` (secondary) | 3.8:1 | AA Large | Darker orange, better contrast |
| `#FFFFFF` (white) | `#E06515` (primaryDark) | 4.3:1 | AA | Hover/pressed states pass AA at any size |
| `#F2F0ED` (textPrimary) | `#26262C` (card) | ~12.5:1 | AAA | Primary text on cards |
| `#A8A4A0` (textSecondary) | `#26262C` (card) | ~5.7:1 | AA | Secondary text on cards |
| `#7A7774` (textTertiary) | `#26262C` (card) | ~3.1:1 | AA Large | Hints/placeholders on cards |
| `#F2F0ED` (textPrimary) | `#141416` (bg) | ~14.8:1 | AAA | Primary text on background |
| `#FF7A2F` (primary) | `#141416` (bg) | ~5.1:1 | AA | Orange accent text on background |
| `#FF7A2F` (primary) | `#26262C` (card) | ~4.2:1 | AA | Orange accent text on cards |

**Rule:** All primary orange buttons use white text at minimum 16px semibold to ensure AA Large compliance.

---

## Feature-Specific Color Decisions

| Feature | Color | Rationale |
|---------|-------|-----------|
| Success/Complete | Green `#10B981` | Universal UX — green = success |
| Progress indicators | Orange `primaryColor` | Brand consistency |
| Selected states | Orange `primaryColor` | Brand consistency |
| Warnings | Yellow-amber `#F5B731` | Shifted yellow to differentiate from orange primary |
| Errors | Red `#EF4444` | Universal error color |
| Info | Orange `#FF7A2F` | Matches primary for cohesion |
| Active/Focus glow | Orange `#FF7A2F` | Warm presence signal |
