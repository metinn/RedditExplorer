//
//  ContentView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 19.03.22.
//

import SwiftUI
import CryptoKit
import CachedAsyncImage

class PostListViewModel: ObservableObject {
    let sortBy: SortBy
    let subReddit: String?
    
    private var api: RedditAPIProtocol.Type = RedditAPI.self
    
    var selectedImageURL: String = ""
    @Published var showImageViewer: Bool = false
    @Published var posts: [Post] = []
    
    init(sortBy: SortBy, subReddit: String?) {
        self.sortBy = sortBy
        self.subReddit = subReddit
    }
    
    func fetchNextPosts() async {
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
        posts = []
        // Wait a bit for user to see. Because we cannot cancel the drag gesture, user have to do it
        try? await Task.sleep(nanoseconds:  500 * 1000 * 1000)
        await fetchNextPosts()
    }
}

struct PostListPage: View {
    @Environment(\.colorScheme) var currentMode
    @StateObject var vm: PostListViewModel
    
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
        .fullScreenCover(isPresented: $vm.showImageViewer) {
            ImageViewer(vm: ImageViewerViewModel(imageUrl: vm.selectedImageURL),
                        showImageViewer: $vm.showImageViewer)
            .background(TransparentBackground())
        }
        .onAppear {
            if vm.posts.isEmpty {
                Task { await vm.fetchNextPosts() }
            }
        }
    }
    
    func buildPostCell(_ post: Post) -> some View {
        return VStack {
            NavigationLink(destination: PostViewPage(post: post)) {
                PostCellView(post: post, limitVerticalSpace: true) { imageUrl in
                    withAnimation {
                        vm.selectedImageURL = imageUrl
                        vm.showImageViewer = true
                    }
                }
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

// TODO: seems fragile, better way?
// https://stackoverflow.com/a/72124662/1423048
struct TransparentBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
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
