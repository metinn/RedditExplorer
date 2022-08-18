//
//  HomePage.swift
//  RedditExplorer
//
//  Created by Metin Guler on 14.08.22.
//

import SwiftUI

class HomeViewModel {
    enum Tab: Hashable {
        case list(SortBy)
        case subreddits
        
        var title: String {
            switch self {
            case .list(let sortBy):
                return sortBy.rawValue
            case .subreddits:
                return "Subreddits"
            }
        }
    }
}

struct HomePage: View {
    let tabList: [HomeViewModel.Tab] = [
        .list(.hot),
        .list(.top),
        .list(.rising),
        .subreddits]
    @State var selectedTab: HomeViewModel.Tab = .list(.hot)
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Tabs
                    TabView(selection: $selectedTab) {
                        ForEach(tabList, id: \.self) { tab in
                            switch tab {
                            case .list(let sortBy):
                                PostListPage(vm: PostListViewModel(sortBy: sortBy, subReddit: nil))
                            case .subreddits:
                                SubredditsPage()
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
                Text(tab.title)
                    .opacity(selectedTab == tab ? 1.0 : 0.4)
                    .onTapGesture {
                        selectedTab = tab
                    }
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
