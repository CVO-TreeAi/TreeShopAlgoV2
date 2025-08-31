import SwiftUI

struct ContentView: View {
    @StateObject private var pricingModel = PricingModel()
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Pure black background
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            // Input Section
                            inputSection
                            
                            // Results Section
                            resultsSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(pricingModel: pricingModel)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.18, green: 0.49, blue: 0.20), Color(red: 0.30, green: 0.69, blue: 0.31)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 120)
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "tree.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                        
                        Text("TreeShop Calculator")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
        }
    }
    
    // MARK: - Input Section
    private var inputSection: some View {
        VStack(spacing: 20) {
            inputField(
                title: "Land Size (Acres)",
                value: $pricingModel.landSize,
                placeholder: "Enter acres",
                formatter: .decimal
            )
            
            packagePicker
            
            projectZipCodeField
            
            transportHoursField
            
            inputField(
                title: "Debris Hauling (Yards)",
                value: $pricingModel.debrisYards,
                placeholder: "Cubic yards",
                formatter: .decimal
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Package Picker
    private var packagePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Package Type")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
            
            Picker("Package Type", selection: $pricingModel.selectedPackage) {
                ForEach(PackageType.allCases) { package in
                    VStack(alignment: .leading) {
                        Text(package.displayName)
                        if !package.densityDescription.isEmpty {
                            Text(package.densityDescription)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .tag(package)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 2)
                    )
            )
            .accentColor(Color(red: 0.30, green: 0.69, blue: 0.31))
            
            // Show description for selected Max package
            if !pricingModel.selectedPackage.densityDescription.isEmpty {
                Text(pricingModel.selectedPackage.densityDescription)
                    .font(.caption)
                    .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                    .padding(.top, 4)
            }
        }
    }
    
    // MARK: - Input Field
    private func inputField(title: String, value: Binding<Double>, placeholder: String, formatter: NumberFormatter.Style) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
            
            TextField(placeholder, value: value, formatter: numberFormatter(style: formatter))
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 2)
                        )
                )
                .foregroundColor(.white)
                .keyboardType(.decimalPad)
        }
    }
    
    // MARK: - Results Section
    private var resultsSection: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                resultRow(label: "Package Cost", value: pricingModel.formatCurrency(pricingModel.baseCost))
                resultRow(label: "Transport", value: pricingModel.formatCurrency(pricingModel.transportCost))
                
                // Show debris breakdown for Max packages
                if pricingModel.isMaxPackage {
                    VStack(spacing: 4) {
                        resultRow(label: "Est. Debris (\(Int(pricingModel.estimatedDebrisYards)) yds @ $20)", value: pricingModel.formatCurrency(pricingModel.estimatedDebrisYards * pricingModel.debrisRatePerYard))
                        if pricingModel.debrisYards > 0 {
                            resultRow(label: "Additional Debris", value: pricingModel.formatCurrency(pricingModel.debrisYards * pricingModel.debrisRatePerYard))
                        }
                        resultRow(label: "Total Debris Hauling", value: pricingModel.formatCurrency(pricingModel.debrisCost))
                            .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                    }
                } else {
                    resultRow(label: "Debris Hauling", value: pricingModel.formatCurrency(pricingModel.debrisCost))
                }
                
                resultRow(label: "Subtotal", value: pricingModel.formatCurrency(pricingModel.subtotal))
                resultRow(label: "Project Total", value: pricingModel.formatCurrency(pricingModel.finalPrice))
                
                // Highlighted deposit row
                depositRow
                
                resultRow(label: "Balance at Completion", value: pricingModel.formatCurrency(pricingModel.balanceDue))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Total section
            totalSection
        }
    }
    
    // MARK: - Result Row
    private func resultRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Deposit Row (Highlighted)
    private var depositRow: some View {
        HStack {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                Text("Deposit Required (\(Int(pricingModel.depositPercentage * 100))%)")
                    .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
            }
            Spacer()
            Text(pricingModel.formatCurrency(pricingModel.depositAmount))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 1.0, green: 0.76, blue: 0.03).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 1.0, green: 0.76, blue: 0.03).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Total Section
    private var totalSection: some View {
        VStack {
            Text("Total Project Cost")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(pricingModel.formatCurrency(pricingModel.finalPrice))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(red: 0.18, green: 0.49, blue: 0.20), Color(red: 0.30, green: 0.69, blue: 0.31)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        )
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Project Zip Code Field
    private var projectZipCodeField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Project Zip Code")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
            
            HStack {
                TextField("Enter project zip code", text: $pricingModel.projectZipCode)
                    .keyboardType(.numberPad)
                    .onChange(of: pricingModel.projectZipCode) { newValue in
                        // Auto-calculate when zip code is 5 digits
                        if newValue.count == 5 && !pricingModel.baseLocationAddress.isEmpty {
                            pricingModel.calculateTransportTime(for: newValue)
                        }
                    }
                
                if pricingModel.isCalculatingDistance {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(Color(red: 0.30, green: 0.69, blue: 0.31))
                } else {
                    Button(action: {
                        if !pricingModel.projectZipCode.isEmpty {
                            pricingModel.calculateTransportTime(for: pricingModel.projectZipCode)
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .foregroundColor(Color(red: 0.30, green: 0.69, blue: 0.31))
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 2)
                    )
            )
            .foregroundColor(.white)
        }
    }
    
    // MARK: - Transport Hours Field
    private var transportHoursField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Transport Hours")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
                
                Spacer()
                
                if pricingModel.transportHours > 0 && !pricingModel.projectZipCode.isEmpty {
                    Text("Auto-calculated")
                        .font(.caption)
                        .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                }
            }
            
            TextField("Hours", value: $pricingModel.transportHours, formatter: numberFormatter(style: .decimal))
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(pricingModel.transportHours > 0 && !pricingModel.projectZipCode.isEmpty ? 
                                       Color(red: 1.0, green: 0.76, blue: 0.03).opacity(0.5) : 
                                       Color.white.opacity(0.1), lineWidth: 2)
                        )
                )
                .foregroundColor(.white)
                .keyboardType(.decimalPad)
        }
    }
    
    // MARK: - Number Formatter
    private func numberFormatter(style: NumberFormatter.Style) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = style
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}