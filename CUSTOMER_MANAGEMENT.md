# TreeShop Customer Management System

A comprehensive customer management system built using your existing TreeShop UI patterns and components.

## Features

### 🏠 Customer List View
- **Modern UI**: Reuses your glassmorphism cards and gradient backgrounds
- **Search & Filter**: Find customers by name, email, phone, or city
- **Customer Types**: Filter by Residential, Commercial, or Municipal
- **Live Stats**: View total customers, projects, and revenue
- **Empty States**: Helpful prompts for first-time users

### 👤 Customer Detail View
- **Complete Profiles**: View all customer information and contact details
- **Project History**: See all past quotes and projects with status tracking
- **Quick Actions**: Call or email customers directly from the app
- **Visual Status**: Color-coded project statuses (Quoted, Accepted, In Progress, etc.)

### ✏️ Add/Edit Customer Form
- **Smart Forms**: Auto-complete address fields with Maps integration
- **Validation**: Email validation and required field checking
- **Customer Types**: Easy selection between Residential/Commercial/Municipal
- **Contact Preferences**: Track preferred communication methods
- **Notes System**: Store additional information about each customer

### 🔗 Calculator Integration
- **Customer Selection**: Choose customers directly from the pricing calculator
- **Save Quotes**: Convert calculations into customer projects
- **Project Tracking**: All quotes saved with full pricing breakdown
- **History**: Access past quotes and project details

## Data Model

### Customer Entity
```swift
struct Customer {
    - Personal Information (name, contact details)
    - Address Information (full address with city, state, zip)
    - Customer Type (residential, commercial, municipal)
    - Communication Preferences
    - Project History
    - Notes and Tags
    - Revenue Tracking
}
```

### Customer Project Entity
```swift
struct CustomerProject {
    - Project Details (name, land size, package type)
    - Pricing Breakdown (base cost, transport, debris)
    - Status Tracking (quoted → accepted → scheduled → completed)
    - Dates (created, scheduled, completed)
    - Location Information
}
```

## Architecture

### State Management
- **CustomerManager**: Centralized customer data management
- **UserDefaults Persistence**: Local data storage with JSON encoding
- **ObservableObject Pattern**: Reactive UI updates

### UI Patterns (Reused from TreeShop)
- **Glassmorphism Cards**: Background blur effects with gradient borders
- **Scale Button Animations**: Haptic feedback on interactions
- **Modern Input Fields**: Consistent styling across all forms
- **Floating Headers**: Compact navigation with action buttons
- **Color Scheme**: Dark theme with green accent colors
- **Typography**: System fonts with proper weight hierarchy

### Navigation Flow
- **TabView**: Main navigation between Calculator and Customers
- **Sheet Presentations**: Modal views for adding/editing customers
- **Deep Linking**: Direct navigation to customer details
- **Context Actions**: Quick actions throughout the app

## Integration Points

### With Existing TreeShop Calculator
1. **Customer Selection Card**: Added to main calculator view
2. **Save Quote Feature**: Converts calculations to customer projects
3. **Header Integration**: Added customers button to floating header
4. **Shared State**: CustomerManager integrated with ContentView

### Maps Integration
- **Address Search**: Real-time address suggestions
- **Auto-completion**: Populate city, state, zip from selected addresses
- **Transport Calculation**: Leverage existing distance calculation features

## Usage

### Adding a New Customer
1. Tap the "+" button in the customer list header
2. Fill in customer information with smart form assistance
3. Use address search for accurate location data
4. Save and the customer appears in the main list

### Creating a Quote for a Customer
1. Use the calculator to set up project details
2. Select or add a customer using the customer selection card
3. Tap "Save" to convert the quote to a customer project
4. Project appears in customer's history with full pricing breakdown

### Managing Customer Projects
1. View project history in customer detail view
2. Update project status as work progresses
3. Track revenue and project completion dates
4. Access full pricing breakdowns for each project

## Technical Implementation

### File Structure
- `CustomerModel.swift` - Data models and business logic
- `CustomerListView.swift` - Main customer list interface
- `CustomerDetailView.swift` - Individual customer profiles
- `AddEditCustomerView.swift` - Customer creation and editing forms
- `MainTabView.swift` - Navigation structure
- Integration in `ContentView.swift` - Calculator integration

### Performance Optimizations
- **LazyVStack**: Efficient scrolling for large customer lists
- **Conditional Rendering**: UI components only render when needed
- **State Optimization**: Minimal state updates for smooth animations
- **Search Debouncing**: Efficient real-time search filtering

## Future Enhancements

### Potential Additions
- **Export Features**: PDF quotes and customer reports
- **Calendar Integration**: Schedule projects with system calendar
- **Photo Attachments**: Before/after project photos
- **Payment Tracking**: Invoice and payment status
- **Customer Tags**: Custom categorization system
- **Analytics Dashboard**: Revenue and project insights
- **Backup/Sync**: iCloud synchronization
- **Notifications**: Follow-up reminders and scheduling alerts

### Business Intelligence
- **Revenue Analytics**: Track performance by customer type
- **Project Metrics**: Average project size and completion times
- **Customer Lifecycle**: Track customer journey from quote to completion
- **Referral Tracking**: Monitor customer acquisition sources

---

Built with ❤️ using your existing TreeShop UI patterns and SwiftUI best practices.