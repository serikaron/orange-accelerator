//
//  Utils.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/15.
//

import SwiftUI

extension Color {
    static var main: Color { .hex("FA8A28") }
    static var c000000: Color { .hex("000000") }
    static var c333333: Color { .hex("33333") }
    static var c666666: Color { .hex("666666") }
    
    static func hex(_ s: String) -> Color {
        Color(hex: s)
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct OrangeCheckBoxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            Image(configuration.isOn ? "checkbox.checked" : "checkbox.empty")
        })
    }
}

struct OrangeText: ViewModifier {
    let size: CGFloat
    let color: Color?
    let weight: Font.Weight
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight))
            .foregroundColor(color)
    }
}
extension View {
    func orangeText(size: CGFloat, color: Color?, weight: Font.Weight = .regular) -> some View {
        modifier(OrangeText(size: size, color: color, weight: weight))
    }
}

struct Utils_Previews: PreviewProvider {
    static var previews: some View {
        Color.main
            .frame(width: 20, height: 20)
            .previewDisplayName("Color")
        VStack {
            Toggle(isOn: .constant(true)) {}
                .toggleStyle(OrangeCheckBoxStyle())
            Toggle(isOn: .constant(false)) {}
                .toggleStyle(OrangeCheckBoxStyle())
        }
        .previewDisplayName("checkbox")
        Text("OrangeText")
            .orangeText(size: 12, color: .main, weight: .bold)
            .previewDisplayName("text")
    }
}
