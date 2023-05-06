//
//  ModePickerView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/27.
//

import SwiftUI

struct ModePickerView: View {
    @Binding var routeMode: RouteMode
    
    var body: some View {
        HStack(spacing: 0) {
            makeButton(mode: .global, position: .left)
            makeButton(mode: .intellegent, position: .right)
        }
    }
    
    fileprivate func makeButton(mode: RouteMode, position: ModeButtonStyle.Position) -> some View {
        Button(mode.buttonTittle) {
            RouteMode.mode = mode
        }
            .buttonStyle(ModeButtonStyle(position: position, selected: routeMode == mode))
    }
}

fileprivate extension RouteMode {
    var buttonTittle: String {
        switch self {
        case .global: return "全局模式"
        case .intellegent: return "智能模式"
        }
    }
}

fileprivate struct ModeButtonStyle: ButtonStyle {
    enum Position {
        case left, right
        
        var roundedCorners: UIRectCorner {
            switch self {
            case .left: return [.topLeft, .bottomLeft]
            case .right: return [.topRight, .bottomRight]
            }
        }
    }
    
    let position: Position
    let selected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .orangeText(size: 15, color: selected ? .white : .main)
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(
                GeometryReader { geometry in
                    ZStack {
                        if selected {
                            RoundedCorner(radius: 20, corners: position.roundedCorners)
                                .fill(Color.main)
                        }
                        RoundedCorner(radius: 20, corners: position.roundedCorners)
                            .stroke(Color.main, lineWidth: 1)
                    }
                }
            )
    }
}

fileprivate struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ModePickerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ModePickerView(routeMode: .constant(.global))
                .previewLayout(.sizeThatFits)
            ModePickerView(routeMode: .constant(.intellegent))
                .previewLayout(.sizeThatFits)
        }
    }
}
