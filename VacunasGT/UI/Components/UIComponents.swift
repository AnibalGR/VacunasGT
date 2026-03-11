import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            // Usamos un simple overlay de alineación para Custom Placeholder o 
            // directamente le pasamos la info si permite styling.
            // Para mantener compatibilidad pasamos placeholder a TextField
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.secondary)
                        // Evita que el placeholder intercepte toques
                        .allowsHitTesting(false)
                }
                TextField("", text: $text)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.12), lineWidth: 1)
        )
    }
}

struct CustomSecureField: View {
    @Binding var text: String
    @Binding var isVisible: Bool
    var placeholder: String
    var icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.secondary)
                        // Evita que el placeholder intercepte toques
                        .allowsHitTesting(false)
                }
                
                if isVisible {
                    TextField("", text: $text)
                        .foregroundColor(.primary)
                } else {
                    SecureField("", text: $text)
                        .foregroundColor(.primary)
                }
            }
            
            Button(action: { isVisible.toggle() }) {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.12), lineWidth: 1)
        )
    }
}
