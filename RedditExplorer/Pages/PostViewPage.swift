//
//  PostViewPage.swift
//  RedditExplorer
//
//  Created by Metin Güler on 20.04.22.
//

import SwiftUI

struct PostViewPage: View {
    let post: Post
    let api = RedditAPI()
    @State var listings: [CommentListing] = []
    @State var collapsedComments: [String] = []
    
    func fetchComments() async {
        do {
            listings = try await api.getPost(subreddit: post.subreddit, id: post.id)
        } catch let err {
            print("metinn", err.localizedDescription)
        }
    }
    
    var body: some View {
        ScrollView {
            PostCellView(post: post, limitVerticalSpace: false)
                .frame(maxWidth: .infinity,
                       alignment: .topLeading)
            
            let comments = listings.dropFirst()
                .map({ $0.data.children })
                .flatMap({ $0.map { $0.data } })
            
            ForEach(comments, id: \.id) { comment in
                let isCollapsed = collapsedComments.contains { $0 == comment.id }
                buildCommentView(comment: comment, isCollapsed: isCollapsed)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal)
        .onAppear {
            Task { await fetchComments() }
        }
    }
    
    func buildCommentView(comment: Comment, isCollapsed: Bool) -> some View {
        return VStack{
            CommentView(comment: comment, postAuthor: self.post.author, nestLevel: 0, showSubcomments: !isCollapsed)
            .onTapGesture {
                if isCollapsed {
                    collapsedComments.removeAll { $0 == comment.id }
                } else {
                    collapsedComments.append(comment.id)
                }
            }
            CommentView(comment: comment, postAuthor: self.post.author, nestLevel: 0, showSubcomments: !isCollapsed)
            .onTapGesture {
                if isCollapsed {
                    collapsedComments.removeAll { $0 == comment.id }
                } else {
                    collapsedComments.append(comment.id)
                }
            }
        }
    }
}

struct CommentView: View {
    let comment: Comment
    let postAuthor: String
    let nestLevel: Int
    let showSubcomments: Bool

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
