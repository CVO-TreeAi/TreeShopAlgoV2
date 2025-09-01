import SwiftUI

struct MainTabView: View {
    @StateObject private var customerManager = CustomerManager()
    
    var body: some View {
        TabView {
            // Calculator Tab
            ContentView()
                .environmentObject(customerManager)
                .tabItem {
                    Label("Calculator", systemImage: "tree.fill")
                }
            
            // Customers Tab
            NavigationView {
                CustomerListView()
                    .environmentObject(customerManager)
            }
            .tabItem {
                Label("Customers", systemImage: "person.2.fill")
            }
        }
        .accentColor(Color(red: 0.30, green: 0.69, blue: 0.31))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}