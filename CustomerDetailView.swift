import SwiftUI

struct CustomerDetailView: View {
    let customer: Customer
    @ObservedObject var customerManager: CustomerManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditCustomer = false
    @State private var showingDeleteAlert = false
    @State private var selectedProject: CustomerProject? = nil
    @State private var showingProjectDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        // Customer header card
                        customerHeaderCard
                        
                        // Contact information card
                        contactInfoCard
                        
                        // Project history card
                        projectHistoryCard
                        
                        // Customer notes card
                        if !customer.notes.isEmpty {
                            customerNotesCard
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .navigationTitle("Customer Details")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: HStack {
                    Button("Edit") {
                        showingEditCustomer = true
                    }
                    .foregroundColor(Color(red: 0.30, green: 0.69, blue: 0.31))
                }
            )
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingEditCustomer) {
            AddEditCustomerView(customerManager: customerManager, existingCustomer: customer)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Customer"),
                message: Text("Are you sure you want to delete \(customer.fullName)? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    customerManager.deleteCustomer(customer)
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(item: $selectedProject) { project in
            ProjectDetailView(project: project)
        }
    }
    
    // MARK: - Customer Header Card
    private var customerHeaderCard: some View {
        VStack(spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.2, green: 0.7, blue: 0.3), Color(red: 0.1, green: 0.5, blue: 0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Text(getInitials(customer.fullName))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(customer.fullName.isEmpty ? "No Name" : customer.fullName)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        Image(systemName: customer.customerType.iconName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                        
                        Text(customer.customerType.displayName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                    }
                    
                    if !customer.referralSource.isEmpty {
                        Text("via \(customer.referralSource)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                }
                
                Spacer()
            }
            
            // Customer stats row
            HStack(spacing: 16) {
                statPill(
                    title: "Projects",
                    value: "\(customer.totalProjects)",
                    icon: "hammer.fill",
                    color: Color(red: 1.0, green: 0.76, blue: 0.03)
                )
                
                if customer.totalRevenue > 0 {
                    statPill(
                        title: "Revenue",
                        value: formatCurrency(customer.totalRevenue),
                        icon: "dollarsign.circle.fill",
                        color: Color(red: 0.2, green: 0.7, blue: 0.3)
                    )
                }
                
                if let lastProject = customer.lastProjectDate {
                    statPill(
                        title: "Last Project",
                        value: formatDate(lastProject),
                        icon: "calendar.circle.fill",
                        color: Color(red: 0.0, green: 0.5, blue: 1.0)
                    )
                }
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Contact Info Card
    private var contactInfoCard: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.3))
                    
                    Text("Contact Information")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Quick contact buttons
                HStack(spacing: 8) {
                    if !customer.phone.isEmpty {
                        Button(action: {
                            if let phoneURL = URL(string: "tel:\(customer.phone.replacingOccurrences(of: " ", with: ""))") {
                                UIApplication.shared.open(phoneURL)
                            }
                        }) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(Color(red: 0.0, green: 0.5, blue: 1.0)))
                        }
                    }
                    
                    if !customer.email.isEmpty {
                        Button(action: {
                            if let emailURL = URL(string: "mailto:\(customer.email)") {
                                UIApplication.shared.open(emailURL)
                            }
                        }) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(Color(red: 1.0, green: 0.3, blue: 0.0)))
                        }
                    }
                }
            }
            
            VStack(spacing: 12) {
                if !customer.email.isEmpty {
                    contactRow(icon: "envelope.fill", title: "Email", value: customer.email)
                }
                
                if !customer.phone.isEmpty {
                    contactRow(icon: "phone.fill", title: "Phone", value: customer.phone)
                }
                
                if !customer.fullAddress.isEmpty {
                    contactRow(icon: "location.fill", title: "Address", value: customer.fullAddress)
                }
                
                if customer.preferredContactMethod != .phone {
                    contactRow(
                        icon: customer.preferredContactMethod.iconName,
                        title: "Preferred Contact",
                        value: customer.preferredContactMethod.displayName
                    )
                }
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Project History Card
    private var projectHistoryCard: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                    
                    Text("Project History")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if !customer.projects.isEmpty {
                    Text("\(customer.projects.count)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.7))
                }
            }
            
            if customer.projects.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "hammer.slash")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.4))
                    
                    Text("No projects yet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.7))
                }
                .padding(.vertical, 24)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(customer.projects.sorted(by: { $0.dateCreated > $1.dateCreated })) { project in
                        projectRow(project)
                    }
                }
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Customer Notes Card
    private var customerNotesCard: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "note.text")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.3))
                    
                    Text("Notes")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            
            Text(customer.notes)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.8))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Helper Views
    private func statPill(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color.white.opacity(0.7))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func contactRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.3))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func projectRow(_ project: CustomerProject) -> some View {
        Button(action: {
            selectedProject = project
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }) {
            HStack(spacing: 12) {
                // Status indicator
                Circle()
                    .fill(project.statusColor)
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(project.projectName.isEmpty ? "Untitled Project" : project.projectName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(project.projectStatus.displayName)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(project.statusColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(project.statusColor.opacity(0.2))
                            )
                    }
                    
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "ruler")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.6))
                            
                            Text("\(project.landSize, specifier: "%.1f") acres")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Text(formatCurrency(project.finalPrice))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.3))
                    }
                    
                    Text(formatDate(project.dateCreated))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Glassmorphism Background (reusing existing pattern)
    private var glassMorphismBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.02),
                            Color.black.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
    
    // MARK: - Helper Functions
    private func getInitials(_ name: String) -> String {
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        } else if let first = components.first, !first.isEmpty {
            return String(first.prefix(2)).uppercased()
        }
        return "??"
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Project Detail View
struct ProjectDetailView: View {
    let project: CustomerProject
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Project header
                        projectHeaderCard
                        
                        // Project details
                        projectDetailsCard
                        
                        // Pricing breakdown
                        pricingBreakdownCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Project Details")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(red: 0.30, green: 0.69, blue: 0.31))
            )
        }
        .preferredColorScheme(.dark)
    }
    
    private var projectHeaderCard: some View {
        VStack(spacing: 16) {
            HStack {
                Circle()
                    .fill(project.statusColor)
                    .frame(width: 16, height: 16)
                
                Text(project.projectName.isEmpty ? "Untitled Project" : project.projectName)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Status")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.7))
                    
                    Text(project.projectStatus.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(project.statusColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Created")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.7))
                    
                    Text(formatDate(project.dateCreated))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var projectDetailsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Project Details")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 12) {
                detailRow(title: "Land Size", value: "\(project.landSize, specifier: "%.1f") acres")
                detailRow(title: "Package Type", value: project.packageType.displayName)
                if !project.projectZipCode.isEmpty {
                    detailRow(title: "Project Location", value: project.projectZipCode)
                }
                detailRow(title: "Transport Hours", value: "\(project.transportHours, specifier: "%.1f") hours")
                if project.debrisYards > 0 {
                    detailRow(title: "Debris Yards", value: "\(project.debrisYards, specifier: "%.0f") yards")
                }
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var pricingBreakdownCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Pricing Breakdown")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 12) {
                pricingRow(title: "Base Cost", value: project.baseCost)
                if project.transportCost > 0 {
                    pricingRow(title: "Transport", value: project.transportCost)
                }
                if project.debrisCost > 0 {
                    pricingRow(title: "Debris Hauling", value: project.debrisCost)
                }
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                HStack {
                    Text("Total Project Cost")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(formatCurrency(project.finalPrice))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.3))
                }
                
                if project.depositAmount > 0 {
                    HStack {
                        Text("Deposit Required")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text(formatCurrency(project.depositAmount))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                    }
                }
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
    }
    
    private func pricingRow(title: String, value: Double) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.7))
            
            Spacer()
            
            Text(formatCurrency(value))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
    }
    
    private var glassMorphismBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.02),
                            Color.black.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    CustomerDetailView(
        customer: Customer(
            firstName: "John",
            lastName: "Smith",
            email: "john.smith@email.com",
            phone: "(555) 123-4567",
            address: "123 Oak Street",
            city: "Portland",
            state: "OR",
            zipCode: "97205"
        ),
        customerManager: CustomerManager()
    )
}