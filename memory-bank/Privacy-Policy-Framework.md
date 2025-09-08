# ScreenTime Balance - Privacy Policy Framework

## Overview
This document outlines the privacy policy framework for ScreenTime Balance app, ensuring compliance with privacy regulations while maintaining user trust and transparency.

**Related Documents:**
- [Features.md](./Features.md) - Detailed feature specifications including data handling
- [Product Requirements Document](./Product-Requirements-Document.md) - High-level privacy constraints

---

## 1. Data Collection & Usage

### 1.1 Personal Data We Collect
**Account Information:**
- Email address (for authentication)
- Name (user-provided, optional)
- Profile avatar (user-uploaded, optional)

**Habit Tracking Data:**
- Daily habit entries (sleep, exercise, outdoor, productive time)
- Timer sessions and manual entries
- Earned screen time calculations
- POWER+ Mode achievements

**Technical Data:**
- Device type and operating system version
- App usage patterns (for performance optimization only)
- Error logs and crash reports (anonymous)

### 1.2 How We Use Your Data
**Primary Purposes:**
- Provide habit tracking and screen time earning functionality
- Sync data across your devices
- Calculate personalized progress and achievements
- Improve app performance and fix bugs

**We Do NOT:**
- Sell your personal data to third parties
- Use your data for advertising purposes
- Share individual habit data with anyone
- Track your location or other device activities

---

## 2. Data Storage & Security

### 2.1 Where Your Data is Stored
**Local Storage:**
- Primary data storage on your device using encrypted SQLite database
- Local data remains functional even without internet connection

**Cloud Backup:**
- Firebase Firestore for data synchronization and backup
- Google Cloud Platform infrastructure (Firebase backend)
- Data encrypted in transit and at rest

### 2.2 Data Security Measures
**Encryption:**
- Local database encryption using device security features
- HTTPS/TLS encryption for all data transmission
- Firebase security rules protecting user data access

**Access Controls:**
- User authentication required for all data access
- Individual user data isolation (users can only access their own data)
- No administrator access to personal habit data

---

## 3. Data Retention & User Rights

### 3.1 Data Retention Policy
**Active Users:**
- Habit data retained for 2 years by default
- User can configure retention period (1 month to 5 years)
- Account information retained until account deletion

**Inactive Users:**
- Data automatically deleted after 3 years of inactivity
- Email notification sent before automatic deletion
- User can reactivate account to prevent deletion

### 3.2 User Rights & Controls
**Data Access:**
- View all your stored data within the app
- Export your data in standard JSON format
- Download complete data archive on request

**Data Correction:**
- Edit habit entries within same day (see [Features.md Section 2.5](./Features.md#25-habit-data-correction-editundo))
- Update profile information at any time
- Correct inaccurate data through app interface

**Data Deletion:**
- Delete individual habit entries
- Delete entire account with 7-day grace period
- Permanent deletion removes all data from our systems

---

## 4. Third-Party Services & Data Sharing

### 4.1 Firebase/Google Cloud Platform
**Service Provider:** Google LLC
**Purpose:** Authentication, data storage, and synchronization
**Data Shared:** Account information and habit tracking data
**Privacy Policy:** https://policies.google.com/privacy

**Data Processing Agreement:**
- Google processes data on our behalf only
- Data remains under your control and our privacy policy
- Google cannot use your data for their own purposes

### 4.2 Analytics & Crash Reporting
**Anonymous Data Only:**
- App performance metrics (load times, feature usage)
- Anonymous crash reports for bug fixing
- No personal identifiers included in analytics

**Opt-Out Available:**
- Users can disable crash reporting in settings
- Analytics data aggregated and anonymized
- No individual user tracking or profiling

---

## 5. Children's Privacy

### 5.1 Age Restrictions
**Minimum Age:** 13 years old
**Parental Consent:** Required for users under 16 in EU
**Age Verification:** Self-reported during account creation

### 5.2 Special Protections for Minors
- No behavioral advertising or profiling
- Enhanced data protection controls
- Simplified privacy settings interface
- Regular prompts about privacy settings

---

## 6. International Data Transfers

### 6.1 Data Location
**Primary Storage:** User's device (local)
**Cloud Backup:** Google Cloud Platform global infrastructure
**EU Users:** Data may be processed in EU or other Google data centers

### 6.2 Transfer Safeguards
- Google's Standard Contractual Clauses for EU data transfers
- Adequate data protection measures in all locations
- User consent for international transfers where required

---

## 7. Privacy Policy Updates

### 7.1 Notification Process
**Material Changes:**
- 30-day advance notice via email
- In-app notification on next login
- Option to delete account if user disagrees with changes

**Minor Updates:**
- Updated privacy policy posted in app
- Version history maintained
- Last updated date clearly displayed

### 7.2 User Consent
**Continued Use:** Constitutes acceptance of updated policy
**Opt-Out Option:** Users can delete account before changes take effect
**Granular Controls:** Users can adjust privacy settings without deleting account

---

## 8. Contact & Data Protection

### 8.1 Privacy Contact Information
**Data Protection Officer:** [To be designated]
**Privacy Email:** privacy@screentimebalance.com (placeholder)
**Response Time:** 30 days maximum for privacy requests

### 8.2 Regulatory Compliance
**GDPR (EU):** Full compliance with data protection rights
**CCPA (California):** Consumer privacy rights honored
**Other Jurisdictions:** Local privacy laws respected where applicable

---

## 9. Implementation Requirements

### 9.1 Technical Implementation
**Privacy by Design:**
- Minimal data collection principle
- Local-first architecture reduces privacy risks
- Encryption by default for all data storage

**User Interface:**
- Clear privacy settings page
- Data usage transparency in app
- Easy access to privacy controls

### 9.2 Legal Requirements
**Privacy Policy Display:**
- Accessible from app settings
- Available during account creation
- Clear, readable language (8th grade level)

**Consent Mechanisms:**
- Explicit consent for data collection
- Granular controls for optional features
- Easy withdrawal of consent

---

## 10. Privacy Risk Assessment

### 10.1 Low Risk Factors
- Local-first data storage
- No advertising or data monetization
- Minimal third-party integrations
- Anonymous analytics only

### 10.2 Medium Risk Factors
- Cloud data synchronization
- International data transfers
- Potential for data breaches

### 10.3 Mitigation Strategies
- Strong encryption throughout
- Regular security audits
- Incident response plan
- User education about privacy features

---

## 11. Future Privacy Considerations

### 11.1 Planned Enhancements
**Phase 2 Features:**
- Enhanced privacy dashboard
- Granular data sharing controls
- Advanced encryption options

**Phase 3 Considerations:**
- Zero-knowledge architecture exploration
- Decentralized data storage options
- Advanced privacy-preserving analytics

### 11.2 Regulatory Monitoring
- Track evolving privacy regulations
- Proactive compliance updates
- Regular privacy policy reviews
- User notification of regulatory changes

---

*This privacy framework serves as the foundation for the legally compliant privacy policy that will be implemented in the ScreenTime Balance app. All technical features must align with these privacy principles.*
