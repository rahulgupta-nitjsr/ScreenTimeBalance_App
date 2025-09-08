# ScreenTime Balance - Design Assets

This folder contains all design assets, wireframes, and visual documentation for the ScreenTime Balance mobile app.

## 📁 Folder Structure

### `/wireframes/`
Contains detailed wireframes for all main app screens, organized by user flow:

- **1 Start_Screen/** - Onboarding and welcome experience
- **2 Home_Screen/** - Main dashboard showing earned screen time and POWER+ Mode status
- **3 Log_Screen/** - Activity logging interface with timer and manual entry
- **4 Progress_Screen/** - Visual progress tracking and habit completion status
- **5 Profile Screen/** - User profile, settings, and account management
- **6 How_It_Works_Screen/** - Educational content explaining the app's algorithm

Each wireframe folder contains:
- `code.html` - Interactive HTML prototype with Tailwind CSS styling
- `screen.png` - Static screenshot of the wireframe

### `/flows/`
- **main_user_journey.png** - Visual flowchart showing the complete user journey from onboarding to daily usage

### `/icons/`
- Placeholder for custom app icons and UI elements
- Currently contains placeholder files for sleep and exercise icons

## 🎨 Design System

### Color Palette
- **Primary Green**: `#38e07b` (Robin Hood Green)
- **Background**: Light gray tones with liquid glass effects
- **Accent Colors**: Yellow for POWER+ Mode, various greens for different UI states

### Typography
- **Primary Font**: Spline Sans (400, 500, 700)
- **Fallback**: Noto Sans
- **Icons**: Material Symbols Outlined

### Key Design Principles
1. **Liquid Glass Aesthetic**: Translucent backgrounds with backdrop blur effects
2. **Minimalist Interface**: Clean, uncluttered layouts with plenty of white space
3. **Positive Reinforcement**: Green color scheme emphasizing growth and achievement
4. **Gamification Elements**: POWER+ Mode badges, progress circles, and achievement indicators

## 📱 Screen Overview

### 1. Start Screen (Onboarding)
- Welcome message with app value proposition
- "Get Started" call-to-action button
- Liquid glass card design with gradient backgrounds

### 2. Home Screen
- Large display of earned screen time (1h 23m example)
- POWER+ Mode status indicator with green dot
- Motivational quote
- Primary action buttons: "Log Time" and "See Progress"
- Bottom navigation with 4 tabs

### 3. Log Screen
- Header showing earned vs. used screen time
- Active timer display (00:00:00 format)
- "Start Timer" button for current activity
- Manual entry section with +/- controls for all 4 habit categories
- Visual icons for each habit type (sleep, exercise, outdoor, productive)

### 4. Progress Screen
- Progress bars for earned vs. used screen time
- POWER+ Mode unlock celebration banner
- Grid of habit progress circles with completion percentages
- Visual indicators for each habit category

### 5. Profile Screen
- User avatar and profile information
- Usage statistics
- Settings menu with notifications, feedback, and support options
- Logout functionality

### 6. How It Works Screen
- Educational cards explaining the app's core concepts
- Information about earning time, habits, penalties, and behavioral science
- Privacy policy link

## 🔄 User Flow
The main user journey flows from onboarding → home dashboard → logging activities → viewing progress → managing profile, with the "How It Works" screen accessible as educational content.

## 🛠️ Technical Implementation
- All wireframes are built with HTML/CSS using Tailwind CSS framework
- Responsive design optimized for mobile devices
- Interactive elements demonstrate intended user interactions
- Material Design icons for consistent iconography

## 📝 Usage Notes
- Wireframes serve as the primary reference for development
- HTML prototypes can be used for user testing and stakeholder reviews
- Design system colors and typography should be maintained across all implementations
- All screens follow the established navigation pattern with bottom tab bar
