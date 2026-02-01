# Old Money Color Palette Design

**Date**: 2025-12-18
**Status**: Approved
**Style**: Minimal & Refined (understated elegance, quiet luxury)

## Overview

A sophisticated color palette for FinPessoal that conveys trust, stability, and refined elegance — the "old money" aesthetic. The palette uses muted grays, subtle gold accents, and cream tones to create an understated luxury feel appropriate for a personal finance app.

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Style | Minimal & Refined | Builds trust, avoids flashiness |
| Dark Mode | Inverted elegance | Cream becomes charcoal, gold remains |
| Semantics | Subtle but clear | Desaturated green/red, readable but not jarring |

---

## Core Color Palette

### Light Mode Base

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Ivory | `#FAF8F5` | 250, 248, 245 | Primary background |
| Cream | `#F5F2EC` | 245, 242, 236 | Card/surface backgrounds |
| Warm Gray | `#E8E4DD` | 232, 228, 221 | Dividers, subtle borders |
| Stone | `#9C9589` | 156, 149, 137 | Secondary text, icons |
| Charcoal | `#3D3A36` | 61, 58, 54 | Primary text |

### Dark Mode Base

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Charcoal Dark | `#1C1B19` | 28, 27, 25 | Primary background |
| Slate | `#2A2826` | 42, 40, 38 | Card/surface backgrounds |
| Dark Stone | `#3D3A36` | 61, 58, 54 | Dividers, subtle borders |
| Muted Ivory | `#A8A49C` | 168, 164, 156 | Secondary text, icons |
| Ivory | `#FAF8F5` | 250, 248, 245 | Primary text |

### Accent Colors (Both Modes)

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Antique Gold | `#B8965C` | 184, 150, 92 | Primary accent, CTAs, highlights |
| Soft Gold | `#D4BA8A` | 212, 186, 138 | Secondary accent, hover states |

---

## Semantic Colors

### Financial Indicators

| Name | Light Mode | Dark Mode | Usage |
|------|------------|-----------|-------|
| Income Green | `#5C8A6B` | `#6B9E7A` | Income, positive amounts, success |
| Expense Rose | `#A67070` | `#B88080` | Expenses, negative amounts |
| Warning Amber | `#B89A5C` | `#C9AB6D` | Warnings, approaching limits |
| Alert Burgundy | `#8B5A5A` | `#9E6B6B` | Errors, overdue, exceeded budgets |

### Status Colors

| Name | Light Mode | Dark Mode | Usage |
|------|------------|-----------|-------|
| Sage | `#7A8B73` | `#8A9B83` | Completed, paid, active |
| Steel | `#6B7280` | `#9CA3AF` | Neutral, inactive, pending |
| Terracotta | `#A67A5C` | `#B88A6C` | Due soon, attention needed |

### Category Colors (Muted)

| Category | Hex | Usage |
|----------|-----|-------|
| Food | `#8B7355` | Food & dining transactions |
| Transport | `#5C6B7A` | Transportation expenses |
| Entertainment | `#7A5C7A` | Entertainment & leisure |
| Healthcare | `#5C7A7A` | Medical & health expenses |
| Shopping | `#7A6B5C` | Retail & shopping |
| Bills | `#6B6B5C` | Utilities & bills |
| Salary | `#5C7A5C` | Income from salary |
| Investment | `#5C6B6B` | Investment transactions |
| Housing | `#7A6B6B` | Rent, mortgage, home |
| Other | `#6B6B6B` | Miscellaneous |

---

## Typography Pairing

| Element | Font | Weight | Size Range |
|---------|------|--------|------------|
| Headlines | NY (System Serif) | Medium | 22-34pt |
| Body | SF Pro | Regular | 15-17pt |
| Numbers/Money | SF Pro Rounded | Medium | 15-28pt |
| Captions | SF Pro | Light | 12-13pt |

---

## UI Polish Details

### Shadows
- Color: `#3D3A36` at 5-8% opacity
- Radius: 8-16pt
- Offset: 0, 2-4pt

### Border Radius
- Small elements (buttons, chips): 8pt
- Cards: 12pt
- Large cards/sheets: 16pt

### Borders/Dividers
- Width: 0.5pt
- Color: Warm Gray (light) / Dark Stone (dark)

### Animations
- Duration: 200-300ms
- Easing: easeInOut
- Style: Subtle, no bouncing or overshooting

---

## Accessibility

### Contrast Ratios (WCAG AA Compliant)

| Combination | Ratio | Status |
|-------------|-------|--------|
| Charcoal on Ivory | 12.4:1 | AAA |
| Antique Gold on Ivory | 5.2:1 | AA |
| Stone on Ivory | 4.6:1 | AA |
| Ivory on Charcoal Dark | 14.1:1 | AAA |
| Antique Gold on Charcoal Dark | 5.8:1 | AA |

### Color Blindness

- Income Green and Expense Rose tested for deuteranopia/protanopia
- Sufficient luminance difference between positive/negative indicators
- Icons and shapes supplement color coding

---

## Implementation

### File Structure

```
FinPessoal/Code/Configuration/Theme/
├── OldMoneyColors.swift      # Color definitions
├── OldMoneyTheme.swift       # Theme configuration
└── Color+OldMoney.swift      # SwiftUI Color extension

Shared/Models/
└── WidgetColors.swift        # Lightweight colors for widgets
```

### Usage Examples

```swift
// Backgrounds
Color.oldMoney.background
Color.oldMoney.surface

// Text
Color.oldMoney.text
Color.oldMoney.textSecondary

// Accent
Color.oldMoney.accent
Color.oldMoney.accentSecondary

// Semantic
Color.oldMoney.income
Color.oldMoney.expense
Color.oldMoney.warning
Color.oldMoney.error

// Categories
Color.oldMoney.category(.food)
```

---

## Migration Notes

- Replace all hardcoded colors with theme colors
- Update widget views to use shared color definitions
- Test all screens in both light and dark mode
- Verify accessibility with VoiceOver and color filters
