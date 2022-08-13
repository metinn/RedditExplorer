//
//  ContentView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 19.03.22.
//

import SwiftUI
import CryptoKit
import CachedAsyncImage

struct PostListPage: View {
    var api: RedditAPIProtocol.Type = RedditAPI.self
    @Environment(\.colorScheme) var currentMode
    @State var posts: [Post] = []
    
    @State var showImageViewer: Bool = false
    @State var selectedImageURL: String = ""
    
    func fetchNextPosts() async {
        do {
            let newPosts = try await api.getHotPosts(after: posts.last?.name, limit: 10)
            posts.append(contentsOf: newPosts)
        } catch let err {
            print("Error: \(err.localizedDescription)")
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView{
                LazyVStack {
                    ForEach(posts, id: \.id) { post in
                        buildPostCell(post)
                    }
                }
                .onRefresh {
                    posts = []
                    // Wait a bit for user to see. Because we cannot cancel the drag gesture, user have to do it
                    try? await Task.sleep(nanoseconds:  500 * 1000 * 1000)
                    await fetchNextPosts()
                }
            }
            .navigationBarTitle("Reddit")
        }
        .navigationViewStyle(.stack)
        .onAppear {
            Task { await fetchNextPosts() }
        }
        .overlay {
            if showImageViewer {
                ImageViewer(vm: ImageViewerViewModel(imageUrl: selectedImageURL),
                            showImageViewer: $showImageViewer)
            }
        }
    }
    
    func buildPostCell(_ post: Post) -> some View {
        return VStack {
            NavigationLink(destination: PostViewPage(post: post)) {
                PostCellView(post: post, limitVerticalSpace: true) { imageUrl in
                    withAnimation {
                        selectedImageURL = imageUrl
                        showImageViewer = true
                    }
                }
                .onAppear {
                    if posts.last?.name == post.name {
                        Task { await fetchNextPosts() }
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
            PostListPage(posts: [samplePost()])
                .preferredColorScheme($0)
        }
    }
}
#endif
