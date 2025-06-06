import Foundation
import SwiftUI

@Observable
class Coordinator {
    
    static let shared = Coordinator()
    
    var navigationPath: [UUID] = []
    var sheetID: UUID?
    var fullScreenCoverID: UUID?
    
    private var views: [UUID: AnyView] = [:]
    
    func viewForID(_ id: UUID) -> AnyView {
        return views[id] ?? AnyView(EmptyView())
    }
    
    func navigateTo<V: View>(_ view: V) {
        let id = UUID()
        views[id] = AnyView(view)
        navigationPath.append(id)
    }
    
    func presentSheet<V: View>(_ view: V) {
        let id = UUID()
        views[id] = AnyView(view)
        sheetID = id
    }
    
    func presentFullScreen<V: View>(_ view: V) {
        let id = UUID()
        views[id] = AnyView(view)
        fullScreenCoverID = id
    }
    
    func dismissSheet() {
        sheetID = nil
    }
    
    func dismissFullScreen() {
        fullScreenCoverID = nil
    }
    
    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func reset() {
        self.navigationPath.removeAll()
    }
}

extension UUID: @retroactive Identifiable {
    public var id: UUID { self }
}

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
