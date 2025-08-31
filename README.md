# TreeShop Pricing Calculator

A professional iOS app for TreeShop forestry and land clearing pricing calculations.

## Features

### 🌲 Package-Based Pricing
- **Small Package**: 4" DBH - $2,125/acre
- **Medium Package**: 6" DBH - $2,500/acre  
- **Large Package**: 8" DBH - $3,375/acre
- **X-Large Package**: 10" DBH - $4,250/acre
- **Max Package - Tiered Density**:
  - Light: 10" and under trees - $8,000/acre
  - Medium: Up to 15" trees - $12,000/acre  
  - Heavy: 15"+ trees - $18,000/acre

### 🚛 Smart Transport Calculation
- Auto-calculates transport time based on project zip code
- Uses Apple Maps for real driving directions
- Automatically calculates round-trip time
- Rounds to nearest 0.5 hour for billing accuracy

### 🗑️ Debris Management
- Auto-estimates debris volume for Max packages
- Light: 500 yards/acre
- Medium: 750 yards/acre (industry average)
- Heavy: 1,000+ yards/acre
- $20/yard debris hauling rate

### ⚙️ Fully Configurable Settings
- Adjustable package rates
- Customizable transport and debris rates
- Business information (name, address, phone, email)
- Apple Maps integration for address validation
- Final price modifier for quick discounts/premiums
- Deposit percentage adjustment

### 📱 Professional Interface
- Dark mode design
- Real-time pricing calculations
- Clean user experience (no exposed formulas)
- Mobile-optimized layout
- Persistent settings storage

## Technical Details

### Built With
- **SwiftUI** - Modern iOS development framework
- **MapKit** - Apple Maps integration for routing
- **CoreLocation** - Location services for distance calculation
- **UserDefaults** - Settings persistence

### Requirements
- iOS 17.0+
- Xcode 15.0+
- Internet connection for Maps functionality

### Architecture
- **MVVM Pattern** - Clean separation of concerns
- **Observable Objects** - Reactive UI updates
- **Combine Framework** - Data binding and real-time updates

## Installation

1. Clone the repository:
```bash
git clone https://github.com/CVO-TreeAi/TreeShopAlgo.git
```

2. Open `TreeShopCalculator.xcodeproj` in Xcode

3. Build and run on simulator or device (⌘+R)

## Usage

### Initial Setup
1. Open app settings (gear icon)
2. Enter business information:
   - Business name
   - Base location address (for transport calculations)
   - Contact information
3. Adjust pricing rates if needed
4. Save settings

### Creating Quotes
1. Enter land size in acres
2. Select appropriate package type
3. Enter project zip code (auto-calculates transport)
4. Add additional debris if needed
5. View instant pricing breakdown

### Pricing Output
- Package cost breakdown
- Transport cost (auto-calculated)
- Debris hauling estimate
- 25% deposit amount
- Total project cost

## Business Logic

### Transport Calculation
```swift
// Round trip time calculation
let oneWayHours = route.expectedTravelTime / 3600.0
let roundTripHours = oneWayHours * 2
let billingHours = (roundTripHours * 2).rounded() / 2 // Round to 0.5 hour
```

### Final Pricing Formula
```swift
let subtotal = packageCost + transportCost + debrisCost
let finalPrice = subtotal * finalPriceModifier  // Default 1.15 (15% markup)
let deposit = finalPrice * 0.25  // 25% deposit
```

### Max Package Debris Estimation
- **Light Density**: 500 yards/acre × land size × $20/yard
- **Medium Density**: 750 yards/acre × land size × $20/yard  
- **Heavy Density**: 1,000 yards/acre × land size × $20/yard

## Security Features

- No hardcoded API keys or sensitive data
- Local data storage only (UserDefaults)
- No external data transmission
- Maps integration uses Apple's secure APIs

## Contributing

This is a private repository for TreeShop internal use. Contact development team for access.

## License

Proprietary - TreeShop/CVO-TreeAI Internal Use Only

---

**TreeShop Calculator** - Professional forestry pricing made simple 🌲