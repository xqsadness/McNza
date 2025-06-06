import SwiftUI

extension View{
    
    func hSpacing(_ alignment: Alignment) -> some View{
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vSpacing(_ alignment: Alignment) -> some View{
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
    
    func interactiveScrollTransition(blur: CGFloat = 10) -> some View {
        self.scrollTransition(topLeading: .interactive, bottomTrailing: .interactive) { view, phase in
            view
                .opacity(1 - (phase.value < 0 ? -phase.value : phase.value))
                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                .blur(radius: phase.isIdentity ? 0 : blur)
        }
    }
}
