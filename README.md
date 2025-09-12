# ZenScreen

A mobile app that helps users earn screen time through positive habit building, using a science-based algorithm and thoughtful design.

> *Transforming screen time guilt into positive habit building through gamification and behavioral science.*

## Project Overview

ZenScreen is a mobile app that allows users to **earn screen time** through positive habit building. Instead of restricting phone usage, the app motivates users to engage in healthy activities (sleep, exercise, outdoor time, productive work) to unlock screen time rewards using a science-backed algorithm.

**Key Innovation:** Positive reinforcement over punishment - users are empowered, not restricted.

---

## Product Development Process

This project follows a structured product development approach:

### Phase 1: Foundation & Strategy ✅
- [x] **Market Research & Competitive Analysis**
- [x] **Problem Statement Definition**
- [x] **Target User Persona Development**
- [x] **Product-Market Fit Analysis**
- [x] **Success Metrics Definition**

### Phase 2: Product Requirements ✅
- [x] **Comprehensive Product Requirements Document (PRD)**
- [x] **Feature Prioritization & MVP Scoping**
- [x] **Technical Constraints & Architecture Planning**
- [x] **Algorithm Design & Scientific Validation**
- [x] **Privacy & Compliance Framework**

### Phase 3: Design & User Experience ✅
- [x] **Design System Creation**
- [x] **User Journey Mapping**
- [x] **Interactive Wireframe Development**
- [x] **Visual Design & Branding**
- [x] **Accessibility & Responsive Design**

### Phase 4: Feature Specification ✅
- [x] **Detailed Feature Documentation (20+ Features)**
- [x] **User Stories & Acceptance Criteria**
- [x] **Technical Requirements & Performance Metrics**
- [x] **Edge Case Analysis & Error Handling**
- [x] **Data Models & API Specifications**

### Phase 5: Technical Architecture ✅
- [x] **System Architecture Design**
- [x] **Database Schema & Relationships**
- [x] **Security & Privacy Implementation**
- [x] **Cross-Platform Development Strategy**
- [x] **Testing & Quality Assurance Framework**

### Phase 6: Implementation Planning ✅
- [x] **Feature-Driven Development Strategy**
- [x] **Comprehensive Implementation Roadmap**
- [x] **Mobile App Development Guide**
- [x] **Quality Gates & Success Criteria**
- [x] **Automated Testing Framework**

---

## UI/UX Design

### Design System
The app features a liquid glass aesthetic with a minimalist interface and positive psychology colors.

<div align="center">

### App Screenshots

| Onboarding | Home Dashboard | Activity Logging |
|------------|----------------|------------------|
| ![Welcome Screen](designs/Wireframes/1%20Start_Screen/screen.png) | ![Home Screen](designs/Wireframes/2%20Home_Screen/Home_screen.png) | ![Log Screen](designs/Wireframes/3%20Log_Screen/Log_screen.png) |
| Clean welcome experience with value proposition | Earned time display with POWER+ Mode status | Timer and manual entry for habit tracking |

| Progress Tracking | User Profile | How It Works |
|------------------|--------------|--------------|
| ![Progress Screen](designs/Wireframes/4%20Progress_Screen/Progress_screen.png) | ![Profile Screen](designs/Wireframes/5%20Profile%20Screen/Profile_screen.png) | ![How It Works](designs/Wireframes/6%20How_It_Works_Screen/How_it_Works_screen.png) |
| Visual progress with celebration elements | User management and app settings | Educational content explaining algorithm |

</div>

### Design Approach
- **Primary Color**: Robin Hood Green (#38e07b) - chosen for its association with growth and achievement
- **Typography**: Spline Sans for readability and modern feel
- **Effects**: Liquid glass with backdrop blur for visual depth
- **Icons**: Material Design for consistency
- **Layout**: Mobile-first responsive design

---

## Algorithm & Gamification

### Science-Based Earning System
The app uses a transparent, research-backed algorithm to convert healthy habits into screen time:

```
🌙 Sleep: 1 hour = 25 min screen time (optimal: 7-9 hours)
💪 Exercise: 1 hour = 20 min screen time (max: 2 hours/day)
🌳 Outdoor: 1 hour = 15 min screen time (max: 2 hours/day)
📚 Productive: 1 hour = 10 min screen time (max: 4 hours/day)
```

### POWER+ Mode
Users can unlock 30 bonus minutes by achieving 3 of 4 daily health goals
- Creates motivation through achievement
- Celebrates positive behavior
- Encourages consistent habit formation

### Behavioral Design
- **Positive Reinforcement**: Rewards over restrictions
- **Transparency**: Clear earning rates and algorithm explanation
- **Flexibility**: Manual entry + timer options
- **Honest Tracking**: Prevents gaming through smart constraints

---

## Technical Architecture

### Technology Stack
```
Frontend: Flutter (Cross-platform)
Database: SQLite (Local) + Firebase Firestore (Cloud)
Authentication: Firebase Auth
Backend: Firebase (Free Tier)
State Management: Riverpod (Modern, Type-Safe)
Design Framework: Material Design 3 + Custom Liquid Glass Components
Testing: Flutter Test + Comprehensive Automated Testing Framework
```

### Key Technical Features
- **Offline-First Architecture**: Full functionality without internet
- **Real-time Sync**: Seamless data synchronization across devices
- **Privacy by Design**: Local-first with encrypted cloud backup
- **Performance Optimized**: <3s startup, <100ms response times
- **Cross-Platform Ready**: Single codebase for Android and iOS

---

## Project Scope

### Documentation
- 12 comprehensive documents covering requirements, design, architecture, and implementation
- 6 interactive wireframes with HTML/CSS prototypes
- Detailed feature specifications with acceptance criteria
- Complete technical architecture and implementation roadmap
- Comprehensive automated testing framework (180 test cases)
- Privacy-compliant framework for data handling
- Complete design system with implementation guidelines

### Development Approach
- **User-Centered Design**: Based on research and personas
- **Feature-Driven Development**: 16 features across 8 iterations with clear acceptance criteria
- **Test-Driven Development**: 180 automated test cases with 90% coverage requirement
- **Quality Gates**: 95% pass rate required before feature completion
- **Scalable Architecture**: Future-ready with cross-platform capabilities

---

## Project Structure

```
ZenScreen/
├── memory-bank/                    # 📚 Comprehensive Documentation
│   ├── Product-Requirements-Document.md
│   ├── Features.md                 # 16 detailed feature specifications
│   ├── Product-Design.md           # Complete design system
│   ├── Architecture.md             # Technical architecture & patterns
│   ├── Tech-Stack.md               # Technology decisions & rationale
│   ├── Implementation-plan.md      # Feature-driven development roadmap
│   ├── Mobile-App-Development-Guide.md # Complete development guide
│   ├── Testing-Plan.md             # Automated testing framework
│   ├── ScreenTime-Earning-Algorithm.md
│   ├── Privacy-Policy-Framework.md
│   └── Progress.md                 # Development tracking
├── tests/                          # 🧪 Comprehensive Testing Framework
│   ├── README.md                   # Testing workflow & processes
│   ├── test-cases.md               # 180 automated test cases
│   ├── TESTING-ARTIFACTS-SUMMARY.md
│   ├── VALIDATION-REPORT.md        # Testing framework validation
│   ├── data/                       # Test data & configurations
│   ├── reports/                    # Failure reports & analysis
│   └── logs/                       # Test execution logs
├── designs/                        # 🎨 UI/UX Design Assets
│   ├── Wireframes/                 # Interactive prototypes
│   ├── flows/                      # User journey mapping
│   └── README.md                   # Design documentation
├── Public/                         # 🌐 Public-facing assets
├── .github/                        # CI/CD and contribution guidelines
└── src/                            # 💻 Source code (development phase)
```

---

## Problem & Solution

### Problem
Most screen time apps are punitive and restrictive, creating guilt around screen time without providing positive alternatives. Users struggle to maintain healthy digital habits.

### Solution
An earning-based screen time management approach that uses positive reinforcement rather than restriction. The app is built on behavioral science principles and wellness research.

### Target Users
- Primary: Young adults (18-35) seeking digital wellness
- Secondary: Professionals wanting better work-life balance

---

## Goals & Metrics

### Project Goals
- ✅ Complete product development process from concept to implementation-ready specifications
- ✅ Create comprehensive documentation, architecture, and testing framework
- ✅ Establish feature-driven development methodology with quality gates
- 🎯 Develop functional MVP with 16 core features
- 🎯 Launch on Google Play Store with automated testing pipeline
- 🎯 Achieve 1,000 installs in first month
- 🎯 25%+ of users report improved digital wellness

---

## Future Roadmap

### Phase 2: Enhanced Features
- **Weekly/Monthly Analytics**: Long-term habit trend analysis
- **Social Features**: Share progress and compete with friends
- **Advanced Customization**: Personalized earning rates and goals
- **Habit Streaks**: Achievement system and milestone celebrations

### Phase 3: AI & Integration
- **Smart Insights**: AI-powered habit recommendations
- **Sensor Integration**: Automatic tracking via device sensors
- **Third-Party APIs**: Integration with fitness and productivity apps
- **Premium Features**: Advanced analytics and coaching

---

## Documentation

---

### Core Documents
- **[Product Requirements](memory-bank/Product-Requirements-Document.md)** - Complete PRD with market analysis
- **[Feature Specifications](memory-bank/Features.md)** - 16 detailed feature specifications
- **[Technical Architecture](memory-bank/Architecture.md)** - System architecture and patterns
- **[Technology Stack](memory-bank/Tech-Stack.md)** - Technology decisions and rationale
- **[Implementation Plan](memory-bank/Implementation-plan.md)** - Feature-driven development roadmap
- **[Mobile Development Guide](memory-bank/Mobile-App-Development-Guide.md)** - Complete development guide
- **[Design System](memory-bank/Product-Design.md)** - UI/UX specifications and guidelines
- **[Algorithm Design](memory-bank/ScreenTime-Earning-Algorithm.md)** - Science-based earning system

### Testing & Quality Assurance
- **[Testing Framework](tests/README.md)** - Comprehensive testing workflow and processes
- **[Test Cases](tests/test-cases.md)** - 180 automated test cases with quality gates
- **[Testing Plan](memory-bank/Testing-Plan.md)** - Automated testing strategy and methodology
- **[Validation Report](tests/VALIDATION-REPORT.md)** - Testing framework validation results

### Design Assets
- **[Design Documentation](designs/README.md)** - Design system and implementation guidelines
- **[Interactive Wireframes](designs/Wireframes/)** - HTML/CSS prototypes for all screens
- **[User Journey](designs/flows/)** - User flow mapping and analysis

### Compliance & Privacy
- **[Privacy Framework](memory-bank/Privacy-Policy-Framework.md)** - Data handling and compliance framework
- **[Progress Tracking](memory-bank/Progress.md)** - Development methodology and progress

---

---

*This project demonstrates a structured approach to product development, from initial concept to implementation-ready specifications. The focus is on user-centered design, behavioral science, and creating positive experiences around digital wellness.*