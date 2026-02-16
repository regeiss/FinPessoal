# Phase 5A: Charts QA Checklist

**Date:** 2026-02-15
**Phase:** 5A - Charts & Data Visualization
**Status:** In Progress
**Tester:** Manual QA Required

## Overview

This checklist covers all manual QA requirements for Phase 5A chart components. Complete each section and mark items as ✅ (Pass), ❌ (Fail), or ⚠️ (Issue Found).

---

## 1. PieDonutChart Component

### Animation & Timing
- [ ] Initial reveal animation is smooth (300ms duration)
- [ ] Segments appear with 50ms stagger (cascading effect)
- [ ] Animation uses easeInOut curve (not linear)
- [ ] No jarring transitions or jumps
- [ ] Animations complete fully without interruption

### Gestures & Interactions
- [ ] **Tap**: First tap selects segment (5% scale increase)
- [ ] **Tap**: Second tap on same segment deselects it
- [ ] **Tap**: Tapping different segment switches selection
- [ ] **Tap**: Tapping empty area deselects current selection
- [ ] **Drag/Scrub**: Dragging across chart highlights segments continuously
- [ ] **Drag/Scrub**: Haptic feedback on each segment hover
- [ ] **Long Press**: 500ms hold triggers (future: detail sheet)
- [ ] **Long Press**: Haptic impact (medium) on trigger

### Visual Feedback
- [ ] Selected segment scales to 1.05x (subtle, not dramatic)
- [ ] Scale animation uses gentle spring (no bounce)
- [ ] Callout appears above selected segment
- [ ] Callout displays label, percentage, and value
- [ ] Callout positions correctly for all segment positions
- [ ] Callout doesn't overlap with chart
- [ ] Callout fades in/out smoothly (200ms)

### Haptic Feedback
- [ ] Selection haptic fires on tap
- [ ] Selection haptic fires on drag hover (not spammy)
- [ ] Medium impact haptic on long press
- [ ] **Reduce Motion**: Haptics disabled when enabled

### Accessibility - VoiceOver
- [ ] Chart has descriptive label ("Donut chart with X segments")
- [ ] Each segment is navigable with swipe left/right
- [ ] Segment announces: label, percentage, value
- [ ] Double-tap selects segment (same as visual tap)
- [ ] Selected state announced properly
- [ ] Callout is hidden from VoiceOver (no duplication)
- [ ] No accessibility warnings in console

### Accessibility - Dynamic Type
- [ ] Chart size remains fixed (doesn't scale with text)
- [ ] Callout text scales with user preference
- [ ] Callout capped at .xxxLarge (no layout breakage)
- [ ] Text uses minimumScaleFactor(0.8) gracefully
- [ ] Labels readable at all text sizes

### Accessibility - High Contrast
- [ ] 3px stroke appears around segments in High Contrast mode
- [ ] Stroke color is .primary (adapts to theme)
- [ ] Segments remain distinguishable
- [ ] Color contrast meets WCAG AA (4.5:1 minimum)

### Appearance Modes
- [ ] Works correctly in Light mode
- [ ] Works correctly in Dark mode
- [ ] Colors adapt properly to theme
- [ ] Callout background uses .ultraThinMaterial
- [ ] Shadow visibility appropriate in both modes

### Edge Cases
- [ ] **Empty data**: Shows empty state with message
- [ ] **Single segment**: Displays 100% circle correctly
- [ ] **Many segments** (10+): Labels don't overlap
- [ ] **Small percentages** (<5%): Segments still visible
- [ ] **Zero values**: Filtered out before rendering

---

## 2. BarChart Component

### Animation & Timing
- [ ] Initial reveal animation is smooth (300ms duration)
- [ ] Bars grow with 50ms stagger (left to right)
- [ ] Animation uses easeInOut curve
- [ ] Heights animate from 0 to target value
- [ ] Opacity fades from 0 to 1 during reveal

### Gestures & Interactions
- [ ] **Tap**: Tapping bar selects it (5% Y-scale increase)
- [ ] **Tap**: Second tap on same bar deselects it
- [ ] **Tap**: Tapping different bar switches selection
- [ ] **Tap**: Selection haptic fires on each tap

### Visual Feedback
- [ ] Selected bar scales vertically to 1.05x
- [ ] Scale anchor is bottom (bar grows upward)
- [ ] Callout appears above selected bar
- [ ] Callout displays label and value
- [ ] Callout positions correctly for all bars
- [ ] Bar labels truncate gracefully if too long

### Haptic Feedback
- [ ] Selection haptic fires on bar tap
- [ ] **Reduce Motion**: Haptics disabled when enabled

### Accessibility - VoiceOver
- [ ] Each bar has label and value announced
- [ ] Double-tap selects bar
- [ ] Selected state announced
- [ ] Navigation between bars works smoothly
- [ ] No accessibility warnings

### Accessibility - Dynamic Type
- [ ] Bar heights remain fixed
- [ ] Labels scale with user preference
- [ ] Labels use minimumScaleFactor(0.8)
- [ ] Callout text scales properly
- [ ] Callout capped at .xxxLarge

### Accessibility - High Contrast
- [ ] 3px stroke appears around bars in High Contrast mode
- [ ] Stroke color is .primary
- [ ] Bars remain distinguishable

### Appearance Modes
- [ ] Works correctly in Light mode
- [ ] Works correctly in Dark mode
- [ ] Bar colors adapt to theme

### Edge Cases
- [ ] **Empty data**: Shows empty state
- [ ] **Single bar**: Displays correctly
- [ ] **Many bars** (12+): Spacing adjusts appropriately
- [ ] **Zero values**: Bar height is 0 (not shown)
- [ ] **Max value**: Bar reaches full height

---

## 3. Data Transitions

### Period Change Morphing
- [ ] Changing period triggers smooth morph (not instant replace)
- [ ] Old values fade out (150ms)
- [ ] Shapes morph to new proportions (300ms spring)
- [ ] New labels fade in after delay (150ms, +200ms delay)
- [ ] No flicker or visual glitches during transition
- [ ] Transition works for all period changes (This Month → Last Month, etc.)

### Loading States
- [ ] Skeleton shimmer appears during data load
- [ ] **PieDonut**: Circular skeleton with shimmer animation
- [ ] **BarChart**: 6 skeleton bars with random heights
- [ ] Shimmer gradient animates in Full mode
- [ ] Static gradient in Reduced mode
- [ ] Solid placeholder in Minimal mode
- [ ] Smooth crossfade from skeleton to chart (easeInOut)
- [ ] Success haptic fires when data loads

### Error States
- [ ] Error view displays on data failure
- [ ] Error icon shown (exclamationmark.triangle.fill)
- [ ] Error message is clear and helpful
- [ ] Retry button is present and functional
- [ ] Retry button reloads data correctly
- [ ] Error state appears instantly (no animation for errors)
- [ ] Warning haptic fires on error

---

## 4. Integration Tests

### CategorySpendingView (PieDonutChart)
- [ ] Chart displays in CategorySpendingView
- [ ] Uses donut style with 60% inner radius
- [ ] Chart size is 250x250
- [ ] Data updates when period changes
- [ ] Loading skeleton appears during fetch
- [ ] Empty state shows when no data
- [ ] All interactions work in context

### MonthlyTrendsView (BarChart)
- [ ] Chart displays in MonthlyTrendsView
- [ ] Shows 6 months of data
- [ ] Chart height is 200px (total layout 250px)
- [ ] Data updates when period changes
- [ ] Loading skeleton shows 6 bars
- [ ] Empty state shows when no data
- [ ] All interactions work in context

### BudgetPerformanceView (BarChart)
- [ ] Chart displays in BudgetPerformanceView
- [ ] Shows budget vs actual spending
- [ ] Data updates correctly
- [ ] All interactions work in context

---

## 5. Accessibility Comprehensive

### VoiceOver Navigation
- [ ] All charts announce title as header
- [ ] Total/summary announced before segments/bars
- [ ] Swipe right/left navigates between elements
- [ ] Magic Tap announces summary statistics
- [ ] Rotor can jump to "Chart Values" category
- [ ] No duplicate announcements
- [ ] No accessibility elements overlap

### Reduce Motion
- [ ] Initial reveal is instant (no animations)
- [ ] Data transitions are instant
- [ ] Selection uses opacity only (no scale)
- [ ] Skeleton is static placeholder
- [ ] Haptics are disabled
- [ ] No springs or bounces

### High Contrast
- [ ] All strokes appear (3px width)
- [ ] Contrast increased appropriately
- [ ] Elements remain distinguishable
- [ ] No reliance on color alone

### Dynamic Type
- [ ] Text scales from Small to xxxLarge
- [ ] Layout doesn't break at xxxLarge
- [ ] minimumScaleFactor prevents extreme scaling
- [ ] Charts remain usable at all sizes

### Color Contrast
- [ ] All chart colors meet WCAG AA (4.5:1)
- [ ] Text on backgrounds meets contrast requirements
- [ ] Callout text is readable
- [ ] Works in both Light and Dark mode

---

## 6. Performance

### Animation Performance
- [ ] **60fps** maintained during all animations
- [ ] No dropped frames during reveal
- [ ] No lag during selection transitions
- [ ] Smooth data morphing transitions
- [ ] No stuttering or jank

### Gesture Performance
- [ ] No lag on tap recognition
- [ ] Drag/scrub is responsive
- [ ] Hit testing is accurate
- [ ] No delay before haptic feedback
- [ ] Multiple rapid taps don't cause issues

### Memory
- [ ] No memory leaks during chart lifecycle
- [ ] Memory stable during data updates
- [ ] Memory doesn't grow on repeated transitions
- [ ] Animation tasks are cancelled properly on disappear

### Device Testing
- [ ] **iPhone SE 2020**: Smooth performance
- [ ] **iPhone 17 Pro Max**: Smooth performance
- [ ] **iPad**: Works in all orientations and split views
- [ ] **Simulator**: No simulator-only bugs

### Large Datasets
- [ ] Works with 20+ chart segments
- [ ] Works with 12 months of bar data
- [ ] No performance degradation with more data
- [ ] Rendering stays under 16ms (60fps)

---

## 7. Edge Cases & Error Handling

### Data Edge Cases
- [ ] Empty array: Shows empty state
- [ ] Null/undefined data: Handled gracefully
- [ ] Single item: Displays correctly
- [ ] Very large numbers: Formatted properly (K/M suffixes)
- [ ] Very small percentages: Still visible
- [ ] Negative values: Handled or filtered
- [ ] NaN/Infinity: Doesn't crash

### UI Edge Cases
- [ ] iPad Split View: Charts adapt correctly
- [ ] Landscape orientation: Charts remain proportional
- [ ] Narrow width: Callout positions adjust
- [ ] Extreme zoom levels: Everything readable
- [ ] Rotation during animation: No crashes

### Network Edge Cases
- [ ] Slow network: Loading state shows
- [ ] Network error: Error state with retry
- [ ] Timeout: Error state appears
- [ ] Data changes during animation: Cancels gracefully

---

## 8. Regression Testing

### Previous Features Still Work
- [ ] Old Money color palette still applied
- [ ] AnimationSettings modes work (Full/Reduced/Minimal)
- [ ] HapticEngine still functional
- [ ] SkeletonView still works
- [ ] Other reports views unaffected
- [ ] Navigation still works
- [ ] Dashboard stats cards unaffected

---

## Test Results Summary

**Total Items**: ~150 checklist items
**Passed**: ___
**Failed**: ___
**Issues**: ___

### Critical Issues Found
_List any blocking issues that must be fixed before release:_

1.
2.
3.

### Non-Critical Issues
_List issues that can be addressed in future iterations:_

1.
2.
3.

### Performance Metrics
- Average FPS during animations: ___
- Memory usage (idle): ___
- Memory usage (animating): ___
- Slowest animation duration: ___

---

## Sign-Off

- [ ] All critical issues resolved
- [ ] All accessibility requirements met
- [ ] Performance targets achieved (60fps minimum)
- [ ] Works on all target devices
- [ ] Ready for production

**QA Tester**: _______________
**Date**: _______________
**Status**: ⬜ Approved / ⬜ Needs Work
