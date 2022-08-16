//
//  OnRefresh.swift
//  RedditExplorer
//
//  Created by Metin Guler on 13.08.22.
//

import SwiftUI

struct OnRefresh: ViewModifier {
    let action: () async -> Void
    
    @State var startOffset: CGFloat?
    @State var isViewApperred = false
    @State var isRefreshing = false
    
    func body(content: Content) -> some View  {
        content
            .background(GeometryReader { geo in
                ZStack {
                    ProgressView()
                            .frame(height: 50, alignment: .center)
                            .frame(maxWidth: .infinity)
                            .offset(y: -50)
                            .opacity(isRefreshing ? 1 : 0)
                            .preference(key: OffsetKey.self,
                                    value: geo.frame(in: .global).origin.y)
                }
            })
            .onPreferenceChange(OffsetKey.self) { originY in
                // TODO: Fragile! Taking the first value after view appearred
                if isViewApperred && startOffset == nil {
                    startOffset = originY
                }

                if let startOffset = startOffset, (originY - startOffset) > 100 {
                    if !isRefreshing {
                        isRefreshing = true
                        Task {
                            await action()
                            await MainActor.run {
                                isRefreshing = false
                            }
                        }
                    }
                }
            }
            .onAppear {
                isViewApperred = true
            }
            .onDisappear {
                isViewApperred = false
                startOffset = nil
            }
    }
    
    struct OffsetKey: PreferenceKey {
        public typealias Value = CGFloat
        public static var defaultValue = CGFloat.zero
        public static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
}

extension View {
    func onRefresh(action: @escaping () async -> Void) -> some View {
        modifier(OnRefresh(action: action))
    }
}
