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
        let kind: RedditObjectType
        let count: Int?
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
            self.listings = try await api.getPost(subreddit: post.subreddit, id: post.id, after: nil, limit: nil)
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
            .flatMap { compactComments(comment: $0, nestLevel: 0, kind: .comment) }
    }
    
    func compactComments(comment: Comment, nestLevel: Int, kind: RedditObjectType) -> [PostViewPageViewModel.Comment] {
        let isCollapsed = isCollapsed(comment.id)
        
        var comments = [PostViewPageViewModel.Comment(id: comment.id,
                                                      author: comment.author,
                                                      score: comment.score,
                                                      body: comment.body ?? "",
                                                      nestLevel: nestLevel,
                                                      isCollapsed: isCollapsed,
                                                      kind: kind,
                                                      count: nil)]
        
        if !isCollapsed, let listing = comment.replies?.data as? RedditListing {
            for child in listing.children {
                if let reply = child.data as? Comment {
                    comments.append(contentsOf: compactComments(comment: reply, nestLevel: nestLevel + 1, kind: child.kind))
                } else if let more = child.data as? CommentMore {
                    let moreComment = PostViewPageViewModel.Comment(id: more.id,
                                                                    author: nil,
                                                                    score: nil,
                                                                    body: "",
                                                                    nestLevel: nestLevel,
                                                                    isCollapsed: isCollapsed,
                                                                    kind: child.kind,
                                                                    count: more.count)
                    comments.append(moreComment)
                }
            }
        }
        
        return comments
    }
    
    func isCollapsed(_ commentId: String) -> Bool {
        return collapsedComments.contains { $0 == commentId }
    }
    
    func onCommentTap(_ comment: PostViewPageViewModel.Comment) {
        if isCollapsed(comment.id) {
            collapsedComments.removeAll { $0 == comment.id }
        } else {
            collapsedComments.append(comment.id)
        }
        
        Task { await prepareComments() }
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
                    onCommentTap(comment)
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
