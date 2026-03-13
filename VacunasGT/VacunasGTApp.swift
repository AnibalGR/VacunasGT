//
//  VacunasGTApp.swift
//  VacunasGT
//
//  Created by Anibal Gramajo on 30/01/26.
//

import SwiftUI
import SwiftData

@main
struct VacunasGTApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Parent.self, // Agregado
            Child.self,
            Vaccine.self,
            VaccinationRecord.self,
            GrowthRecord.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var childrenViewModel = ChildrenViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentViewWrapper()
                .environmentObject(authViewModel)
                .environmentObject(childrenViewModel)
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}

struct ContentViewWrapper: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Query private var parents: [Parent]
    @State private var isSplashScreenActive = true
    
    var body: some View {
        if isSplashScreenActive {
            SplashView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            isSplashScreenActive = false
                        }
                    }
                }
        } else if !authViewModel.isAuthenticated {
            LoginView()
        } else {
            // Usuario Autenticado -> Mostrar TabView (Por ahora obviamos Onboarding local si no es necesario)
            MainTabView()
        }
    }
}

