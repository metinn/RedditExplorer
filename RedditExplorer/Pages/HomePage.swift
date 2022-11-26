//
//  HomePage.swift
//  RedditExplorer
//
//  Created by Metin Guler on 14.08.22.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    let tabList: [HomeViewModel.Tab] = [
        .list(.hot),
        .list(.top),
        .list(.rising),
        .subreddits]
    @Published var selectedTab: HomeViewModel.Tab = .list(.hot)
    
    var selectedImageURL: String = ""
    @Published var showImageViewer: Bool = false
    
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
        
        var icon: String {
            switch self {
            case .list(let sortBy):
                switch sortBy {
                case .hot:
                    return "flame"
                case .new:
                    return "paperplane"
                case .controversial:
                    return "questionmark.bubble"
                case .top:
                    return "chart.line.uptrend.xyaxis"
                case .rising:
                    return "sunrise"
                }
                
            case .subreddits:
                return "figure.fishing"
            }
        }
    }
    
    func showImage(_ imageUrl: String) {
        withAnimation {
            selectedImageURL = imageUrl
            showImageViewer = true
        }
    }
}

struct HomePage: View {
    @StateObject var vm = HomeViewModel()
    
    var body: some View {
        NavigationView {
            TabView(selection: $vm.selectedTab) {
                ForEach(vm.tabList, id: \.self) { tab in
                    switch tab {
                    case .list(let sortBy):
                        PostListPage(vm: PostListViewModel(sortBy: sortBy, subReddit: nil))
                            .tabItem {
                                Label(tab.title, systemImage: tab.icon)
                            }
                    case .subreddits:
                        SubredditsPage()
                            .tabItem {
                                Label(tab.title, systemImage: tab.icon)
                            }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .overlay {
            if vm.showImageViewer {
                ImageViewer(imageUrl: vm.selectedImageURL,
                            showImageViewer: $vm.showImageViewer)
            }
        }
        .environmentObject(vm)
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
