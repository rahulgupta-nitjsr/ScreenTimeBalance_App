# ScreenTime Balance - Product Design Documentation

## Overview
This document provides comprehensive design specifications for the ScreenTime Balance mobile app, including visual design system, user interface components, interaction patterns, and design implementation guidelines.

**Related Documents:**
- [Design Assets](../designs/README.md) - Complete wireframes and visual assets
- [Features.md](./Features.md) - Detailed feature specifications
- [Product Requirements Document](./Product-Requirements-Document.md) - High-level requirements
- [ScreenTime Earning Algorithm](./ScreenTime-Earning-Algorithm.md) - Algorithm specifications

---

## 1. Design Philosophy & Principles

### 1.1 Core Design Philosophy
**"Positive Reinforcement Through Beautiful Simplicity"**

The design emphasizes:
- **Empowerment over restriction**: Users earn rewards rather than face punishments
- **Transparency over complexity**: Clear, understandable interfaces
- **Motivation over monitoring**: Focus on encouragement and achievement
- **Beauty over functionality**: Aesthetic appeal enhances user engagement

### 1.2 Design Principles
1. **Liquid Glass Aesthetic**: Modern, translucent interfaces with depth and elegance
2. **Minimalist Approach**: Clean layouts with purposeful white space
3. **Positive Psychology**: Green color psychology for growth and achievement
4. **Gamification Integration**: Subtle game-like elements without overwhelming the core purpose
5. **Accessibility First**: Clear contrast, readable text, and intuitive navigation

---

## 2. Visual Design System

### 2.1 Color Palette

#### Primary Colors
- **Robin Hood Green**: `#38e07b` - Primary brand color, positive actions, achievements
- **Light Gray**: `#f7fafc` - Background color, clean and neutral
- **Steel Gray**: `#4a5568` - Secondary text, subtle elements

#### Accent Colors
- **Success Green**: `#22c55e` - Completed states, success indicators
- **Warning Yellow**: `#facc15` - POWER+ Mode celebrations, attention-grabbing elements
- **Neutral Gray**: `#6b7280` - Inactive states, secondary information
- **White**: `#ffffff` - Cards, overlays, clean backgrounds

#### Gradient System
- **Primary Gradient**: `rgba(56, 224, 123, 0.1)` to `rgba(247, 250, 252, 0.1)`
- **Background Gradients**: Subtle circular gradients for depth
- **Liquid Glass Effect**: `backdrop-filter: blur(20px)` with transparency

### 2.2 Typography

#### Font Stack
- **Primary**: Spline Sans (400, 500, 700, 900)
- **Fallback**: Noto Sans
- **System**: Sans-serif

#### Typography Scale
- **Display Large**: 7xl (72px) - Main earned time display
- **Heading 1**: 4xl (36px) - Screen titles, major headings
- **Heading 2**: 2xl (24px) - Section headers
- **Body Large**: lg (18px) - Important body text, quotes
- **Body Regular**: base (16px) - Standard body text
- **Body Small**: sm (14px) - Secondary information
- **Caption**: xs (12px) - Labels, fine print

#### Font Weights
- **Light**: 400 - Body text, secondary information
- **Medium**: 500 - Emphasized text, labels
- **Bold**: 700 - Headings, important actions
- **Black**: 900 - Display text, major emphasis

### 2.3 Iconography

#### Icon System
- **Primary**: Material Symbols Outlined
- **Style**: Line-based, consistent stroke width
- **Sizes**: 24px (standard), 32px (large), 48px (display)

#### Key Icons
- **Navigation**: home, add_circle, show_chart, person
- **Habits**: dark_mode (sleep), fitness_center (exercise), park (outdoor), work (productive)
- **Actions**: play_circle, add, remove, edit
- **Status**: check_circle, warning, info

### 2.4 Spacing & Layout

#### Spacing Scale
- **xs**: 4px - Fine adjustments
- **sm**: 8px - Small gaps
- **md**: 16px - Standard spacing
- **lg**: 24px - Section spacing
- **xl**: 32px - Large sections
- **2xl**: 48px - Major sections
- **3xl**: 64px - Screen-level spacing

#### Layout Grid
- **Container**: Max-width 480px (mobile-first)
- **Padding**: 16px standard, 24px for major sections
- **Margins**: 8px between elements, 16px between sections
- **Border Radius**: 12px (small), 16px (medium), 24px (large), 32px (cards)

---

## 3. Component Design System

### 3.1 Buttons

#### Primary Button
```css
- Background: #38e07b (Robin Hood Green)
- Text: #1f2937 (Dark Gray)
- Height: 56px
- Border Radius: 28px (fully rounded)
- Font: Spline Sans 700, 18px
- Shadow: 0 4px 12px rgba(56, 224, 123, 0.3)
- Hover: Scale 1.05, enhanced shadow
```

#### Secondary Button
```css
- Background: #f3f4f6 (Light Gray)
- Text: #1f2937 (Dark Gray)
- Height: 56px
- Border Radius: 28px
- Font: Spline Sans 700, 18px
- Hover: Scale 1.05, background darkens
```

#### Icon Button
```css
- Size: 40px x 40px
- Background: Transparent or subtle background
- Icon: 24px Material Symbols
- Border Radius: 20px
- Hover: Background color change
```

### 3.2 Cards & Containers

#### Liquid Glass Card
```css
- Background: rgba(255, 255, 255, 0.7)
- Backdrop Filter: blur(20px)
- Border: 1px solid rgba(255, 255, 255, 0.2)
- Border Radius: 24px
- Shadow: 0 8px 32px rgba(0, 0, 0, 0.1)
- Padding: 24px
```

#### Progress Card
```css
- Background: White with subtle gradient
- Border Radius: 16px
- Shadow: 0 2px 8px rgba(0, 0, 0, 0.05)
- Padding: 16px
- Border: 1px solid rgba(0, 0, 0, 0.05)
```

### 3.3 Navigation

#### Bottom Navigation Bar
```css
- Height: 80px
- Background: rgba(255, 255, 255, 0.8)
- Backdrop Filter: blur(24px)
- Border Top: 1px solid rgba(0, 0, 0, 0.1)
- Padding: 8px 16px
- Icon Size: 24px
- Text Size: 12px
```

#### Navigation Items
- **Active State**: Green color (#38e07b), bold text
- **Inactive State**: Gray color (#6b7280), normal weight
- **Special**: Central "+" button with elevated design

### 3.4 Progress Indicators

#### Circular Progress
```css
- Size: 96px diameter
- Stroke Width: 4px
- Background Circle: #e5e7eb (Light Gray)
- Progress Circle: #38e07b (Robin Hood Green)
- Animation: Smooth stroke-dasharray animation
```

#### Linear Progress Bar
```css
- Height: 12px
- Background: #e5e7eb (Light Gray)
- Progress: #38e07b (Robin Hood Green)
- Border Radius: 6px
- Animation: Smooth width transition
```

### 3.5 Form Elements

#### Input Fields
```css
- Height: 48px
- Background: White
- Border: 1px solid #d1d5db
- Border Radius: 12px
- Padding: 12px 16px
- Font: Spline Sans 400, 16px
- Focus: Border color #38e07b, shadow
```

#### Toggle Controls
```css
- Size: 44px x 24px
- Background: #d1d5db (inactive), #38e07b (active)
- Thumb: 20px circle, white
- Animation: Smooth slide transition
```

---

## 4. Screen-by-Screen Design Specifications

### 4.1 Start Screen (Onboarding)

#### Layout Structure
- **Background**: Light gray with gradient overlays
- **Content**: Centered liquid glass card
- **Elements**: Title, description, CTA button

#### Key Elements
- **Title**: "Welcome to FocusFlow" (4xl, bold, dark gray)
- **Description**: Value proposition text (lg, steel gray)
- **CTA Button**: "Get Started" (primary button style)
- **Background**: Circular gradient overlays for depth

#### Interaction Design
- **Button Hover**: Scale and shadow enhancement
- **Card Animation**: Subtle entrance animation
- **Background**: Gentle gradient animation

### 4.2 Home Dashboard

#### Layout Structure
- **Header**: Earned time display (7xl, bold)
- **Status**: POWER+ Mode indicator with dot
- **Quote**: Motivational text (lg, italic)
- **Actions**: Two primary buttons
- **Navigation**: Bottom tab bar

#### Key Elements
- **Time Display**: "1h 23m" (7xl, bold, dark)
- **Status Dot**: Green circle (2px, #22c55e)
- **POWER+ Mode**: "POWER+ Mode: Active" (base, medium)
- **Quote**: Italicized motivational text
- **Buttons**: "Log Time" (primary), "See Progress" (secondary)

#### Visual Hierarchy
1. **Primary**: Earned time display
2. **Secondary**: POWER+ Mode status
3. **Tertiary**: Motivational quote
4. **Actions**: Primary action buttons

### 4.3 Log Screen

#### Layout Structure
- **Header**: Back button, title, time summary
- **Timer Section**: Large display, start button
- **Manual Entry**: List of habit categories with controls
- **Navigation**: Bottom tab bar with central "+"

#### Key Elements
- **Timer Display**: "00:00:00" (7xl, bold, monospace)
- **Start Button**: Large primary button with play icon
- **Habit Cards**: Individual cards for each category
- **Controls**: +/- buttons for manual adjustment
- **Icons**: Material symbols for each habit type

#### Interaction Patterns
- **Timer Start**: Button transforms to stop state
- **Manual Entry**: Immediate visual feedback
- **Category Selection**: Visual state changes
- **Navigation**: Central "+" button elevation

### 4.4 Progress Screen

#### Layout Structure
- **Header**: Back button, title
- **Summary Cards**: Earned/used time with progress bars
- **POWER+ Banner**: Celebration notification
- **Habit Grid**: 2x3 grid of progress circles
- **Navigation**: Bottom tab bar

#### Key Elements
- **Progress Bars**: Linear indicators with percentages
- **POWER+ Banner**: Yellow background with lightning icon
- **Habit Circles**: Circular progress with icons
- **Completion States**: Visual distinction for completed habits

#### Visual States
- **Completed**: Full green circle, check icon
- **In Progress**: Partial circle, percentage text
- **Not Started**: Empty circle, gray icon

### 4.5 Profile Screen

#### Layout Structure
- **Header**: Back button, title
- **Profile Section**: Avatar, name, email
- **Usage Stats**: Average screen time card
- **Settings List**: Menu items with icons
- **Logout**: Prominent action button

#### Key Elements
- **Avatar**: 128px circle with edit button
- **User Info**: Name (2xl, bold), email (base, gray)
- **Stats Card**: Usage information with icon
- **Settings Items**: Icon, text, arrow pattern
- **Logout Button**: Warning-colored action

#### Interaction Design
- **Avatar Edit**: Overlay button with hover state
- **Settings Items**: Hover effects, arrow indicators
- **Logout**: Confirmation dialog (not shown in wireframe)

### 4.6 How It Works Screen

#### Layout Structure
- **Header**: Close button, title
- **Content Cards**: 4 educational sections
- **Footer**: Privacy policy link
- **Navigation**: Bottom tab bar

#### Key Elements
- **Educational Cards**: Gradient backgrounds with icons
- **Section Headers**: Green text (2xl, bold)
- **Body Text**: Gray text (base, relaxed)
- **Background Gradients**: Subtle circular overlays

#### Content Sections
1. **Earning Time**: How users earn screen time
2. **Habits**: Science-backed habit tracking
3. **Penalties**: Sleep-based penalty system
4. **Why This Works**: Behavioral science explanation

---

## 5. Responsive Design & Adaptations

### 5.1 Mobile-First Approach
- **Primary Target**: 375px - 414px (iPhone standard sizes)
- **Secondary**: 360px - 428px (Android standard sizes)
- **Breakpoints**: Single breakpoint for mobile optimization

### 5.2 Screen Size Adaptations
- **Small Screens** (320px-375px): Reduced padding, smaller text
- **Standard Screens** (375px-414px): Default design specifications
- **Large Screens** (414px+): Increased padding, larger touch targets

### 5.3 Orientation Handling
- **Portrait**: Primary orientation, all designs optimized
- **Landscape**: Limited support, basic functionality maintained

---

## 6. Animation & Interaction Design

### 6.1 Animation Principles
- **Purposeful**: Every animation serves a functional purpose
- **Smooth**: 60fps performance, hardware acceleration
- **Consistent**: Standardized timing and easing
- **Accessible**: Respects reduced motion preferences

### 6.2 Key Animations

#### Page Transitions
- **Duration**: 300ms
- **Easing**: ease-in-out
- **Type**: Slide or fade transitions

#### Button Interactions
- **Hover**: Scale 1.05, 200ms ease-out
- **Press**: Scale 0.95, 100ms ease-in
- **Release**: Scale 1.05, 150ms ease-out

#### Progress Animations
- **Circular Progress**: Stroke-dasharray animation, 800ms ease-out
- **Linear Progress**: Width transition, 600ms ease-out
- **Counter Animation**: Number counting, 1000ms ease-out

#### State Changes
- **POWER+ Mode Unlock**: Celebration animation, 1.2s ease-out
- **Timer Start/Stop**: Smooth state transitions, 200ms
- **Data Updates**: Subtle fade-in, 300ms ease-out

### 6.3 Micro-Interactions
- **Button Feedback**: Immediate visual response
- **Loading States**: Skeleton screens or spinners
- **Error States**: Shake animation for invalid inputs
- **Success States**: Check mark animation

---

## 7. Accessibility Design

### 7.1 Visual Accessibility
- **Color Contrast**: WCAG AA compliance (4.5:1 ratio minimum)
- **Text Size**: Minimum 16px for body text
- **Touch Targets**: Minimum 44px x 44px
- **Focus Indicators**: Clear visual focus states

### 7.2 Interaction Accessibility
- **Keyboard Navigation**: Full keyboard support
- **Screen Reader**: Semantic HTML, ARIA labels
- **Voice Control**: VoiceOver/TalkBack compatibility
- **Motor Accessibility**: Large touch targets, gesture alternatives

### 7.3 Cognitive Accessibility
- **Clear Hierarchy**: Obvious information structure
- **Consistent Patterns**: Predictable interaction models
- **Error Prevention**: Clear validation and feedback
- **Simple Language**: Plain language, clear instructions

---

## 8. Design Implementation Guidelines

### 8.1 Development Handoff
- **Design Tokens**: CSS custom properties for all design values
- **Component Library**: Reusable UI components
- **Style Guide**: Comprehensive design system documentation
- **Asset Organization**: Structured file naming and organization

### 8.2 Quality Assurance
- **Design Review**: Regular design-dev alignment
- **Pixel Perfect**: Accurate implementation verification
- **Cross-Device Testing**: Multiple device validation
- **Performance**: Animation and loading optimization

### 8.3 Maintenance & Updates
- **Version Control**: Design system versioning
- **Documentation**: Up-to-date design specifications
- **Feedback Loop**: User testing and iteration
- **Scalability**: Design system expansion planning

---

## 9. Design Assets & Resources

### 9.1 Asset Organization
```
/designs/
├── wireframes/           # Interactive HTML prototypes
├── flows/               # User journey diagrams
├── icons/               # Custom icon assets
└── README.md           # Asset documentation
```

### 9.2 Design Tools & Resources
- **Prototyping**: HTML/CSS with Tailwind
- **Icons**: Material Symbols Outlined
- **Fonts**: Google Fonts (Spline Sans, Noto Sans)
- **Colors**: Custom CSS variables
- **Animations**: CSS transitions and transforms

### 9.3 Design System Files
- **CSS Variables**: Color, typography, spacing tokens
- **Component Styles**: Reusable component definitions
- **Animation Library**: Standard animation classes
- **Responsive Utilities**: Mobile-first responsive helpers

---

*This design documentation serves as the definitive guide for implementing the ScreenTime Balance app's visual design. All development should reference these specifications to ensure consistency and quality.*
