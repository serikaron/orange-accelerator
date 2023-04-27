//
//  ModePickerView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/27.
//

import SwiftUI

struct ModePickerView: View {
    @EnvironmentObject var service: V2Service
    
    var body: some View {
        HStack(spacing: 0) {
            makeButton(mode: .global, position: .left)
            makeButton(mode: .intellegent, position: .right)
        }
    }
    
    fileprivate func makeButton(mode: RouteMode, position: ModeButtonNormal.Position) -> some View {
        Button(mode.buttonTittle) {
            service.mode = mode
        }
            .buttonStyle(ModeButtonNormal(position: position, selected: service.mode == mode))
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

fileprivate struct ModeButtonNormal: ButtonStyle {
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
                    if selected {
                        RoundedCorner(radius: 20, corners: position.roundedCorners)
                            .fill(Color.main)
                    } else {
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
        ModePickerView()
            .environmentObject(V2Service())
    }
}
