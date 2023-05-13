//
//  MemberStoreView.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/8.
//

import SwiftUI

let ITEM_COUNT_PER_ROW = 2

struct MemberStoreView: View {
    @EnvironmentObject var nav: NavigationService
    @State private var items: [[MemberStoreItem]] = []
    
    @State private var selectedItemId = 0
    
    var body: some View {
        content
            .onAppear {
                Task {
                    do {
                        var all = try await MemberStoreItem.all
                        selectedItemId = all.first?.id ?? 0
                        all.reverse()
                        var row = [MemberStoreItem]()
                        while let item = all.popLast() {
                            row.append(item)
                            if row.count == ITEM_COUNT_PER_ROW {
                                items.append(row)
                                row = [MemberStoreItem]()
                            }
                        }
                        if !row.isEmpty {
                            items.append(row)
                        }
                    } catch {
                        Box.sendError(error)
                    }
                }
            }
    }
    
    private var content: some View {
            VStack(spacing: 0) {
                NavigationTitleView(title: "开通会员")
//                ScrollView {
//                    Group {
                        Spacer().frame(height: 55)
                        VStack(alignment: .leading, spacing: 30) {
                            ForEach(Array(zip(items.indices, items)), id: \.0) { _, row in
                                HStack(spacing: 30) {
                                    ForEach(row, id: \.id) {item in
                                        MemberStoreItemView(item: item, selectedItemId: $selectedItemId)
                                    }
                                }
                            }
                        }
                        Spacer().frame(height: 64)
//                    }
//                    .frame(maxWidth: .infinity)
//                }
                Button("立即支付") {
                    Task {
                        await MemberStoreItem.buy(with: selectedItemId)
                    }
                }
                .buttonStyle(OrangeButton())
                .frame(width: 295)
                //                    .padding(.horizontal, 40)
                Spacer().frame(height: 47)
                HStack(spacing: 0) {
                    Text("支付过程中如果遇到问题，请联系")
                        .orangeText(size: 13, color: .c000000)
                    Button {
                        nav.webPage = .customService
                    } label: {
                        Text("在线客服")
                            .orangeText(size: 13, color: .main)
                    }
                }
                Spacer()
            }
            .navigationBarHidden(true)
    }
}

fileprivate struct MemberStoreItemView: View {
    static let width: CGFloat = 155
    static let height: CGFloat = 110
    let item: MemberStoreItem
    @Binding var selectedItemId: Int
    private var selected: Bool {
        selectedItemId == item.id
    }
    
    private var fontColor: Color {
        selected ? .white : .main
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(item.name)
                .orangeText(size: 20, color: fontColor, weight: .bold)
            Spacer().frame(height: 16)
            Text("USD  \(String(format: "%.2f", item.price))")
                .orangeText(size: 15, color: fontColor)
            Spacer().frame(height: 8)
            Text(item.mark)
                .orangeText(size: 12, color: fontColor)
        }
        .padding(21.5)
        .frame(width: Self.width, height: Self.height)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.main, lineWidth: 1)
                    .frame(width: Self.width, height: Self.height)
                RoundedRectangle(cornerRadius: 10)
                    .fill(selected ? Color.main : Color.white)
            }
        )
        .onTapGesture {
            selectedItemId = item.id
        }
    }
}

struct MemberStoreView_Previews: PreviewProvider {
    static var previews: some View {
        MemberStoreView()
    }
}
