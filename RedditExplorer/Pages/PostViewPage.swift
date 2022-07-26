//
//  PostViewPage.swift
//  RedditExplorer
//
//  Created by Metin Güler on 20.04.22.
//

import SwiftUI

struct PostViewPageViewModel {
    struct Comment {
        let id: String
        let author: String?
        let score: Int?
        let body: String
        let nestLevel: Int
        let isCollapsed: Bool
    }
}

struct PostViewPage: View {
    let post: Post
    let api = RedditAPI.shared
    @State var listings: [CommentListing]?
    @State var allComments: [PostViewPageViewModel.Comment] = []
    @State var collapsedComments: [String] = []
    
    func fetchComments() async {
        do {
            self.listings = try await api.getPost(subreddit: post.subreddit, id: post.id)
            await prepareComments()
            
        } catch let err {
            print("metinn", err.localizedDescription)
        }
    }
    
    func prepareComments() async {
        guard let commentListing = listings else { return }
        self.allComments = commentListing.dropFirst()
            .map({ $0.data.children })
            .flatMap({ $0.map { $0.data } })
            .flatMap { compactComments(comment: $0, nestLevel: 0) }
    }
    
    func compactComments(comment: Comment, nestLevel: Int) -> [PostViewPageViewModel.Comment] {
        let isCollapsed = isCollapsed(comment.id)
        
        var comments = [PostViewPageViewModel.Comment(id: comment.id,
                                                      author: comment.author,
                                                      score: comment.score,
                                                      body: comment.body ?? "",
                                                      nestLevel: nestLevel,
                                                      isCollapsed: isCollapsed)]
        
        if !isCollapsed, let replies = comment.replies?.data.children.map({ $0.data }) {
            for reply in replies {
                comments.append(contentsOf: compactComments(comment: reply, nestLevel: nestLevel + 1))
            }
        }
        
        return comments
    }
    
    func isCollapsed(_ commentId: String) -> Bool {
        return collapsedComments.contains { $0 == commentId }
    }
    
    var body: some View {
        ScrollView {
            PostCellView(post: post, limitVerticalSpace: false)
                .frame(maxWidth: .infinity,
                       alignment: .topLeading)
            
            RoundedRectangle(cornerRadius: 1.5)
                .foregroundColor(Color.gray)
                .frame(height: 1)
                .padding(.bottom, 5)
            
            if allComments.isEmpty {
                ProgressView()
            }
            
            ForEach(allComments, id: \.id) { comment in
                Button {
                    if isCollapsed(comment.id) {
                        collapsedComments.removeAll { $0 == comment.id }
                    } else {
                        collapsedComments.append(comment.id)
                    }
                    
                    Task { await prepareComments() }
                } label: {
                    CommentView(comment: comment, postAuthor: self.post.author)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal)
        .onAppear {
            Task { await fetchComments() }
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostViewPage(post: samplePost())
    }
}
