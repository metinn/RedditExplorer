//
//  PostViewPage.swift
//  RedditExplorer
//
//  Created by Metin Güler on 20.04.22.
//

import SwiftUI
import SwiftyJSON

struct PostViewPageViewModel {
    enum Kind: String {
        case comment = "t1"
        case more = "more"
    }
    
    struct Comment {
        let id: String
        let author: String?
        let score: Int?
        let body: String
        let nestLevel: Int
        let isCollapsed: Bool
        let kind: Kind
        let count: Int?
    }
}

struct PostViewPage: View {
    let post: Post
    let api = RedditAPI.shared
    @State var postData: JSON?
    @State var allComments: [PostViewPageViewModel.Comment] = []
    @State var collapsedComments: [String] = []
    
    func fetchComments() async {
        do {
            postData = try await api.getPost(subreddit: post.subreddit,
                                                 id: post.id,
                                                 after: nil,
                                                 limit: 20)
            await prepareComments()
            
        } catch let err {
            print("metinn", err.localizedDescription)
        }
    }
    
    func prepareComments() async {
        guard let commentDatas = postData?[1]["data"]["children"].array as? [JSON] else {
            return
        }
        
        allComments =  commentDatas.flatMap {
            compactComments(commentData: $0, nestLevel: 0)
        }
    }
    
    func compactComments(commentData: JSON, nestLevel: Int) -> [PostViewPageViewModel.Comment] {
        guard let kind = PostViewPageViewModel.Kind(rawValue: commentData["kind"].stringValue) else { return [] }
        let comment = commentData["data"]
        
        let isCollapsed = isCollapsed(comment["id"].stringValue)
        var comments = [PostViewPageViewModel.Comment(id: comment["id"].stringValue,
                                                      author: comment["author"].stringValue,
                                                      score: comment["score"].intValue,
                                                      body: comment["body"].stringValue,
                                                      nestLevel: nestLevel,
                                                      isCollapsed: isCollapsed,
                                                      kind: kind,
                                                      count: comment["count"].int)]
        
        if !isCollapsed, let replies = comment["replies"]["data"]["children"].array {
            for reply in replies {
                comments.append(contentsOf: compactComments(commentData: reply, nestLevel: nestLevel + 1))
            }
        }
        
        return comments
    }
    
    func isCollapsed(_ commentId: String) -> Bool {
        return collapsedComments.contains { $0 == commentId }
    }
    
    var body: some View {
        ScrollView {
            // post
            PostCellView(post: post, limitVerticalSpace: false)
                .frame(maxWidth: .infinity,
                       alignment: .topLeading)
            
            // seperator
            RoundedRectangle(cornerRadius: 1.5)
                .foregroundColor(Color.gray)
                .frame(height: 1)
                .padding(.bottom, 5)
            
            // progress
            if allComments.isEmpty {
                ProgressView()
            }
            
            // comments
            ForEach(allComments, id: \.id) { comment in
                buildComment(comment)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal)
        .onAppear {
            Task { await fetchComments() }
        }
    }
    
    func buildComment(_ comment: PostViewPageViewModel.Comment) -> some View {
        return Button {
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

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostViewPage(post: samplePost())
    }
}
