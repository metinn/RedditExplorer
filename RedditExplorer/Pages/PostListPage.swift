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
    @Environment(\.colorScheme) var currentMode
    @State var posts: [Post] = []
    
    func fetchListings() async {
        do {
            let listing = try await RedditAPI().getHotPosts()
            posts = listing.data.children.map { $0.data }
        } catch let err {
            print("Error: \(err.localizedDescription)")
        }
    }
    
    var body: some View {
        NavigationView {
            List(posts, id: \.id) { post in
                NavigationLink(destination: PostViewPage(post: post)) {
                    PostCellView(post: post, limitVerticalSpace: true)
                }
            }
            .listStyle(InsetListStyle())
            .navigationBarTitle("Reddit")
        }
        .onAppear {
            Task { await fetchListings() }
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
