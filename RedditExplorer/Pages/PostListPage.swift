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
    let api: RedditAPIProtocol = RedditAPI.shared
    @Environment(\.colorScheme) var currentMode
    @State var posts: [Post] = []
    
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
            }
            .navigationBarTitle("Reddit")
        }
        .navigationViewStyle(.stack)
        .onAppear {
            Task { await fetchNextPosts() }
        }
    }
    
    func buildPostCell(_ post: Post) -> some View {
        return VStack {
            NavigationLink(destination: PostViewPage(post: post)) {
                PostCellView(post: post, limitVerticalSpace: true)
                    .padding(.horizontal)
                    .onAppear {
                        if posts.last?.name == post.name {
                            Task { await fetchNextPosts() }
                        }
                    }
            }.buttonStyle(PlainButtonStyle())
            
            Divider().padding(.zero)
        }
    }
}

struct PostList_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            PostListPage(posts: [samplePost()])
                .preferredColorScheme($0)
        }
    }
}
