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
            
            let comments = listings.dropFirst().map({ $0.data.children }).flatMap({ $0.map { $0.data } })
            ForEach(comments, id: \.id) { comment in
                CommentView(comment: comment, postAuthor: self.post.author, nestLevel: 0)
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
    let comment: Comment
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
            /// Recursive comments
            if comment.replies != nil {
                ForEach(comment.replies!.data.children.map { $0.data }, id: \.id) { reply in
                    CommentView(comment: reply, postAuthor: self.postAuthor, nestLevel: self.nestLevel + 1)
                }
            }
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostViewPage(post: samplePost())
    }
}
