import SwiftUI

// MARK: - View Modifiers

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.brandNavy.opacity(0.05), lineWidth: 1)
            )
    }
}

struct PrimaryButtonModifier: ViewModifier {
    var isLoading: Bool = false
    
    func body(content: Content) -> some View {
        content
            .font(.headline.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [.brandNavy, .brandLightBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(16)
            .shadow(color: Color.brandNavy.opacity(0.3), radius: 8, x: 0, y: 4)
            .opacity(isLoading ? 0.8 : 1.0)
    }
}

// MARK: - Extensions

extension View {
    func cardStyle() -> some View {
        self.modifier(CardModifier())
    }
    
    func primaryButtonStyle(isLoading: Bool = false) -> some View {
        self.modifier(PrimaryButtonModifier(isLoading: isLoading))
    }
}
