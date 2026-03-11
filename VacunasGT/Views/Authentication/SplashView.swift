import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity = 0.5
    
    var body: some View {
        ZStack {
            // Fondo absoluto para evitar espacios en blanco por safe area
            Rectangle()
                .fill(Color.brandBackground)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                BrandLogo(size: 160)
                    .scaleEffect(isActive ? 1.0 : 0.8)
                    .opacity(isActive ? 1.0 : 0.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isActive)
                
                Spacer()
                
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.3)
                        .tint(.brandNavy)
                    
                    Text("Protegiendo el futuro de Guatemala")
                        .font(.footnote.bold())
                        .foregroundColor(.brandNavy.opacity(0.6))
                        .tracking(1)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation {
                isActive = true
            }
        }
        .statusBarHidden(true)
    }
}


