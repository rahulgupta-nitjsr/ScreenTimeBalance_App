# Product Requirements Document (PRD) – ZenScreen

## 1. Problem Statement
Adults and young professionals are struggling with excessive smartphone use, leading to reduced productivity, impaired sleep, and imbalanced lifestyles. Existing solutions focus on punitive controls or stats, often feeling restrictive or “parental.” There is a clear opportunity for a positive, habit-forming screen time management tool that rewards good behaviors with phone time, with a modern, minimalist user experience.

## 2. Target Users & Stakeholders
- **Primary:** Young adults (students and professionals, ages 18–35) seeking positive, empowering ways to manage screen habits.
- **Secondary:** General adults interested in wellness/digital balance.
- **Key Stakeholders:** End users, founding team, potential wellness partners.

## 3. Goals & Objectives
- Enable users to balance screen time with healthy life habits through motivation and rewards.
- Deliver an enjoyable, frictionless, science-based experience.
- Achieve technical & process mastery for the founding team.

## 4. Success Metrics (Phase 1)
- App fully functional & installable on founder’s device.
- Live on Google Play.
- 1,000 installs in month 1 post-launch.
- 25%+ early users report actual screen/life balance improvement.
- Full dev/launch learning goal for founder achieved.

## 5. High-Level Features (Phase 1)
- Manual & stopwatch entry for 4 tracked categories: Sleep, Outdoor, Productive (Non-work), Exercise.
- **POWER+ Mode:** Achieving any 3 of 4 daily health targets unlocks a badge and additional 30 minutes screen time ("gamified mode").
- Transparent, science-backed earning algorithm with clear proportional rates and category caps (see below and [ScreenTime-Earning-Algorithm.md](./ScreenTime-Earning-Algorithm.md)).
- Live, intuitive visualization of good habits vs. earned screen time (with liquid glass minimal UI).
- Clean onboarding, account creation (sync/history; no ads or trackers in phase 1).
- **Complete UI/UX Design System:** 6 fully designed screens with interactive wireframes, design system, and implementation guidelines (see [Product-Design.md](./Product-Design.md) and [Design Assets](../designs/README.md)).

## 6. Core Algorithm Reference & Constraints
Full, detailed logic and rationale in [ScreenTime-Earning-Algorithm.md](./memory-bank/ScreenTime-Earning-Algorithm.md).

**Summary of Algorithmic Constraints:**
- **Max daily screen time:** 2 hrs (120 min); up to 2.5 hrs (150 min) with POWER+ Mode.
- **Earning rates (per category):**  
  - Sleep: 1 hr = 25 min (max 9 hr/night)
  - Exercise: 1 hr = 20 min (max 2 hr)
  - Outdoor: 1 hr = 15 min (max 2 hr)
  - Productive (non-work): 1 hr = 10 min (max 4 hr)
- **POWER+ Mode unlocked by 3 of 4 goals:**
  - Sleep ≥ 7 hr
  - Exercise ≥ 45 min
  - Outdoor ≥ 30 min
  - Productive ≥ 2 hr
- **Strict: Only one activity at a time is tracked in “live” stopwatch/manual mode to prevent double-counting.**

## 7. Constraints (non-algorithmic)
- Zero/minimum cost tools, stack, and app publishing.
- MVP launch on Android.
- No advertisements, analytics, third-party trackers in v1.
- No auto sensor data (MVP is pure manual + stopwatch).

## 8. Out-of-Scope (Non-goals for Phase 1)
- AI/ML-based analytics or habits prediction.
- Monetization/ads.
- Family/parental control.
- Sensor-driven data import.

## 9. Mapping Features to User/Business Goals

| Feature                                  | User/Business Goal Supported                              |
|-------------------------------------------|-----------------------------------------------------------|
| Manual/stopwatch habit entry              | Empowerment, positive control, lowest friction            |
| Science-based screen time algorithm       | Motivation, trust, clarity, wellness                      |
| POWER+ Mode gamification                  | Motivation, retention, "badge effect"                     |
| Visualization (Good/Bad)                  | User motivation, progress feedback, fun UX                |
| Minimalist/liquid glass UI                | Modern feel, engagement, brand identity                   |
| Account creation/history                  | Retention, sync, user progress                            |
| Complete design system & wireframes       | Development efficiency, user testing, stakeholder alignment |

## 10. Dependencies & Enhanced Risk Assessment
- **Algorithm Balance:** Ensuring POWER+ Mode is motivating but not exploitable; algorithms must be transparent, fair, and science-based.
- **Manual Input Friction:** Excessive manual entry may reduce usage/adoption—live user feedback is crucial.
- **Algorithm Validation:** Early, ongoing review of time/points earned to prevent abuse and ensure engagement.
- Store/Play Store policies must be followed (wellness claims, privacy, etc.), else approval risk.
