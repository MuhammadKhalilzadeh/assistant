# Animation Guidelines

This document defines animation standards for consistent motion across the app.

## Duration Tokens

| Duration | Value | Usage |
|----------|-------|-------|
| Fast | 150ms | Button press, micro-interactions |
| Standard | 300ms | Page transitions, focus states |
| Slow | 500ms | Complex animations, loading states |

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
| Scale range | 1.0 → 0.95 |
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
| Border width | 1px | 2px |
| Border alpha | 0.2 | 0.5 |
| Shadow | none | white glow |

```dart
// Shadow on focus
boxShadow: _isFocused
    ? [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ]
    : null,
```

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
| Fade | 300ms | Opacity 0 → 1 |
| Slide | 300ms | Right → Center |

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
  backgroundColor: Colors.white.withValues(alpha: 0.2),
  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
    color: isSelected ? AppTheme.primaryColor : Colors.white,
    borderRadius: BorderRadius.circular(12),
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
const Duration(milliseconds: 150)  // Fast
const Duration(milliseconds: 300)  // Standard
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
├─ Yes → 150ms, easeInOut
└─ No
    Is it a page transition?
    ├─ Yes → 300ms, fade or slide
    └─ No
        Is it a complex sequence?
        ├─ Yes → 500ms, consider stagger
        └─ No → 300ms, easeInOut
```

---

## Staggered Animations (Future)

For list item animations, consider staggering:

```dart
// Each item starts slightly after the previous
AnimationController(
  duration: const Duration(milliseconds: 500),
)

// Stagger calculation
final interval = Interval(
  index * 0.1,  // Start later for each item
  (index * 0.1) + 0.5,  // End
  curve: Curves.easeOut,
)
```

---

## Performance Tips

1. **Use `RepaintBoundary`** for complex animated widgets
2. **Prefer `Transform`** over `Container` for position changes (GPU accelerated)
3. **Use `const` constructors** where possible
4. **Avoid animating layout** (prefer opacity and transform)
5. **Test on lower-end devices** for jank detection
