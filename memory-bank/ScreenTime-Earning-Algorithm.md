# ScreenTime Balance – Earning Algorithm (Phase 1)

## Overview
Users earn daily screen time by logging four good habit categories: Sleep, Exercise, Outdoor, and Productive (non-work). Earning is transparent, capped, and gamified with “POWER+ Mode” for additional rewards.

---

## 1. Core Principles

- **Standard Daily Maximum:** 2 hours (120 mins) of earned screen time per day.
- **POWER+ Mode Bonus:** 30 min extra if user achieves recommended thresholds in any 3 of the 4 categories (max possible per day: 2.5 hrs / 150 min).

---

## 2. Category Earning Logic

### **A. Sleep (Penalty and Reward)**
| Hours Slept           | Screen Time Effect     |
|-----------------------|-----------------------|
| Less than 6 hours     | ‒20 min penalty       |
| 6 to <7 hours         | +20 min               |
| 7 to 9 hours          | +30 min               |
| Greater than 9 hours  | ‒20 min penalty       |

- Only one sleep log per day is counted.
- Penalty applies to total daily screen time earned (floor at 0 min, not negative).

### **B. Exercise**
- **Earning Rate:** 1 hour exercise = 20 min screen time.
- **Caps:** Up to 2 hours/day credit (max: +40 min).
- **Log Method:** Manual or in-app stopwatch (cannot overlap with another category).

### **C. Outdoor**
- **Earning Rate:** 1 hour outdoor = 15 min screen time.
- **Caps:** Up to 2 hours/day credit (max: +30 min).
- **Log Method:** Manual or in-app stopwatch (cannot overlap with another category).

### **D. Productive (Non-work)**
- **Earning Rate:** 1 hour productive focus (non-paid/career) = 10 min screen time.
- **Caps:** Up to 4 hours/day credit (max: +40 min).
- **Log Method:** Manual or in-app stopwatch (cannot overlap with another category).

**Note:** Only one category can accrue “live” time at a time—no simultaneous stopwatches.

---

## 3. POWER+ Mode (Gamified Bonus)
- If a user logs recommended minimums in any 3 out of 4 categories:
    - Sleep: 7+ hr
    - Exercise: 45+ min
    - Outdoor: 30+ min
    - Productive: 2+ hr
- Unlocks **POWER+ Mode:** +30 minutes additional screen time (single-day bonus).
- Badge and banner shown in UI to reinforce positive streaks.

---

## 4. Daily Screen Time Summary Calculation

- Calculate screen time contributed from each category as above.
- Apply sleep penalty or reward based on sleep range.
- **Total daily screen time earned = (Exercise + Outdoor + Productive + Sleep reward/penalty)**
- If POWER+ Mode unlocked, **add 30 min**.
- **Apply max daily cap of 2 hr (120 min), except with POWER+ Mode where cap is 2.5 hr (150 min)**.
- If penalties push total below zero, floor at 0 min for the day.

---

## 5. User Experience
- All progress and earned/penalized minutes are live and visible in the app UI.
- “POWER+ Mode” (gamified bonus) is celebrated with a badge and highlight.
- Algorithm rationale and science references are made available via info/help page for transparency and trust.

---

_This algorithm is locked for Phase 1. It may evolve based on actual user feedback and behavior analytics post-launch._
