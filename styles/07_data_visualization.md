# Data Visualization — Ember Dark

This document defines styling rules for charts, gauges, and data displays in the app.

## Chart Color Palette

Ordered color sequence for multi-series data. Use colors in order; do not skip or reorder.

| Index | Token | Hex | Usage |
|-------|-------|-----|-------|
| 1 | `chartOrange` | `#FF7A2F` | Primary series (matches primaryColor) |
| 2 | `chartAmber` | `#FFB347` | Secondary series (matches accentColor) |
| 3 | `chartBurntOrange` | `#FF5500` | Tertiary series (matches secondaryColor) |
| 4 | `chartGold` | `#F5B731` | Fourth series |
| 5 | `chartPeach` | `#FF9A5C` | Fifth series (matches primaryLight) |
| 6 | `chartWhite` | `#F2F0ED` | Sixth series / contrast (matches textPrimary) |

```dart
static const List<Color> chartPalette = [
  Color(0xFFFF7A2F), // Orange
  Color(0xFFFFB347), // Amber
  Color(0xFFFF5500), // Burnt Orange
  Color(0xFFF5B731), // Gold
  Color(0xFFFF9A5C), // Peach
  Color(0xFFF2F0ED), // White
];
```

For two-series charts (e.g., bar charts from samples), use:
- Series A: `#FF7A2F` (orange)
- Series B: `#F2F0ED` (white/light)

---

## Single-Metric Gauge

Circular arc gauge for displaying a single percentage or score:

```dart
CustomPaint(
  size: const Size(120, 120),
  painter: GaugePainter(
    value: 0.75,
    backgroundColor: AppTheme.cardBorderColor,  // #3A3A44
    foregroundColor: AppTheme.primaryColor,       // #FF7A2F
    strokeWidth: 8,
  ),
  child: Center(
    child: Text(
      '75%',
      style: TextStyle(
        color: AppTheme.primaryColor,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
)
```

| Property | Value |
|----------|-------|
| Track (background) | `AppTheme.cardBorderColor` (#3A3A44) |
| Arc (foreground) | `AppTheme.primaryColor` (#FF7A2F) |
| Stroke width | 8px |
| Cap | `StrokeCap.round` |
| Start angle | -π/2 (12 o'clock) |
| Value text | `AppTheme.primaryColor`, 24px, w700 |

### Gauge with Glow
For emphasis, add a glow behind the arc:
```dart
Paint()
  ..color = AppTheme.primaryColor.withValues(alpha: 0.20)
  ..strokeWidth = 12
  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
```

---

## Axis & Grid Styling

### Grid Lines
```dart
Paint()
  ..color = AppTheme.dividerColor  // #2E2E34
  ..strokeWidth = 1
```

### Axis Labels
```dart
TextStyle(
  color: AppTheme.textTertiary,  // #7A7774
  fontSize: 11,
  fontWeight: FontWeight.w400,
)
```

### Axis Lines
```dart
Paint()
  ..color = AppTheme.cardBorderColor  // #3A3A44
  ..strokeWidth = 1
```

| Element | Color | Weight |
|---------|-------|--------|
| Grid lines | `dividerColor` (#2E2E34) | 1px |
| Axis lines | `cardBorderColor` (#3A3A44) | 1px |
| Axis labels | `textTertiary` (#7A7774) | 11px, w400 |
| Data labels | `textSecondary` (#A8A4A0) | 12px, w500 |

---

## Tooltip Styling

Tooltips that appear on tap/hover over data points:

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    color: AppTheme.surfaceColor,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppTheme.cardBorderColor, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.30),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
    ],
  ),
)
```

| Property | Value |
|----------|-------|
| Background | `AppTheme.surfaceColor` (#1C1C20) |
| Border | `AppTheme.cardBorderColor` (#3A3A44), 1px |
| Border radius | 8px |
| Label text | `textSecondary`, 11px |
| Value text | `textPrimary`, 14px, w600 |

---

## Bar Chart Styling

### Vertical Bars
```dart
Container(
  width: barWidth,
  height: barHeight,
  decoration: BoxDecoration(
    color: seriesColor,  // from chartPalette
    borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
  ),
)
```

### Two-Series Bar Chart (Orange + White)
From sample designs, two-series bar charts alternate:
- Primary bars: `#FF7A2F` (orange)
- Secondary bars: `#F2F0ED` (white) at 80% opacity

```dart
// Primary bar
color: AppTheme.primaryColor  // #FF7A2F

// Secondary bar
color: AppTheme.textPrimary.withValues(alpha: 0.80)  // #F2F0ED @ 80%
```

### Bar Spacing
| Property | Value |
|----------|-------|
| Bar width | Responsive: `(chartWidth / dataCount) * 0.6` |
| Bar gap | `(chartWidth / dataCount) * 0.4` |
| Group gap (multi-series) | 4px between bars in same group |
| Corner radius | 4px top corners |

---

## Line Chart Styling

### Data Line
```dart
Paint()
  ..color = AppTheme.primaryColor  // #FF7A2F
  ..strokeWidth = 2.5
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.stroke
```

### Area Fill (under line)
```dart
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    AppTheme.primaryColor.withValues(alpha: 0.20),
    AppTheme.primaryColor.withValues(alpha: 0.0),
  ],
)
```

### Data Points
```dart
Container(
  width: 8,
  height: 8,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: AppTheme.primaryColor,
    border: Border.all(color: AppTheme.cardColor, width: 2),
  ),
)
```

---

## Pie / Donut Chart Styling

Use the `chartPalette` colors in order. For donut charts:

| Property | Value |
|----------|-------|
| Outer radius | Responsive |
| Inner radius | 60% of outer radius |
| Segment gap | 2px |
| Center text | `textPrimary`, headline size, w700 |
| Legend text | `textSecondary`, 12px |
| Legend dot size | 8px circle |

---

## Do's and Don'ts

### DO
```dart
// Use chartPalette for consistent colors
color: AppTheme.chartPalette[seriesIndex]

// Use dark background for chart area
color: AppTheme.cardColor

// Use subtle grid lines
color: AppTheme.dividerColor

// Add glow to highlighted/active data
boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.20), blurRadius: 8)]
```

### DON'T
```dart
// Don't use random or non-palette colors for data series
color: Colors.blue  // BAD - use chartPalette

// Don't use bright grid lines
color: Colors.white  // BAD - use dividerColor for subtle grids

// Don't use text-heavy legends — keep them minimal
// BAD: Long paragraph descriptions next to chart
```
