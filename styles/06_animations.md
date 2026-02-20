# Animation Guidelines — Ember Dark

This document defines animation standards for consistent motion across the app.

## Duration Tokens

| Duration | Value | Usage |
|----------|-------|-------|
| Micro | 100ms | Tiny feedback (opacity flicker, icon swap) |
| Fast | 150ms | Button press, micro-interactions |
| Standard | 300ms | Page transitions, focus states |
| Slow | 500ms | Complex animations, loading states |
| Ambient | 2000ms | Glow pulses, breathing effects |
| Ambient Slow | 4000ms | Bottom ambient glow pulse |
| Drift | 8000ms | Slow ambient float (dashboard only) |

---

## Animation Curves

| Curve | Usage |
|-------|-------|
| `Curves.easeInOut` | Default for most animations |
| `Curves.easeOut` | Entering animations |
| `Curves.easeIn` | Exiting animations |

---

## Button Press Animation

Implemented in `CustomButton`:

```dart
// Controller setup
_animationController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 150),
);

// Scale animation
_scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
  CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
);

// Apply with ScaleTransition
ScaleTransition(
  scale: _scaleAnimation,
  child: /* button content */,
)
```

### Trigger Events
```dart
onTapDown: (_) => _animationController.forward();
onTapUp: (_) => _animationController.reverse();
onTapCancel: () => _animationController.reverse();
```

| Property | Value |
|----------|-------|
| Duration | 150ms |
| Scale range | 1.0 -> 0.95 |
| Curve | `Curves.easeInOut` |

---

## Focus State Animation

Implemented in `CustomTextField`:

```dart
// Controller setup
_animationController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 300),
);

// Trigger on focus change
void _onFocusChange() {
  if (_focusNode.hasFocus) {
    _animationController.forward();
  } else {
    _animationController.reverse();
  }
}
```

### Visual Changes on Focus
| Property | Unfocused | Focused |
|----------|-----------|---------|
| Border width | 1px | 1.5px |
| Border color | `cardBorderColor` | `activeBorderColor` (#FF7A2F) |
| Shadow | none | orange glow |

```dart
// Shadow on focus
boxShadow: _isFocused
    ? [
        BoxShadow(
          color: AppTheme.primaryColor.withValues(alpha: 0.15),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ]
    : null,
```

---

## Glow Pulse Animation

For active states like a running timer — a 2-second breathing glow cycle:

```dart
// Controller setup
_glowController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 2000),
);

_glowAnimation = Tween<double>(begin: 0.15, end: 0.40).animate(
  CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
);

// Loop
_glowController.repeat(reverse: true);

// Apply to shadow
BoxShadow(
  color: AppTheme.primaryColor.withValues(alpha: _glowAnimation.value),
  blurRadius: 20,
  offset: Offset.zero,
)
```

| Property | Value |
|----------|-------|
| Duration | 2000ms (full cycle) |
| Opacity range | 0.15 -> 0.40 |
| Glow color | `AppTheme.primaryColor` (#FF7A2F) |
| Curve | `Curves.easeInOut` |
| Loop | `repeat(reverse: true)` |

---

## Bottom Ambient Glow Pulse

A slow-breathing warm glow at the bottom of dashboard/hero screens:

```dart
// Controller setup
_ambientGlowController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 4000),
);

_ambientGlowAnimation = Tween<double>(begin: 0.04, end: 0.10).animate(
  CurvedAnimation(parent: _ambientGlowController, curve: Curves.easeInOut),
);

// Loop
_ambientGlowController.repeat(reverse: true);

// Apply to bottom glow container
Positioned(
  bottom: -100,
  left: 0,
  right: 0,
  height: 300,
  child: AnimatedBuilder(
    animation: _ambientGlowAnimation,
    builder: (context, child) {
      return Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomCenter,
            radius: 0.8,
            colors: [
              Color(0xFFFF7A2F).withValues(alpha: _ambientGlowAnimation.value),
              Colors.transparent,
            ],
          ),
        ),
      );
    },
  ),
)
```

| Property | Value |
|----------|-------|
| Duration | 4000ms (full cycle) |
| Opacity range | 0.04 -> 0.10 |
| Glow color | `#FF7A2F` (Ember Orange) |
| Curve | `Curves.easeInOut` |
| Loop | `repeat(reverse: true)` |

---

## Shimmer Loading Effect

For skeleton screens while data loads — a 1.5-second shimmer sweep:

```dart
// Shimmer widget
AnimatedBuilder(
  animation: _shimmerController,
  builder: (context, child) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            AppTheme.shimmerBase,      // #26262C
            AppTheme.shimmerHighlight, // #3A3A44
            AppTheme.shimmerBase,      // #26262C
          ],
          stops: [
            _shimmerAnimation.value - 0.3,
            _shimmerAnimation.value,
            _shimmerAnimation.value + 0.3,
          ],
        ).createShader(bounds);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.shimmerBase,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  },
)
```

| Property | Value |
|----------|-------|
| Duration | 1500ms |
| Base color | `AppTheme.shimmerBase` (#26262C) |
| Highlight color | `AppTheme.shimmerHighlight` (#3A3A44) |
| Loop | `repeat()` |

---

## Card Entrance Animation

Staggered fade+slide for list items on page load:

```dart
// Per-item animation
_entranceController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 400),
);

_fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
  CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
);

_slideAnimation = Tween<Offset>(
  begin: const Offset(0, 0.05),
  end: Offset.zero,
).animate(
  CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
);

// Stagger: each card starts 60ms after the previous
Future.delayed(Duration(milliseconds: index * 60), () {
  _entranceController.forward();
});
```

| Property | Value |
|----------|-------|
| Duration | 400ms per card |
| Stagger delay | 60ms between cards |
| Fade | 0.0 -> 1.0 |
| Slide | 5% down -> center |
| Curve | `Curves.easeOut` |

---

## Ambient Float (Dashboard Only)

Very slow drift animation for decorative glow blobs:

```dart
_floatController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 8000),
);

_floatAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
  CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
);

_floatController.repeat(reverse: true);

// Apply as Transform.translate
Transform.translate(
  offset: Offset(0, _floatAnimation.value),
  child: /* glow blob */,
)
```

| Property | Value |
|----------|-------|
| Duration | 8000ms (full cycle) |
| Drift range | -5px to +5px vertical |
| Curve | `Curves.easeInOut` |
| Loop | `repeat(reverse: true)` |

---

## Page Transitions

### Fade Transition (Default)
Used for navigation from dashboard to detail pages:

```dart
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => page,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  },
  transitionDuration: const Duration(milliseconds: 300),
)
```

### Slide Transition
Alternative for horizontal navigation:

```dart
transitionsBuilder: (context, animation, secondaryAnimation, child) {
  const begin = Offset(1.0, 0.0);  // From right
  const end = Offset.zero;
  const curve = Curves.easeInOut;

  var tween = Tween(begin: begin, end: end).chain(
    CurveTween(curve: curve),
  );

  return SlideTransition(
    position: animation.drive(tween),
    child: child,
  );
}
```

| Transition | Duration | Direction |
|------------|----------|-----------|
| Fade | 300ms | Opacity 0 -> 1 |
| Slide | 300ms | Right -> Center |

---

## Loading States

### CircularProgressIndicator in Buttons
```dart
SizedBox(
  height: 20,
  width: 20,
  child: CircularProgressIndicator(
    strokeWidth: 2,
    valueColor: AlwaysStoppedAnimation<Color>(textColor),
  ),
)
```

### LinearProgressIndicator
```dart
LinearProgressIndicator(
  value: progress,
  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
  minHeight: 8,
)
```

---

## Implicit Animations

For simple property changes, use implicit animations:

### AnimatedContainer
```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  decoration: BoxDecoration(
    color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: isSelected ? AppTheme.activeBorderColor : AppTheme.cardBorderColor,
    ),
  ),
)
```

### AnimatedOpacity
```dart
AnimatedOpacity(
  duration: const Duration(milliseconds: 300),
  opacity: isVisible ? 1.0 : 0.0,
  child: content,
)
```

---

## Animation Best Practices

### DO
```dart
// Use animation controllers with proper lifecycle
@override
void initState() {
  super.initState();
  _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
}

@override
void dispose() {
  _animationController.dispose();
  super.dispose();
}

// Use CurvedAnimation for easing
CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)

// Use standard durations
const Duration(milliseconds: 100)   // Micro
const Duration(milliseconds: 150)   // Fast
const Duration(milliseconds: 300)   // Standard
const Duration(milliseconds: 2000)  // Ambient
const Duration(milliseconds: 4000)  // Ambient Slow
```

### DON'T
```dart
// Don't use arbitrary durations
const Duration(milliseconds: 237)  // BAD

// Don't forget to dispose controllers
// Missing dispose() call - memory leak

// Don't use linear animation for UI
Curves.linear  // BAD for UI, feels robotic
```

---

## Animation Decision Tree

```
Is it a micro-interaction (button press, toggle)?
|- Yes -> 150ms, easeInOut
|- No
    Is it a page transition?
    |- Yes -> 300ms, fade or slide
    |- No
        Is it a glow/breathing effect?
        |- Yes -> 2000ms, easeInOut, repeat(reverse: true)
        |- No
            Is it a bottom ambient glow?
            |- Yes -> 4000ms, easeInOut, repeat(reverse: true)
            |- No
                Is it a complex sequence (card entrance)?
                |- Yes -> 400ms per item, 60ms stagger, easeOut
                |- No -> 300ms, easeInOut
```

---

## Performance Tips

1. **Use `RepaintBoundary`** for complex animated widgets
2. **Prefer `Transform`** over `Container` for position changes (GPU accelerated)
3. **Use `const` constructors** where possible
4. **Avoid animating layout** (prefer opacity and transform)
5. **Test on lower-end devices** for jank detection
6. **Dispose all controllers** — especially repeating ones (glow, shimmer, float, ambient glow)
