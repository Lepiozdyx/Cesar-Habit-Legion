import SwiftUI

extension View {
    func bg() -> some View {
        self.background(
            Image(.bg)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

extension View {
    func roadBg() -> some View {
        self.background(
            Image(.roadBg)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}
