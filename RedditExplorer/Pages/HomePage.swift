//
//  HomePage.swift
//  RedditExplorer
//
//  Created by Metin Guler on 14.08.22.
//

import SwiftUI
import AVKit

class HomeViewModel: ObservableObject {
    enum Tab: Hashable {
        case list(SortBy)
        case subreddits
        
        var title: String {
            switch self {
            case .list(let sortBy):
                return sortBy.rawValue.capitalized
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
                default:
                    return "square"
                }
                
            case .subreddits:
                return "figure.fishing"
            }
        }
    }
    
    var selectedImageURL: String = ""
    @Published var showImageViewer: Bool = false
    
    var webUrl: String = ""
    @Published var showWebView = false
    
    var player: AVPlayer? = nil
    @Published var showVideoFullscreen = false
    
    func showImage(_ imageUrl: String) {
        withAnimation {
            selectedImageURL = imageUrl
            showImageViewer = true
        }
    }
    
    func showWebView(_ url: String) {
        webUrl = url
        showWebView = true
    }
    
    func showVideo(_ videoUrl: String) {
        guard let url = URL(string: videoUrl) else { return }
        
        player = AVPlayer(url: url)
        showVideoFullscreen = true
    }
}

struct HomePage: View {
    @StateObject var vm = HomeViewModel()
    
    var body: some View {
        TabView {
            NavigationView {
                PostListPage(vm: PostListViewModel(listing: .subreddit(nil)))
            }
            .tabItem {
                Label("Hot", systemImage: "flame")
            }
        
            NavigationView {
                SubredditsPage()
                    .navigationTitle("Subreddits")
            }
            .tabItem {
                Label("Subreddits", systemImage: "figure.fishing")
            }
        }
        .overlay {
            if vm.showImageViewer {
                ImageViewer(imageUrl: vm.selectedImageURL,
                            showImageViewer: $vm.showImageViewer)
            }
        }
        .sheet(isPresented: $vm.showWebView) {
            if let url = URL(string: vm.webUrl) {
                WebView(url: url)
            }
        }
        .sheet(isPresented: $vm.showVideoFullscreen) {
            VideoPlayer(player: vm.player!)
                .ignoresSafeArea()
                .onAppear {
                    vm.player?.play()
                }
                .onDisappear {
                    vm.player?.pause()
                    vm.player = nil
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
