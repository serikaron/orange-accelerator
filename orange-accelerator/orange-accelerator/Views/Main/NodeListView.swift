//
//  NodeListView.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/8.
//

import SwiftUI

fileprivate struct NodeItem {
    let name: String
    let latency: Double?
}

fileprivate struct Section {
    let name: String
    let items: [NodeItem]
}

struct NodeListView: View {
    @State private var sections: [Section] = []
    
    var body: some View {
        content
            .onAppear {
                Task {
                    do {
                        let endpoints = try await EndpointList.all
                            .filtered(isVip: Account.current.isVip)
                            .ping()
                        var dict = [String: [NodeItem]]()
                        endpoints.forEach { endpoint in
                            if dict[endpoint.group] == nil {
                                dict[endpoint.group] = []
                            }
                            
                            var latency: Double = 0
                            switch endpoint.latency {
                            case .timeout: latency = 0
                            case let .ms(ms): latency = ms
                            case .none: latency = 0
                            }
                            
                            dict[endpoint.group]!.append(NodeItem(name: endpoint.name, latency: latency))
                        }
                        
                        for item in dict {
                            sections.append(Section(name: item.key, items: item.value))
                        }
                    }
                }
            }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            NavigationTitleView(title: "选择节点")
            VStack(spacing: 0) {
                searchInput
                Spacer().frame(height: 11)
                sloganView
                ForEach(Array(zip(sections.indices, sections)), id: \.0) { _, section in
                    SectionView(section: section)
                }
                Spacer()
            }
            .padding(.horizontal, 15)
        }
        .navigationBarHidden(true)
    }
    
    private var searchInput: some View {
        ZStack {
            Color(hex: "#EDEDED")
                .frame(height: 32)
                .cornerRadius(16)
            HStack(spacing: 0) {
                Spacer().frame(width: 20)
                Image("icon.search")
                Spacer().frame(width: 17)
                Text("搜索节点")
                    .orangeText(size: 15, color: .c999999)
                Spacer()
            }
        }
        .frame(height: 52)
    }
    
    private var sloganView: some View {
        VStack {
            HStack {
                Spacer().frame(width: 26)
                Image("main.ball")
                Spacer().frame(width: 12)
                VStack(alignment: .leading) {
                    Text("自动匹配最快网路")
                        .orangeText(size: 16, color: .c000000)
                    Text("随时随刻为您选择当前最快网路连接")
                        .orangeText(size: 12, color: .hex("#999999"))
                }
                Spacer()
            }
            Color(hex: "#EDEDED")
                .frame(height: 1)
        }
        .frame(height: 64)
    }
}

fileprivate struct SectionView: View {
    let section: Section
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer().frame(width: 7)
                Text(section.name)
                    .orangeText(size: 15, color: .c000000)
                Spacer()
            }
            VStack(spacing: 0) {
                ForEach(section.items, id: \.name) { item in
                    NodeItemView(item: item)
                }
            }
        }
    }
}

fileprivate struct NodeItemView: View {
    let item: NodeItem
    
    private var strength: Int {
        guard let latency = item.latency else { return 0 }
        switch latency {
        case 1...100: return 5
        case 101...300: return 4
        case 301...500: return 3
        case 501...700: return 2
        case 701...900: return 1
        default:
            return 0
        }
    }
    
    private var latency: String {
        "\(String(format: "%0.2f", item.latency ?? 0))ms"
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Color(hex: "#EDEDED")
                    .frame(height: 1)
            }
            HStack(spacing: 0) {
                Spacer().frame(width: 20)
                Image("main.ball")
                Spacer().frame(width: 16)
                Text(item.name)
                    .orangeText(size: 15, color: .c000000)
                Spacer()
                SignalIcon(strength: strength)
                Spacer().frame(width: 10)
                Text(latency)
                    .orangeText(size: 15, color: .c999999)
                Spacer().frame(width: 7)
            }
        }
        .frame(height: 64)
    }
}

fileprivate struct SignalIcon: View {
    let strength: Int
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("signal.gray")
            if (1...5).contains(strength) {
                Image("signal.\(strength)")
            }
        }
    }
}

struct NodeListView_Previews: PreviewProvider {
    static var previews: some View {
        NodeListView()
        SectionView(section: Section(name: "测试节点", items: [
            NodeItem(name: "测试节点", latency: 0),
            NodeItem(name: "测试节点", latency: 300),
        ]))
        NodeItemView(item: NodeItem(name: "测试节点", latency: 100))
        HStack {
            SignalIcon(strength: 0)
            SignalIcon(strength: 1)
            SignalIcon(strength: 2)
            SignalIcon(strength: 3)
            SignalIcon(strength: 4)
            SignalIcon(strength: 5)
        }
    }
}
