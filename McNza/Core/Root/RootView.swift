//
//  RootView.swift
//  McNza
//
//  Created by xqsadness4 on 5/6/25.
//


import SwiftUI

struct RootView<Content: View>: View {
    
    @AppStorage("FIRST_LOAD_APP") var FIRST_LOAD_APP = true
    
    @ViewBuilder var content: Content
    // View Properties
    @State private var overlayWindow: UIWindow?
    
    init(content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
                .transition(.move(edge: .trailing))
                .onAppear {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, overlayWindow == nil {
                        let window = PassthroughWindow(windowScene: windowScene)
                        window.backgroundColor = .clear
                        
                        // View Controller
                        let rootController = UIHostingController(rootView: OverlayGroup())
                        rootController.view.frame = windowScene.keyWindow?.frame ?? .zero
                        rootController.view.backgroundColor = .clear
                        window.rootViewController = rootController
                        
                        window.isHidden = false
                        window.isUserInteractionEnabled = true
                        window.tag = 1009
                        
                        overlayWindow = window
                    }
                }
        }
        .animation(.easeInOut, value: FIRST_LOAD_APP)
    }
}
