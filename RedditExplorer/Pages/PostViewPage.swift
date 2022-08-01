//
//  PostViewPage.swift
//  RedditExplorer
//
//  Created by Metin Güler on 20.04.22.
//

import SwiftUI

struct PostViewPage: View {
    let post: Post
    let api: RedditAPIProtocol = RedditAPI.shared
    @State var commentList: [Comment]?
    @State var collapsedComments: [String] = []
    
    func fetchComments() async {
        do {
            self.commentList = try await api.getComments(subreddit: post.subreddit, id: post.id, commentId: nil)
            
        } catch let err {
            print("Error", err.localizedDescription)
        }
    }
    
    func fetchMoreComment(id: String) async {
        do {
            guard
                let new = try await api.getComments(subreddit: post.subreddit, id: post.id, commentId: id).first,
                let index = commentList?.firstIndex(where: { $0.id == new.id })
            else { return }
            
            commentList?[index] = new
            
        } catch let err {
            print("Error", err.localizedDescription)
        }
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
            
            if commentList == nil {
                ProgressView()
            }
            
            if let comments = commentList {
                ForEach(comments, id: \.id) { comment in
                    buildComment(comment: comment, depth: 0, topParentId: comment.id)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal)
        .onAppear {
            Task { await fetchComments() }
        }
    }
    
    func buildComment(comment: Comment, depth: Int, topParentId: String) -> AnyView {
        let collapsed = isCollapsed(comment.id)
        
        // comment
        let commentView = Button {
            if isCollapsed(comment.id) {
                collapsedComments.removeAll { $0 == comment.id }
            } else {
                collapsedComments.append(comment.id)
            }
        } label: {
            CommentView(comment: comment,
                        postAuthor: self.post.author,
                        depth: depth,
                        isCollapsed: collapsed)
        }.buttonStyle(.plain)

        // replies
        guard !collapsed, let replies = comment.replies?.data as? RedditListing else {
            return AnyView(commentView)
        }
        
        return AnyView(VStack {
            commentView
            
            ForEach(replies.children, id: \.data.id)  { replyObject in
                if let reply = replyObject.data as? Comment {
                    buildComment(comment: reply, depth: depth + 1, topParentId: topParentId)
                    
                } else if let more = replyObject.data as? MoreComment {
                    buildMoreComment(more, depth: depth, topParentId: topParentId)
                }
            }
        })
    }
    
    func buildMoreComment(_ more: MoreComment, depth: Int, topParentId: String) -> some View {
        return MoreCommentView(moreComment: more, depth: depth + 1)
            .onTapGesture {
                Task { await fetchMoreComment(id: topParentId) }
            }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostViewPage(post: samplePost())
    }
}
