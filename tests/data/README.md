# Test Data & Configuration - ZenScreen Mobile App

**Last Updated**: September 11, 2025  
**Data Version**: 1.0  

---

## 📁 Directory Structure

```
tests/data/
├── README.md                    # This file - test data documentation
├── test-users.json             # Test user accounts and profiles
├── test-habits.json            # Sample habit data for testing
├── test-scenarios.json         # Test scenario configurations
├── test-environments.json      # Test environment configurations
├── test-data-sets/             # Large test data sets
│   ├── user-profiles.json      # Extended user profile data
│   ├── habit-histories.json    # Historical habit data
│   └── performance-data.json   # Performance test data
└── fixtures/                   # Test fixtures and mock data
    ├── mock-responses.json     # Mock API responses
    ├── sample-images/          # Test images and assets
    └── database-seeds.json     # Database seed data
```

### **🚨 CRITICAL: Test Directory Structure**

**ALWAYS use these established test directories:**
- ✅ **Flutter Tests**: `ScreenTimeBalance\tests\flutter\`
- ✅ **Unit Tests**: `ScreenTimeBalance\tests\flutter\unit\`
- ✅ **Widget Tests**: `ScreenTimeBalance\tests\flutter\widget\`
- ✅ **Integration Tests**: `ScreenTimeBalance\tests\flutter\integration\`
- ✅ **Test Mocks**: `ScreenTimeBalance\tests\flutter\mocks\`

**❌ NEVER create new test folders** - Always use the existing structure and place test artifacts in the designated locations.

---

## 🎯 Test Data Philosophy

### **Data Management Principles**
- **Realistic Data**: Test data mirrors real user scenarios
- **Privacy Compliant**: No real user data used in tests
- **Comprehensive Coverage**: Data covers all edge cases and scenarios
- **Maintainable**: Easy to update and modify test data
- **Version Controlled**: All test data tracked in version control

### **Data Categories**
1. **User Data**: Test accounts, profiles, authentication data
2. **Habit Data**: Sample habit entries, timer sessions, progress data
3. **Configuration Data**: Test environments, feature flags, settings
4. **Performance Data**: Large datasets for performance testing
5. **Mock Data**: Simulated API responses, external service data

---

## 👥 Test User Data

### **Test User Accounts**
**File**: `tests/data/test-users.json`

**User Types**:
- **Standard Users**: Regular app users with typical usage patterns
- **Power Users**: Heavy users with extensive habit tracking
- **New Users**: Fresh accounts for onboarding testing
- **Edge Case Users**: Users with unusual data patterns
- **Admin Users**: Test accounts with administrative privileges

**User Data Includes**:
- Email addresses (test domains only)
- Passwords (test passwords only)
- Profile information (names, avatars, preferences)
- Authentication tokens (test tokens)
- Account status (active, suspended, deleted)

### **Sample User Data Structure**
```json
{
  "users": [
    {
      "id": "test-user-001",
      "email": "john.doe@test.com",
      "password": "TestPassword123!",
      "profile": {
        "name": "John Doe",
        "avatar_url": "https://test.com/avatars/john.jpg",
        "timezone": "America/New_York",
        "preferences": {
          "notifications": true,
          "theme": "light"
        }
      },
      "account_status": "active",
      "created_date": "2025-09-01T00:00:00Z"
    }
  ]
}
```

---

## 📊 Habit Test Data

### **Sample Habit Entries**
**File**: `tests/data/test-habits.json`

**Habit Categories**:
- **Sleep**: Various sleep durations (4-12 hours)
- **Exercise**: Different exercise types and durations
- **Outdoor Time**: Various outdoor activities
- **Productive Time**: Different productive activities

**Data Includes**:
- Daily habit entries with timestamps
- Manual time entries (+/- 15 minute increments)
- Timer session data
- POWER+ Mode achievements
- Historical progress data

### **Sample Habit Data Structure**
```json
{
  "habit_entries": [
    {
      "id": "habit-001",
      "user_id": "test-user-001",
      "date": "2025-09-11",
      "sleep_minutes": 480,
      "exercise_minutes": 60,
      "outdoor_minutes": 120,
      "productive_minutes": 180,
      "earned_screen_time": 200,
      "power_plus_mode": true,
      "created_at": "2025-09-11T08:00:00Z"
    }
  ]
}
```

---

## ⚙️ Test Configuration

### **Test Environments**
**File**: `tests/data/test-environments.json`

**Environment Types**:
- **Local Development**: Local testing environment
- **Staging**: Pre-production testing environment
- **Production**: Production environment (read-only tests)
- **Performance**: High-load testing environment
- **Security**: Security testing environment

**Configuration Includes**:
- Database connections
- API endpoints
- Feature flags
- Environment variables
- Test data setup

### **Test Scenarios**
**File**: `tests/data/test-scenarios.json`

**Scenario Types**:
- **Happy Path**: Normal user workflows
- **Edge Cases**: Boundary conditions and limits
- **Error Conditions**: Error handling scenarios
- **Performance**: High-load and stress scenarios
- **Security**: Security testing scenarios

---

## 🎭 Mock Data & Fixtures

### **Mock API Responses**
**File**: `tests/data/fixtures/mock-responses.json`

**Mock Data Includes**:
- Firebase Auth responses
- Firestore database responses
- External API responses
- Error responses
- Network failure simulations

### **Database Seeds**
**File**: `tests/data/fixtures/database-seeds.json`

**Seed Data Includes**:
- Initial database schema
- Sample user accounts
- Default app settings
- Test habit categories
- System configuration

---

## 📈 Performance Test Data

### **Large Data Sets**
**Directory**: `tests/data/test-data-sets/`

**Performance Data Includes**:
- **User Profiles**: 1000+ test user profiles
- **Habit Histories**: 1 year of historical habit data
- **Performance Metrics**: Response time benchmarks
- **Load Test Data**: High-volume data for stress testing

### **Performance Test Scenarios**
- **Concurrent Users**: Multiple users accessing simultaneously
- **Large Datasets**: Apps with extensive historical data
- **Network Conditions**: Various network speeds and reliability
- **Device Performance**: Different device capabilities

---

## 🔒 Security Test Data

### **Security Test Cases**
**File**: `tests/data/security-test-data.json`

**Security Data Includes**:
- **Malicious Inputs**: SQL injection attempts, XSS payloads
- **Invalid Credentials**: Wrong passwords, expired tokens
- **Privilege Escalation**: Attempts to access unauthorized data
- **Data Validation**: Invalid data formats and edge cases

### **Privacy Test Data**
- **Personal Information**: Test personal data (not real)
- **Consent Scenarios**: Various consent states and preferences
- **Data Deletion**: Test data deletion scenarios
- **Data Portability**: Data export and import testing

---

## 🎯 Data Usage Guidelines

### **Test Data Best Practices**
1. **Never Use Real Data**: All test data must be synthetic
2. **Maintain Consistency**: Use consistent data across test runs
3. **Version Control**: Track all test data changes
4. **Documentation**: Document data structure and usage
5. **Cleanup**: Clean up test data after test completion

### **Data Privacy**
- **No Real User Data**: Never include real user information
- **Test Domains Only**: Use test email domains (@test.com, @example.com)
- **Synthetic Names**: Use clearly fake names and information
- **Data Retention**: Follow data retention policies for test data

---

## 🔄 Data Maintenance

### **Update Schedule**
- **Weekly**: Review and update test data
- **Monthly**: Refresh large datasets
- **Per Release**: Update data for new features
- **As Needed**: Update data for specific test requirements

### **Data Validation**
- **Format Validation**: Ensure all data follows correct formats
- **Completeness Check**: Verify all required fields are present
- **Consistency Check**: Ensure data relationships are valid
- **Privacy Check**: Verify no real user data is included

---

## 🚀 Future Enhancements

### **Planned Improvements**
1. **Data Generation**: Automated test data generation
2. **Data Masking**: Advanced data privacy protection
3. **Data Analytics**: Test data usage analytics
4. **Data Templates**: Reusable data templates
5. **Data Integration**: Integration with external data sources

---

**Note**: This test data system provides comprehensive, realistic, and privacy-compliant data for all testing scenarios. All data is synthetic and designed to support thorough testing of all app features.
