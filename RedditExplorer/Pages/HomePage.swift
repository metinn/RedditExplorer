//
//  HomePage.swift
//  RedditExplorer
//
//  Created by Metin Guler on 14.08.22.
//

import SwiftUI

struct HomePage: View {
    let tabList: [SortBy] = [.hot, .top, .rising]
    @State var selectedTabs = Set<SortBy>()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Tabs
                    TabView {
                        ForEach(tabList, id: \.self) { tab in
                            PostListPage(list: tab)
                                .onAppear {
                                    selectedTabs.insert(tab)
                                }
                                .onDisappear {
                                    selectedTabs.remove(tab)
                                }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Tab bar,
                    VStack {
                        Spacer()
                        
                        tabBar(geometry)
                    }
                }
                .navigationBarHidden(true)
                .ignoresSafeArea()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    func tabBar(_ geometry: GeometryProxy) -> some View {
        return HStack {
            ForEach(tabList, id: \.self) { tab in
                Text(tab.rawValue)
                    .opacity(selectedTabs.contains(tab) ? 1.0 : 0.4)
            }
        }
        .padding()
        .frame(height: 40)
        .background(.white)
        .cornerRadius(10)
        .shadow(radius: 10)
        .padding(.bottom, geometry.safeAreaInsets.bottom + 30)
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
