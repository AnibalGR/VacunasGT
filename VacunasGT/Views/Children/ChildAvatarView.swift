//
//  ChildAvatarView.swift
//  VacunasGT
//
//  Vista reutilizable que muestra la foto de perfil de un niño.
//  Si no existe foto, muestra un avatar con las iniciales del nombre.
//

import SwiftUI
import SwiftData

struct ChildAvatarView: View {
    let childUUID: String
    let name: String
    var photoURL: String? = nil
    var size: CGFloat = 80
    var showEditBadge: Bool = false

    @Query private var photos: [ChildPhoto]

    private var photo: ChildPhoto? {
        photos.first { $0.childUUID == childUUID }
    }

    private var initials: String {
        let parts = name.split(separator: " ")
        let chars = parts.prefix(2).compactMap(\.first).map(String.init)
        return chars.joined().uppercased()
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let urlString = photoURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            localOrInitialsView
                        case .empty:
                            ProgressView()
                                .frame(width: size, height: size)
                        @unknown default:
                            localOrInitialsView
                        }
                    }
                } else {
                    localOrInitialsView
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 3))
            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)

            if showEditBadge {
                Image(systemName: "camera.circle.fill")
                    .font(.system(size: size * 0.32))
                    .foregroundColor(.brandNavy)
                    .background(Color.white.clipShape(Circle()))
                    .offset(x: 2, y: 2)
            }
        }
    }

    @ViewBuilder
    private var localOrInitialsView: some View {
        if let data = photo?.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            // Avatar con iniciales
            Circle()
                .fill(Color.brandNavy.opacity(0.18))
                .overlay(
                    Text(initials)
                        .font(.system(size: size * 0.35, weight: .bold))
                        .foregroundColor(.brandNavy)
                )
        }
    }
}
