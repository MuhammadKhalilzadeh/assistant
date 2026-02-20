# Jarvis Assistant - Ember Dark Design System

This directory contains the official UI/UX design rules for the Jarvis Assistant app. The **Ember Dark** theme evokes a warm, focused command center aesthetic with layered dark surfaces, warm orange accents, and ambient glow effects.

## Design Philosophy

1. **Depth Through Darkness** — Layered dark surfaces (#141416 -> #1C1C20 -> #26262C) create hierarchy with ~2x luminance jumps
2. **Warm Presence** — Ember orange (#FF7A2F) and burnt orange (#FF5500) accents signal energy and focus
3. **Contained Color** — Color used surgically for status, actions, and data — never decorative
4. **Breathing Space** — Generous spacing; content floats in dark canvas
5. **Subtle Motion** — Glow pulses, shimmer loading, smooth transitions — alive but not distracting

## Source of Truth

All design tokens are defined in:
```
lib/presentation/constants/app_theme.dart
```

## Quick Reference Card

### Colors
| Token | Hex | Usage |
|-------|-----|-------|
| `primaryColor` | `#FF7A2F` | Ember Orange — primary actions, accents |
| `secondaryColor` | `#FF5500` | Burnt Orange — secondary highlights |
| `accentColor` | `#FFB347` | Warm Amber — special highlights |
| `textPrimary` | `#F2F0ED` | Main text on dark backgrounds (~12.5:1) |
| `textSecondary` | `#A8A4A0` | Secondary/muted text (~5.7:1 AA) |
| `textOnPrimary` | `#FFFFFF` | Text on gradient backgrounds |
| `backgroundColor` | `#141416` | Background — deepest layer |
| `surfaceColor` | `#1C1C20` | Surface — elevated layer |
| `cardColor` | `#26262C` | Card surface — card backgrounds |

### Spacing Scale
| Token | Value | Usage |
|-------|-------|-------|
| `spacingXS` | 4px | Tight spacing, icon gaps |
| `spacingSM` | 8px | Small component spacing |
| `spacingMD` | 16px | Default spacing, padding |
| `spacingLG` | 24px | Section spacing |
| `spacingXL` | 32px | Large section gaps |
| `spacingXXL` | 48px | Page-level spacing |

### Border Radius
| Token | Value | Usage |
|-------|-------|-------|
| `borderRadiusSmall` | 8px | Buttons, small elements |
| `borderRadiusMedium` | 12px | Input fields, chips |
| `borderRadiusLarge` | 16px | Navigation bars |
| `borderRadiusCard` | 16px | Cards (default) |
| `borderRadiusXLarge` | 24px | Modal sheets |
| `borderRadiusPill` | 999px | Pill-shaped CTA buttons |

### Responsive Padding Formula
```dart
final padding = (screenWidth * 0.04).clamp(16.0, 24.0);
```

### Glass Effect (Glassmorphism on Dark)
```dart
// Uses BackdropFilter with ImageFilter.blur
color: cardColor.withValues(alpha: 0.06)     // Background (defaults to cardColor)
border: Colors.white.withValues(alpha: 0.12) // Border
blur: ImageFilter.blur(sigmaX: 10, sigmaY: 10)
```

## Guide Contents

1. **[01_colors.md](./01_colors.md)** - Color system, gradients, and glow effects
2. **[02_typography.md](./02_typography.md)** - Typography scale and usage
3. **[03_spacing_layout.md](./03_spacing_layout.md)** - Spacing tokens and layout rules
4. **[04_components.md](./04_components.md)** - Button, card, input styling
5. **[05_screens.md](./05_screens.md)** - Screen structure patterns
6. **[06_animations.md](./06_animations.md)** - Animation guidelines
7. **[07_data_visualization.md](./07_data_visualization.md)** - Chart and data visualization styling

## Usage Guidelines

1. **Always use AppTheme tokens** — Never hardcode colors, spacing, or radii
2. **Follow responsive patterns** — Use the clamp formula for padding
3. **Dark backgrounds everywhere** — All screens use dark canvas with layered surfaces
4. **Glow effects for emphasis** — Use glow shadows for interactive/active elements

## Key Patterns

### Dark Backgrounds with Glow
All screens use dark backgrounds with cards distinguished by lighter surface color + border + subtle glow.

### Custom AppBar
Detail pages use a custom Row-based AppBar with dark contained icon buttons:
```dart
Row(
  children: [
    Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorderColor),
      ),
      child: IconButton(icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary)),
    ),
    Text('Title', style: TextStyle(color: AppTheme.textPrimary, fontSize: 24)),
  ],
)
```

### FAB Styling
Gradient background with neon glow:
```dart
Container(
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: AppTheme.primaryGradient,
    boxShadow: AppTheme.neonGlow,
  ),
  child: FloatingActionButton(
    backgroundColor: Colors.transparent,
    elevation: 0,
    child: const Icon(Icons.add, color: Colors.white),
  ),
)
```
