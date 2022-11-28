//
//  ContentView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 19.03.22.
//

import SwiftUI
import CachedAsyncImage

class PostListViewModel: ObservableObject {
    let sortBy: SortBy
    let subReddit: String?
    var isFetchInProgress = false
    
    private var api: RedditAPIProtocol.Type = RedditAPI.self
    
    @Published var posts: [Post] = []
    
    init(sortBy: SortBy, subReddit: String?) {
        self.sortBy = sortBy
        self.subReddit = subReddit
    }
    
    func fetchNextPosts() async {
        // TODO: better way? when scrolling to fast down, it is possible to get same request more then once
        guard !isFetchInProgress else { return }
        isFetchInProgress = true
        defer { isFetchInProgress = false }
        
        do {
            let newPosts = try await api.getPosts(sortBy, subreddit: subReddit, after: posts.last?.name, limit: 10)
            
            DispatchQueue.main.async {
                self.posts.append(contentsOf: newPosts)
            }
        } catch let err {
            print("Error: \(err.localizedDescription)")
        }
    }
    
    func refreshPosts() async {
        DispatchQueue.main.async {
            self.posts = []
        }
        // Wait a bit for user to see. Because we cannot cancel the drag gesture, user have to do it
        try? await Task.sleep(nanoseconds:  500 * 1000 * 1000)
        await fetchNextPosts()
    }
}

struct PostListPage: View {
    @Environment(\.colorScheme) var currentMode
    @StateObject var vm: PostListViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(vm.posts, id: \.id) { post in
                    buildPostCell(post)
                }
            }
            .onRefresh {
                await vm.refreshPosts()
            }
        }
        .onAppear {
            if vm.posts.isEmpty {
                Task { await vm.fetchNextPosts() }
            }
        }
    }
    
    func buildPostCell(_ post: Post) -> some View {
        return VStack {
            NavigationLink(destination: PostViewPage(vm: PostViewViewModel(post: post))) {
                PostCellView(vm: PostCellViewModel(post: post, limitVerticalSpace: true) { imageUrl in
                    homeVM.showImage(imageUrl)
                })
                .onAppear {
                    if vm.posts.last?.name == post.name {
                        Task { await vm.fetchNextPosts() }
                    }
                }
            }.buttonStyle(PlainButtonStyle())
            
            //Divider
            Color.gray
                .opacity(0.2)
                .frame(height: 10)
        }
    }
}

#if DEBUG
struct PostList_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            PostListPage(vm: PostListViewModel(sortBy: .hot, subReddit: nil))
                .preferredColorScheme($0)
        }
    }
}
#endif
