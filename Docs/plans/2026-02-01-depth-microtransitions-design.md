# Depth and Microtransitions Design
**Date:** 2026-02-01
**Status:** Approved
**Target Devices:** iPhone 15+, iPad Pro M2+
**Implementation Approach:** Feature-by-Feature

## Vision

Transform FinPessoal into a bold, expressive premium finance app with sophisticated animations throughout. Full dynamic experience targeting latest devices with ProMotion support, rich haptic choreography, and mode-aware visual refinements.

## Design Decisions

### Animation Philosophy
- **Bold & Expressive**: Full expression style with dynamic animations throughout
- **Premium Feel**: "Modern luxury brand meets premium mobile experience"
- **Device Target**: iPhone 15+ and iPad Pro M2+ only, pushing hardware limits
- **Performance**: 120 FPS baseline with ProMotion, 60 FPS minimum

### Priority Order
1. Financial Dashboard (Weeks 1-3)
2. Transaction Flow (Weeks 4-6)
3. Goals & Budgets (Weeks 7-9)
4. Lists & Navigation (Weeks 10-11)

### Interaction Design
- **Haptics**: Rich haptic choreography synchronized with animations
- **Sound**: Minimal sound accents (off by default) for major actions only
- **Accessibility**: Tiered animation modes (Full, Reduced, Minimal)
- **Dark Mode**: Mode-aware refinements maintaining consistent choreography

### Implementation Strategy
- **Feature-by-Feature**: Complete each area fully before moving to next
- **Timeline**: 12 weeks total (3 weeks per major feature + 2 weeks polish)

## Architecture

### Three-Layer System

**Layer 1: Animation Engine**
- Centralized `AnimationEngine` managing all configurations
- Named animation presets (springs, timings, curves)
- `AnimationMode` enum: `.full`, `.reduced`, `.minimal`
- SwiftUI `TimelineView` for complex choreography
- Metal shaders for particle effects

**Layer 2: Reusable Components**
- `AnimatedCard`: Base for all card animations
- `PhysicsNumberCounter`: Animated numbers with spring physics
- `ParticleEmitter`: Configurable Metal-based particle system
- `GestureInteractionModifier`: Unified gesture handling with haptics
- `HeroTransitionCoordinator`: Complex hero transitions

**Layer 3: Screen-Specific Coordinators**
- Per-feature animation coordinators
- Screen-specific haptic patterns
- Custom animation compositions

## Feature Specifications

### 1. Financial Dashboard (Priority #1)

#### Balance Cards
- **Hero expansion**: Tap → full-screen detail with morphing transition
- **Number animations**: Balance changes with spring physics, digits roll individually
- **Micro-interactions**: Press/hold shows scale + shadow depth change
- **Particle effects**: Gold shimmer (light mode), soft glow (dark mode)
- **Parallax on scroll**: Multi-speed element movement for depth

#### Interactive Charts
- **Gesture exploration**: Pan/pinch with fluid physics
- **Data animations**: Staggered bar/line drawing
- **Hover states**: Touch scale + haptic + tooltip
- **Type transitions**: Morphing between chart types

#### Loading States
- **Skeleton shimmer**: Animated gradient on placeholders
- **Staggered reveal**: Cards appear sequentially (50ms delay)

#### Scroll Interactions
- **Pull-to-refresh**: Custom spring bounce animation
- **Scroll momentum**: Overdamped physics
- **Section headers**: Sticky with blur on scroll

#### Haptic Choreography
- Card tap: Light impact
- Hero expansion: Medium impact
- Data refresh: Success notification
- Positive balance: Gentle success pattern

### 2. Transaction Flow (Priority #2)

#### Add Transaction Sheet
- **Dramatic entrance**: Spring overshoot slide + backdrop blur
- **Card expansion**: Button morphs to full form with hero animation
- **Form fields**: Sequential staggered appearance (50ms delay)
- **Amount input**: Subtle bounce on each digit
- **Category selection**: Grid with hover states, selection pulse
- **Account picker**: Swipeable carousel with snap physics

#### Gesture Interactions
- **Swipe to categorize**: Right swipe with haptic confirmation
- **Swipe to delete**: Left swipe with warning haptic
- **Drag to reorder**: Long press + drag with elevation shadow

#### Success Animations
- Form collapse back to list
- New card flies into position
- Success haptic (tap-tap-tap)
- Optional subtle sound
- Gold particle burst (Full mode)

#### Transaction Detail
- **Hero transition**: Row expands maintaining visual continuity
- **Edit mode**: Fields morph to editable state
- **Delete confirmation**: Dramatic scale + blur backdrop

#### Haptic Patterns
- Field focus: Light tap
- Category selected: Medium impact
- Amount entered: Selection feedback
- Save success: Success notification
- Swipe actions: Directional feedback

### 3. Goals & Budgets (Priority #3)

#### Goal Progress
- **Liquid fill**: Fluid simulation for progress bars
- **Milestone markers**: Pulse when reached
- **Interactive progress**: Drag for "what-if" scenarios
- **Time-based animations**: Real-time daily progress with `TimelineView`

#### Achievement Celebrations
- **Particle explosion**: Gold/silver burst from center
- **Haptic crescendo**: Building intensity (light → medium → heavy)
- **Success sound**: Optional triumphant chime
- **Card transformation**: 3D flip to "completed" state
- **Confetti mode**: Brief shower effect (Full mode)

#### Budget Tracking
- **Health meter**: Color-morphing progress ring
- **Warning animations**: Pulsing glow + warning haptic
- **Overspend effect**: Shake + error haptic
- **Category breakdown**: Pie chart segments with rotation + scale

#### Interactive Cards
- **Parallax layers**: Multi-speed background/progress/text
- **Press interaction**: 3D tilt based on touch location
- **Expansion**: Hero transition to detailed breakdown

#### Haptic Choreography
- Progress update: Gentle selection tap
- Milestone reached: Medium impact
- Goal achieved: Success crescendo
- Budget warning: Warning pattern (tap-pause-tap-pause)
- Budget exceeded: Error pattern (heavy-heavy-heavy)

### 4. Lists & Navigation (Priority #4)

#### List Animations
- **Staggered entrance**: Sequential with 30ms delay, slide from right
- **Item insertion**: Fly in from top with spring bounce
- **Item deletion**: Scale down + fade, gap collapse with physics
- **Reordering**: Elevation shadow during drag, fluid repositioning
- **Empty states**: Animated illustrations with breathing effect

#### Swipe Gestures
- **Contextual actions**: Rubber-band resistance
- **Completion**: Spring animation to final state
- **Cancel**: Elastic snap-back with overdamped spring
- **Multi-directional**: Left (delete), right (actions) with distinct haptics

#### Tab Navigation
- **Tab switching**: Matched geometry morphing
- **Icon animations**: Scale up + color transition
- **Indicator**: Flowing indicator (not jumping)
- **Badge animations**: Gentle pulse for notifications

#### Navigation Transitions
- **Push/Pop**: Custom slide with blur + scale for depth
- **Modal**: Sheet slide with progressive backdrop blur
- **Hero transitions**: Shared element morphing with matched geometry
- **Dismissal**: Interactive gesture-driven with progress-based blur

#### Context Menus
- **Appearance**: Spring scale from touch point with blur
- **Item reveal**: Cascading stagger
- **Selection**: Item scale on touch, collapse on selection
- **Haptics**: Medium on open, light on selection

## Technical Implementation

### Animation Mode System
```swift
enum AnimationMode {
  case full      // All effects enabled
  case reduced   // No particles, simplified transitions
  case minimal   // Fade-only, instant where possible
}
```

### Performance Budget
- **Target**: 120 FPS (ProMotion) on iPhone 15 Pro
- **Fallback**: 60 FPS minimum on iPhone 15
- **Particles**: Max 500 simultaneously
- **Profiling**: Instruments monitoring, optimize with `drawingGroup()`

### Optimization Strategies
- Lazy loading of animations
- GPU acceleration with `.drawingGroup()`
- Animation pooling (reuse particle emitters)
- Conditional rendering (skip off-screen)
- Geometry caching for expensive layouts

### Dark Mode Adaptations
- Shadow opacity: Light (0.15) → Dark (0.4)
- Glow effects: Light (soft gold) → Dark (muted white)
- Particle brightness: Auto-adjusts to mode
- Background blur: Light (10pt) → Dark (20pt)

### Haptic Implementation
- `UIImpactFeedbackGenerator` with prepared states
- Custom `CHHapticPattern` for celebrations
- Budget: Max 3 haptics/second to avoid fatigue
- Prepare in `onAppear`, release in `onDisappear`

### Accessibility Integration
- Read `UIAccessibility.isReduceMotionEnabled` on launch
- In-app settings override system preference
- VoiceOver announcements for non-visual feedback
- Button alternatives for all gesture interactions

## Component Architecture

### AnimationEngine
```swift
struct AnimationEngine {
  // Spring presets
  static let gentleSpring = Animation.spring(response: 0.6, dampingFraction: 0.8)
  static let bouncySpring = Animation.spring(response: 0.5, dampingFraction: 0.6)
  static let snappySpring = Animation.spring(response: 0.3, dampingFraction: 0.9)

  // Timing curves
  static let easeInOut = Animation.easeInOut(duration: 0.3)
  static let quickFade = Animation.easeOut(duration: 0.2)

  // Mode management
  static var currentMode: AnimationMode = .full
}
```

### Core Components

**AnimatedCard**
- Base modifier for card animations
- Handles press states, expansion, parallax
- Configurable shadow depth (mode-aware)
- Hero transition support via namespace matching

**PhysicsNumberCounter**
- Digit-by-digit spring physics
- Configurable speed, spring, font
- Currency formatting with locale
- Optional haptic on milestones

**ParticleEmitter**
- Metal Performance Shaders based
- Presets: gold shimmer, celebration burst, warning pulse
- Color palette adapts to mode
- Automatic cleanup on completion

**GestureInteractionModifier**
- Unified gesture handling (tap, long press, drag, swipe)
- Automatic haptic coordination
- Velocity-aware animations
- Cancellable with elastic snap-back

**HeroTransitionCoordinator**
- Matched geometry effect management
- Z-index layering during transitions
- Multi-element timing coordination
- Fallback transitions when matching fails

## File Structure

```
Code/
├── Animation/
│   ├── Engine/
│   │   ├── AnimationEngine.swift
│   │   ├── AnimationMode.swift
│   │   └── HapticEngine.swift
│   ├── Components/
│   │   ├── AnimatedCard.swift
│   │   ├── PhysicsNumberCounter.swift
│   │   ├── ParticleEmitter.swift
│   │   ├── GestureInteractionModifier.swift
│   │   └── HeroTransitionCoordinator.swift
│   ├── Coordinators/
│   │   ├── DashboardAnimationCoordinator.swift
│   │   ├── TransactionAnimationCoordinator.swift
│   │   ├── GoalsAnimationCoordinator.swift
│   │   └── NavigationAnimationCoordinator.swift
│   └── Shaders/
│       └── ParticleShaders.metal
├── Configuration/
│   └── AnimationSettings.swift
└── Features/ (existing)
```

## Testing Strategy

### Unit Tests
- Animation mode switching logic
- Haptic pattern triggering
- Number counter calculations
- Particle emission parameters
- Accessibility override settings

### UI Tests
- Animation completion timeframes
- Gesture recognizer conflict resolution
- Hero transition visual continuity
- Animation cancellation handling
- Reduced motion mode verification

### Performance Tests
- Instruments profiling (Time Profiler, Core Animation)
- Memory leak detection
- FPS monitoring during heavy sequences
- Battery impact testing
- Thermal state monitoring with throttling

### Visual Regression
- Reference video recording
- Build-to-build comparison
- Snapshot testing for static states
- Light/dark mode coverage

### Device Testing Matrix
- iPhone 15 Pro Max (120Hz primary)
- iPhone 15 (60Hz baseline)
- iPad Pro M2 (large screen)
- Various accessibility text sizes
- Reduced motion enabled

## Error Handling

### Animation Failures
- Graceful fallback if Metal shaders fail
- Instant transitions if FPS drops below 30
- Timeout for stuck animations (3 second max)
- Console logging (debug only)

### Haptic Failures
- Silent failure if engine unavailable
- No visual indication (subtle enhancement only)

## Implementation Roadmap

### Phase 1: Dashboard (Weeks 1-3)
- **Week 1**: Animation engine + base components
- **Week 2**: Balance cards + number counters
- **Week 3**: Charts, particles, polish + testing

### Phase 2: Transactions (Weeks 4-6)
- **Week 4**: Form animations + gesture interactions
- **Week 5**: Hero transitions + success animations
- **Week 6**: Swipe actions + polish + testing

### Phase 3: Goals & Budgets (Weeks 7-9)
- **Week 7**: Progress animations + liquid fills
- **Week 8**: Celebration effects + milestones
- **Week 9**: Budget warnings + polish + testing

### Phase 4: Lists & Navigation (Weeks 10-11)
- **Week 10**: List animations + tab transitions
- **Week 11**: Context menus + final polish

### Phase 5: Integration & Polish (Week 12)
- Full app testing
- Performance optimization
- Accessibility validation
- Sound integration

## Success Criteria

### Performance
- ✅ 120 FPS on iPhone 15 Pro during animations
- ✅ 60 FPS minimum on iPhone 15
- ✅ No memory leaks in particle systems
- ✅ Battery impact < 5% increase during normal use

### User Experience
- ✅ All animations feel intentional and premium
- ✅ Haptics enhance but don't distract
- ✅ Reduced motion mode fully functional
- ✅ VoiceOver users can complete all tasks

### Quality
- ✅ Zero animation-related crashes
- ✅ Animations complete within expected timeframes
- ✅ Dark mode animations match quality of light mode
- ✅ All gesture interactions feel responsive

## Notes

- **Sound Files**: Create/license subtle sound effects for success/celebration moments
- **Metal Shaders**: May need Graphics team support for complex particle systems
- **Device Testing**: Prioritize getting iPhone 15 Pro for ProMotion testing early
- **Accessibility**: User testing with VoiceOver users recommended before final release
