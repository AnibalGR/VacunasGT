import SwiftUI

struct BrandLogo: View {
    var size: CGFloat = 120
    var color: Color = .brandNavy
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Escudo
                Image(systemName: "shield.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .offset(x: -size * 0.15)
                
                // Niño (usando una combinación de símbolos para recrear el de la imagen)
                HStack(spacing: -size * 0.05) {
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.6, height: size * 0.8)
                        .offset(x: size * 0.2, y: size * 0.05)
                }
                
                // Cruz médica blanca sobre el escudo
                Image(systemName: "plus")
                    .font(.system(size: size * 0.3, weight: .bold))
                    .foregroundColor(.white)
                    .offset(x: -size * 0.2, y: 0)
            }
            .foregroundColor(color)
            
            Text("Niño Sano GT")
                .font(.system(size: size * 0.25, weight: .bold))
                .foregroundColor(color)
        }
    }
}


