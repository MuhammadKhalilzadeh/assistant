# Jarvis Assistant - Nexus Dark v2 Design System

This directory contains the official UI/UX design rules for the Jarvis Assistant app. The **Nexus Dark v2** theme evokes a futuristic command center aesthetic with layered dark surfaces, electric blue accents, and intelligence glow effects.

## Design Philosophy

1. **Depth Through Darkness** — Layered dark surfaces (#15161A -> #1D1E24 -> #282A32) create hierarchy with ~2x luminance jumps
2. **Intelligence Glow** — Electric blue (#6B9EFF) and violet (#7C5CFC) accents signal AI presence
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
| `primaryColor` | `#6B9EFF` | Nexus Blue — primary actions, accents |
| `secondaryColor` | `#7C5CFC` | Nexus Violet — secondary highlights |
| `accentColor` | `#00D4AA` | Nexus Cyan — special highlights |
| `textPrimary` | `#F0F1F4` | Main text on dark backgrounds (~12.9:1) |
| `textSecondary` | `#A0A8B4` | Secondary/muted text (~5.9:1 AA) |
| `textOnPrimary` | `#FFFFFF` | Text on gradient backgrounds |
| `backgroundColor` | `#15161A` | Background — deepest layer |
| `surfaceColor` | `#1D1E24` | Surface — elevated layer |
| `cardColor` | `#282A32` | Card surface — card backgrounds |

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
