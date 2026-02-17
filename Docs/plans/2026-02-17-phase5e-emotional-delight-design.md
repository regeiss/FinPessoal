# Phase 5E: Emotional Delight - Design Document

**Date**: February 17, 2026
**Phase**: 5E - Emotional Delight
**Dependencies**: Phase 5D (Animation Integration) complete
**Approach**: CelebrationConfig data model + CelebrationFactory

---

## Overview

Phase 5E deepens the emotional connection between users and their financial goals by introducing category-aware celebration experiences and milestone-scaled particle effects. Where Phase 5D integrated animations into screens, Phase 5E makes those animations *personal* — a vacation goal completion feels different from a wedding fund or retirement milestone.

**Goal**: Make goal completion and savings milestones feel uniquely rewarding through themed particle effects and contextual celebration messages.

**Success Criteria**:
- 5 goal categories have distinct, recognisable celebration experiences
- Dashboard milestones scale visually with amount ($1k feels different from $100k)
- All existing call sites remain unbroken (backwards-compatible changes only)
- Full Reduce Motion / Minimal mode / accessibility support maintained
- Build succeeds with zero errors
- 10+ new unit tests passing

---

## Architecture

### Core Principle

Celebrations are driven by data, not code branching. A `CelebrationConfig` struct encapsulates everything a `CelebrationView` needs to render a themed experience. A `CelebrationFactory` maps `GoalCategory` and `MilestoneTier` to configs. Existing call sites pass `nil` config and keep their current behaviour.

### New Types

```swift
// CelebrationConfig.swift

struct CelebrationConfig {
  let style: CelebrationStyle         // .refined / .minimal / .joyful
  let haptic: HapticPattern           // existing haptic patterns
  let duration: Double                // auto-dismiss duration in seconds
  let particleConfig: ParticleConfig? // optional themed particle overlay
  let accentColor: Color              // celebration accent color
  let icon: String                    // SF Symbol name
  let message: String?                // optional contextual message
}

struct ParticleConfig {
  let type: ParticleType
  let intensity: ParticleIntensity
  let colors: [Color]
}

enum ParticleType {
  case confetti   // Vacation
  case sparkle    // House, Education
  case coins      // Dashboard milestones
  case hearts     // Wedding
  case stars      // Retirement
}

enum ParticleIntensity {
  case light      // $1k milestone, small completions
  case medium     // $5k–$25k, standard goal completions
  case epic       // $50k–$100k, major achievements
}
```

```swift
// CelebrationFactory.swift

enum MilestoneTier {
  case small    // $1k
  case medium   // $5k–$10k
  case large    // $25k
  case epic     // $50k–$100k

  static func tier(for amount: Double) -> MilestoneTier {
    switch amount {
    case ..<5000:   return .small
    case ..<25000:  return .medium
    case ..<50000:  return .large
    default:        return .epic
    }
  }
}

class CelebrationFactory {
  static func config(for category: GoalCategory) -> CelebrationConfig
  static func config(for milestone: MilestoneTier) -> CelebrationConfig
}
```

### Updated Signatures (Backwards-Compatible)

```swift
// CelebrationView — new optional config param, defaults to nil
struct CelebrationView: View {
  init(
    config: CelebrationConfig? = nil,   // NEW — themed experience
    style: CelebrationStyle = .refined, // existing (used when config is nil)
    duration: Double = 2.0,             // existing
    haptic: HapticPattern = .achievement, // existing
    onComplete: @escaping () -> Void
  )
}

// ParticleEmitter — new optional particleConfig param
struct ParticleEmitter: View {
  init(
    particleConfig: ParticleConfig? = nil,  // NEW
    // ... existing params still work
  )
}
```

---

## Goal Category Configurations

### Emotional Categories (Custom)

| Category | Particle | Intensity | Colors | Icon | Message |
|----------|----------|-----------|--------|------|---------|
| Vacation | `.confetti` | `.medium` | blue, cyan, yellow | `airplane` | "Bon voyage! 🏖️" |
| House | `.sparkle` | `.medium` | green, gold | `house.fill` | "Welcome home! 🏠" |
| Wedding | `.hearts` | `.medium` | pink, rose, gold | `heart.fill` | "Congratulations! 💍" |
| Retirement | `.stars` | `.medium` | gold, bronze | `star.fill` | "Enjoy your freedom! 🌟" |
| Education | `.sparkle` | `.medium` | purple, blue | `graduationcap.fill` | "Knowledge achieved! 🎓" |

### Standard Categories (Fallback)

| Category | Style | Notes |
|----------|-------|-------|
| Car | `.refined` | Existing behaviour |
| Investment | `.refined` | Existing behaviour |
| Emergency | `.refined` | Existing behaviour |
| Other | `.refined` | Existing behaviour |

---

## Dashboard Milestone Tiers

All milestone tiers use `.coins` particle type with gold/amber/yellow colours. Intensity and message scale with amount:

| Tier | Threshold | Intensity | Duration | Message |
|------|-----------|-----------|----------|---------|
| `.small` | $1k | `.light` | 1.5s | "First milestone! ✨" |
| `.medium` | $5k–$10k | `.medium` | 2.0s | "Growing strong! 💪" |
| `.large` | $25k | `.medium` | 2.0s | "Quarter century! 🌟" |
| `.epic` | $50k–$100k | `.epic` | 3.0s | "Incredible savings! 🏆" |

`DashboardViewModel.checkMilestones()` derives the `MilestoneTier` from the crossed threshold and stores the current config as `@Published var milestoneCelebrationConfig: CelebrationConfig?`. `DashboardScreen` passes this to `CelebrationView`.

---

## Data Flow

### Goal Completion Flow

```
User adds contribution → GoalProgressSheet.addContribution()
  → GoalViewModel.updateGoalProgress()
  → Goal.isCompleted becomes true
  → GoalScreen.onChange(completedGoals.count) fires
  → completedGoal = goals.first(where: { $0.isCompleted && wasActive })
  → config = CelebrationFactory.config(for: completedGoal.category)
  → showGoalCompleteCelebration = true
  → CelebrationView(config: config) overlay renders
  → Auto-dismiss after config.duration
  → showGoalCompleteCelebration = false
```

### Milestone Flow

```
loadDashboardData() completes
  → checkMilestones() called
  → MilestoneTier.tier(for: totalBalance) derived
  → milestoneCelebrationConfig = CelebrationFactory.config(for: tier)
  → showMilestoneCelebration = true
  → DashboardScreen CelebrationView(config: milestoneCelebrationConfig) renders
  → Auto-dismiss → state resets
```

---

## Accessibility

| Concern | Handling |
|---------|---------|
| Reduce Motion | `ParticleConfig` emits 0 particles; `CelebrationView` falls back to simple fade |
| Minimal mode | `particleConfig` ignored; standard refined style used |
| VoiceOver | `accessibilityHidden(true)` on all particle/celebration overlays |
| High Contrast | `accentColor` opacity reduced 50% (built into existing `CelebrationView`) |
| Dynamic Type | Icons use `@ScaledMetric`; messages use system fonts (inherited) |

---

## Files

### New (3 files)

| File | Lines | Purpose |
|------|-------|---------|
| `Animation/Components/AdvancedPolish/CelebrationConfig.swift` | ~80 | Config types: `CelebrationConfig`, `ParticleConfig`, `ParticleType`, `ParticleIntensity` |
| `Animation/Components/AdvancedPolish/CelebrationFactory.swift` | ~100 | `CelebrationFactory` + `MilestoneTier` |
| `FinPessoalTests/Animation/AdvancedPolish/CelebrationFactoryTests.swift` | ~120 | 10 unit tests |

### Modified (5 files)

| File | Change |
|------|--------|
| `CelebrationView.swift` | Add optional `config: CelebrationConfig?` param; render themed content when set |
| `ParticleEmitter.swift` | Accept `ParticleConfig` for type/intensity/colors |
| `GoalScreen.swift` | Track last completed goal; pass `CelebrationFactory.config(for:)` to overlay |
| `DashboardViewModel.swift` | Add `milestoneCelebrationConfig`; use `MilestoneTier` in `checkMilestones()` |
| `DashboardScreen.swift` | Pass `milestoneCelebrationConfig` to `CelebrationView` |

**Total estimated code**: ~300 lines production + ~120 lines tests

---

## Testing Strategy

### Unit Tests — CelebrationFactoryTests (10 tests)

```swift
// Factory returns correct config per category
func testVacationConfigHasConfettiParticles()
func testWeddingConfigHasHeartsParticles()
func testHouseConfigHasSparkleParticles()
func testRetirementConfigHasStarsParticles()
func testEducationConfigHasSparkleParticles()
func testCarConfigUsesRefinedFallback()

// MilestoneTier derivation
func testSmallMilestoneTierAt1000()
func testMediumMilestoneTierAt5000()
func testLargeMilestoneTierAt25000()
func testEpicMilestoneTierAt100000()
```

### Manual Testing Checklist

**Goal completions:**
- [ ] Vacation goal at 100%: confetti burst appears
- [ ] Wedding goal at 100%: hearts particle + "Congratulations!" message
- [ ] House goal at 100%: sparkle + "Welcome home!" message
- [ ] Car goal at 100%: standard refined celebration (no particles)
- [ ] All celebrations auto-dismiss correctly

**Dashboard milestones:**
- [ ] $1k crossed: light coin burst
- [ ] $10k crossed: medium coin burst
- [ ] $100k crossed: epic coin shower (3s duration)
- [ ] Milestone not repeated after first trigger

**Accessibility:**
- [ ] Reduce Motion ON: particles absent, fade only
- [ ] Minimal mode: standard refined, no particles
- [ ] VoiceOver: celebrations don't interrupt announcements

---

## Out of Scope (Phase 5F candidates)

- Device motion parallax (gyroscope)
- Morphing hero transitions
- Gradient themes per budget category
- Seasonal celebration themes
- Analytics on which celebrations users engage with most

---

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| ParticleEmitter not flexible enough for new types | Read ParticleEmitter.swift before writing config; adapt if needed |
| GoalScreen can't identify which goal just completed | Track `previousCompletedGoals` set alongside `previousCompletedCount` |
| CelebrationView backwards-compat breaks | All new params optional with existing defaults |

---

**Status**: Ready for implementation planning
**Next Step**: Create implementation plan using writing-plans skill

---

**Document Version**: 1.0
**Author**: Claude Sonnet 4.5
**Date**: February 17, 2026
**Project**: FinPessoal iOS App — Phase 5E Emotional Delight
