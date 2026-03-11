//
//  OnboardingView.swift
//  VacunasGT
//
//  Created by Anibal Gramajo on 30/01/26.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var nombre: String = ""
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "heart.text.square.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .symbolEffect(.bounce, value: isAnimating)
                
                Text("Bienvenido a Niño Sano GT")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Lleva el control de salud de tus hijos de forma fácil, segura y sin necesidad de internet.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("¿Cómo te llamas?")
                        .font(.headline)
                    TextField("Tu Nombre (ej. Mamá, Papá, María)", text: $nombre)
                        .textFieldStyle(.roundedBorder)
                        .padding(.top, 5)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: saveParent) {
                    Text("Comenzar")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(nombre.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(nombre.isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .onAppear {
                isAnimating = true
            }
            .navigationBarHidden(true)
        }
    }
    
    private func saveParent() {
        let parent = Parent(nombre: nombre)
        modelContext.insert(parent)
        // La app detectará automáticamente el cambio en la Query y cambiará de vista (o requerirá reinicio de vista raíz)
    }
}


