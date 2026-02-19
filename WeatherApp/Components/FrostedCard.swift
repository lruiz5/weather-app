import SwiftUI

struct FrostedCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(.white.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

extension View {
    func frostedCard() -> some View {
        modifier(FrostedCard())
    }
}
