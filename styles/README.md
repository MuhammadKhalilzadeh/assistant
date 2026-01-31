# Jarvis Assistant - UI/UX Style Guide

This directory contains the official UI/UX design rules for the Jarvis Assistant app. These rules ensure consistent implementation patterns across all screens and components.

## Source of Truth

All design tokens are defined in:
```
lib/presentation/constants/app_theme.dart
```

## Quick Reference Card

### Colors
| Token | Hex | Usage |
|-------|-----|-------|
| `primaryColor` | `#6366F1` | Primary actions, accent elements |
| `secondaryColor` | `#EC4899` | Secondary highlights |
| `accentColor` | `#10B981` | Success states, positive actions |
| `textPrimary` | `#1E293B` | Main text on light backgrounds |
| `textSecondary` | `#64748B` | Secondary/muted text |
| `textOnPrimary` | `#FFFFFF` | Text on gradient backgrounds |

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
| `borderRadiusCard` | 20px | Cards (default) |
| `borderRadiusXLarge` | 24px | Modal sheets |

### Responsive Padding Formula
```dart
final padding = (screenWidth * 0.04).clamp(16.0, 24.0);
```

### Glass Effect (Glassmorphism)
```dart
color: Colors.white.withValues(alpha: 0.15)
border: Colors.white.withValues(alpha: 0.2)
```

## Guide Contents

1. **[01_colors.md](./01_colors.md)** - Color system and gradients
2. **[02_typography.md](./02_typography.md)** - Typography scale and usage
3. **[03_spacing_layout.md](./03_spacing_layout.md)** - Spacing tokens and layout rules
4. **[04_components.md](./04_components.md)** - Button, card, input styling
5. **[05_screens.md](./05_screens.md)** - Screen structure patterns
6. **[06_animations.md](./06_animations.md)** - Animation guidelines

## Usage Guidelines

1. **Always use AppTheme tokens** - Never hardcode colors, spacing, or radii
2. **Follow responsive patterns** - Use the clamp formula for padding
3. **Maintain consistency** - All detail screens use gradient backgrounds
4. **Glass effects on gradients** - Use 0.15 alpha for backgrounds, 0.2 for borders

## Key Patterns

### Gradient Backgrounds
All 19 screens use gradient backgrounds with white/glass-effect content.

### Custom AppBar
Detail pages use a custom Row-based AppBar, not Material AppBar:
```dart
Row(
  children: [
    IconButton(icon: Icon(Icons.arrow_back, color: Colors.white)),
    Text('Title', style: TextStyle(color: Colors.white, fontSize: 24)),
  ],
)
```

### FAB Styling
Always white background with theme foreground:
```dart
FloatingActionButton(
  backgroundColor: Colors.white,
  foregroundColor: AppTheme.primaryColor,
)
```
