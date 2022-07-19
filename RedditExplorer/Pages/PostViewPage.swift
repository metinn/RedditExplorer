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
        let body: String?
        let nestLevel: Int
    }
}

struct PostViewPage: View {
    let post: Post
    let api = RedditAPI()
    @State var listings: [CommentListing]?
    @State var allComments: [PostViewPageViewModel.Comment] = []
    @State var collapsedComments: [String] = []
    
    func fetchComments() async {
        do {
            self.listings = try await api.getPost(subreddit: post.subreddit, id: post.id)
            await processComments()
            
        } catch let err {
            print("metinn", err.localizedDescription)
        }
    }
    
    func processComments() async {
        guard let commentListing = listings else { return }
        self.allComments = commentListing.dropFirst()
            .map({ $0.data.children })
            .flatMap({ $0.map { $0.data } })
            .flatMap { compactComments(comment: $0, nestLevel: 0) }
    }
    
    func compactComments(comment: Comment, nestLevel: Int) -> [PostViewPageViewModel.Comment] {
        var comments = [PostViewPageViewModel.Comment(id: comment.id,
                                                      author: comment.author,
                                                      score: comment.score,
                                                      body: comment.body,
                                                      nestLevel: nestLevel)]
        
        if let replies = comment.replies?.data.children.map({ $0.data }), !isCollapsed(comment.id) {
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
            
            ForEach(allComments, id: \.id) { comment in
                CommentView(comment: comment, postAuthor: self.post.author, nestLevel: comment.nestLevel)
                .onTapGesture {
                    if isCollapsed(comment.id) {
                        collapsedComments.removeAll { $0 == comment.id }
                    } else {
                        collapsedComments.append(comment.id)
                    }
                    
                    Task { await processComments() }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal)
        .onAppear {
            Task { await fetchComments() }
        }
    }
}

struct CommentView: View {
    let comment: PostViewPageViewModel.Comment
    let postAuthor: String
    let nestLevel: Int

    var authorText: some View {
        if comment.author == postAuthor {
            return Text(comment.author ?? "-a-").foregroundColor(.accentColor).bold()
        } else {
            return Text(comment.author ?? "-a-")
        }
    }
    
    var body: some View {
        Group {
            HStack {
                /// Left border for nested comments
                if nestLevel > 0 {
                    RoundedRectangle(cornerRadius: 1.5)
                        .foregroundColor(Color(hue: 1.0 / Double(nestLevel), saturation: 1.0, brightness: 1.0))
                        .frame(width: 3)
                }
                /// Content
                VStack(alignment: .leading) {
                    HStack {
                        authorText
                        Image(systemName: "arrow.up")
                        Text("\(comment.score ?? 0)")
                    }
                        .font(.caption)
                        .opacity(0.75)
                    Text(comment.body ?? "")
                }
            }
            .padding(.leading, CGFloat(self.nestLevel * 10))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
            
//            /// Recursive comments
//            if showSubcomments && comment.replies != nil {
//                ForEach(comment.replies!.data.children.map { $0.data }, id: \.id) { reply in
////                    let isCollapsed = collapsedComments.contains { $0 == comment.id }
//                    CommentView(comment: reply, postAuthor: self.postAuthor, nestLevel: self.nestLevel + 1, showSubcomments: true)
//                }
//            }
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostViewPage(post: samplePost())
    }
}
