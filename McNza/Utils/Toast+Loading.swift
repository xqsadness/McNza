import SwiftUI
import Combine

@Observable
class LoadingManager: ObservableObject {
    static let shared = LoadingManager()
    var isLoading: Bool = false
    
    func showLoading() {
        withAnimation(.easeInOut) {
            isLoading = true
        }
    }
    
    func hideLoading() {
        withAnimation(.easeInOut) {
            isLoading = false
        }
    }
}

struct HUD: View {
    
    enum LoadingType{
        case dotsBouncing
        case lineSpacing
    }
    
    //Prop
    let dotSize: CGFloat
    let timming: CGFloat
    
    let animationTimer: Publishers.Autoconnect<Timer.TimerPublisher>
    let colorTimer: Publishers.Autoconnect<Timer.TimerPublisher>
    
    let type: LoadingType
    
    private let maxCounter = 3
    @State private var counter = -1
    @State private var colorIndex = 0
    
    //custom your color
    @State private var colors_0: [Color] = [.cyan, .green, .red]
    @State private var colors_1: [Color] = [.green, .red, .cyan]
    @State private var colors_2: [Color] = [.red, .cyan, .green]
    
    init(dotSize: CGFloat = 10.0, speed: CGFloat = 0.5, type: LoadingType) {
        self.dotSize = dotSize
        self.timming = speed / 2
        
        self.animationTimer = Timer.publish(every: timming, on: .main, in: .common).autoconnect()
        self.colorTimer = Timer.publish(every: timming * 3, on: .main, in: .common).autoconnect()
        
        self.type = type
    }
    
    var body: some View {
        VStack(spacing: 10){
            VStack(spacing: 5){
                switch type {
                case .dotsBouncing:
                    dotsViewBouncing()
                case .lineSpacing:
                    linesViewScaling()
                }
                
                Text("Loading")
                    .foregroundColor(.white)
                    .hSpacing(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.6))
        .edgesIgnoringSafeArea(.all)
    }
}

extension HUD{
    
    @ViewBuilder
    private func dotsViewBouncing() -> some View{
        RoundedRectangle(cornerRadius: 10)
            .fill(.white)
            .frame(width: 80, height: 80)
            .overlay {
                HStack{
                    ForEach(0..<maxCounter, id: \.self){ index in
                        let jump = dotSize / CGFloat(4)
                        let offsetY = counter == index ? -jump : jump
                        let colors: [Color] = index == 0 ? colors_0 : (index == 1 ? colors_1 : colors_2)
                        Circle()
                            .frame(width: dotSize, height: dotSize)
                            .foregroundStyle(colors[colorIndex])
                            .offset(y: offsetY)
                    }
                }
            }
            .onReceive(animationTimer, perform: { _ in
                withAnimation(.easeInOut(duration: timming * 2)){
                    counter = counter == maxCounter-1 ? 0 : counter+1
                }
            })
            .onReceive(colorTimer, perform: { _ in
                withAnimation(.easeIn){
                    colorIndex = colorIndex == colors_0.count-1 ? 0 : colorIndex+1
                }
            })
    }
    
    @ViewBuilder
    private func linesViewScaling() -> some View{
        RoundedRectangle(cornerRadius: 10)
            .fill(.white)
            .frame(width: 80, height: 80)
            .overlay {
                HStack{
                    ForEach(0..<maxCounter, id: \.self){ index in
                        let maxHeight = counter == index ? dotSize : dotSize * 3
                        let colors: [Color] = index == 0 ? colors_0 : (index == 1 ? colors_1 : colors_2)
                        RoundedRectangle(cornerRadius: dotSize/2)
                            .frame(maxWidth: dotSize, maxHeight: maxHeight)
                            .foregroundStyle(colors[colorIndex])
                    }
                }
            }
            .onReceive(animationTimer, perform: { _ in
                withAnimation(.easeInOut(duration: timming * 2)){
                    counter = counter == maxCounter-1 ? 0 : counter+1
                }
            })
            .onReceive(colorTimer, perform: { _ in
                withAnimation(.easeIn){
                    colorIndex = colorIndex == colors_0.count-1 ? 0 : colorIndex+1
                }
            })
    }
    
}

class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == view ? nil : view
    }
}

struct OverlayGroup: View {
    var loadingManager = LoadingManager.shared
    
    var body: some View {
        ZStack {
            ToastGroup()
            if loadingManager.isLoading {
                HUD(type: .lineSpacing)
            }
        }
    }
}

@Observable
class Toast {
    static let shared = Toast()
    fileprivate var toasts: [ToastItem] = []
    var position: Position = .bottom
    
    func present(title: String, symbol: String? = "", tint: Color = .primary, isUserInteractionEnabled: Bool = false, timing: ToastTime = .long, position: Position = .top){
        self.position = position
        withAnimation(.snappy) {
            toasts.append(ToastItem(title: title, symbol: symbol, tint: tint, isUserInteractionEnabled: isUserInteractionEnabled, timing: timing))
        }
    }
    
    func presentUnique(title: String, symbol: String? = "", tint: Color = .primary, isUserInteractionEnabled: Bool = false, timing: ToastTime = .long, position: Position = .top) {
        if !toasts.contains(where: { $0.title == title && $0.symbol == symbol }) {
            self.position = position
            withAnimation(.snappy) {
                toasts.append(ToastItem(title: title, symbol: symbol, tint: tint, isUserInteractionEnabled: isUserInteractionEnabled, timing: timing))
            }
        }
    }
}

struct ToastItem: Identifiable {
    let id: UUID = .init()
    /// Custom Properties
    var title: String
    var symbol: String?
    var tint: Color
    var isUserInteractionEnabled: Bool
    /// Timing
    var timing: ToastTime = .medium
}

enum ToastTime: CGFloat {
    case short = 1.0
    case medium = 2.0
    case long = 3.5
}

fileprivate struct ToastGroup: View {
    var model = Toast.shared
    
    var body: some View {
        GeometryReader{
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            ZStack{
                ForEach(model.toasts){ toast in
                    ToastView(size: size, item: toast)
                        .scaleEffect(scale(toast))
                        .offset(y: offsetY(toast))
                        .zIndex(Double(model.toasts.firstIndex(where: { $0.id == toast.id }) ?? 0))
                }
            }
            .padding(model.position == .bottom ? .bottom : .top, safeArea.top == .zero ? 15 : 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: model.position == .bottom ? .bottom : .top)
        }
    }
    
    func offsetY(_ item: ToastItem) -> CGFloat{
        let index = CGFloat(model.toasts.firstIndex(where: { $0.id == item.id }) ?? 0)
        let totalCount = CGFloat(model.toasts.count) - 1
        return (totalCount - index) >= 2 ? -20 : ((totalCount - index) * -10)
    }
    
    func scale(_ item: ToastItem) -> CGFloat{
        let index = CGFloat(model.toasts.firstIndex(where: { $0.id == item.id }) ?? 0)
        let totalCount = CGFloat(model.toasts.count) - 1
        return 1.0 - ((totalCount - index) >= 2 ? 0.2 : ((totalCount - index) * 0.1))
    }
}

fileprivate struct ToastView: View {
    var size: CGSize
    var item: ToastItem
    var model = Toast.shared
    //View props
    @State private var delayTask: DispatchWorkItem?
    
    var body: some View {
        HStack(spacing: 4){
            if let symbol = item.symbol, !symbol.isEmpty{
                Image(systemName: symbol)
                    .font(.title3)
                    .padding(.trailing, 10)
            }
            
            Text(item.title)
                .hSpacing(.center)
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .truncationMode(.middle)
        }
        .foregroundStyle(item.tint)
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(
            .backgroundToast
                .shadow(.drop(color: .primary.opacity(0.06), radius: 5,x: 5, y: 5))
                .shadow(.drop(color: .primary.opacity(0.06), radius: 5,x: -5, y: -5)), in: .capsule
        )
        .contentShape(Capsule())
        .onTapGesture {
            removeToast()
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onEnded({ value in
                    guard item.isUserInteractionEnabled else { return }
                    let endY = value.translation.height
                    let velocityY = value.velocity.height
                    
                    if model.position == .bottom{
                        if (endY + velocityY) > 100{
                            // Removing toast
                            removeToast()
                        }
                    }else{
                        if (endY + velocityY) < 100{
                            // Removing toast
                            removeToast()
                        }
                    }
                    
                })
        )
        .onAppear{
            guard delayTask == nil else { return }
            
            delayTask = .init(block: {
                removeToast()
            })
            
            if let delayTask{
                DispatchQueue.main.asyncAfter(deadline: .now() + item.timing.rawValue, execute: delayTask)
            }
        }
        //Limiting size
        .frame(maxWidth: size.width * 0.7)
        .transition(.offset(y: model.position == .bottom ? 150 : -150))
    }
    
    func removeToast(){
        if let delayTask{
            delayTask.cancel()
        }
        withAnimation(.snappy){
            Toast.shared.toasts.removeAll(where: { $0.id == item.id })
        }
    }
}

enum Position{
    case top
    case bottom
}

