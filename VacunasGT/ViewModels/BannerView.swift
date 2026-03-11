import SwiftUI

struct BannerView: View {
    let message: String
    var systemImage: String = "checkmark.circle.fill"
    var background: Color = .green

    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundColor(.white)
                Text(message)
                    .foregroundColor(.white)
                    .font(.subheadline.bold())
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(background.opacity(0.9))
            .cornerRadius(12)
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.spring(response: 0.35, dampingFraction: 0.9), value: isVisible)
        }
    }
}

#Preview {
    StatefulPreviewWrapper(true) { visible in
        VStack {
            BannerView(message: "Cambios guardados", isVisible: visible)
            Spacer()
        }
        .padding(.top, 40)
    }
}

// Helper for previews
struct StatefulPreviewWrapper<Content: View>: View {
    @State var value: Bool
    let content: (Binding<Bool>) -> Content
    init(_ value: Bool, content: @escaping (Binding<Bool>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }
    var body: some View { content($value) }
}
