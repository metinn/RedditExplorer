//
//  PostViewPage.swift
//  RedditExplorer
//
//  Created by Metin Güler on 20.04.22.
//

import SwiftUI

struct PostViewPage: View {
    let post: Post
    var api: RedditAPIProtocol.Type = RedditAPI.self
    @State var commentList: [Comment]?
    @State var collapsedComments: [String] = []
    @State private var showWebView = false
    
    @State var showImageViewer: Bool = false
    @State var selectedImageURL: String = ""
    
    func fetchComments() {
        Task {
            do {
                self.commentList = try await api.getComments(subreddit: post.subreddit, id: post.id, commentId: nil)
                
            } catch let err {
                print("Error", err.localizedDescription)
            }
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
            PostCellView(post: post, limitVerticalSpace: false, autoPlayVideo: true) { imageUrl in
                withAnimation {
                    selectedImageURL = imageUrl
                    showImageViewer = true
                }
            }
            
            // Link button
            Button {
                self.showWebView = true
            } label: {
                Text("Open Link")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .border(.blue, width: 1)
            }
            .padding(.horizontal)
            
            RoundedRectangle(cornerRadius: 1.5)
                .foregroundColor(Color.gray)
                .frame(height: 1)
            
            if commentList == nil {
                ProgressView()
            }
            
            if let comments = commentList {
                LazyVStack(spacing: 0) {
                    ForEach(comments, id: \.id) { comment in
                        buildComment(comment: comment, depth: 0, topParentId: comment.id)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(showImageViewer)
        .onAppear {
            fetchComments()
        }
        .overlay {
            if showImageViewer {
                ImageViewer(vm: ImageViewerViewModel(imageUrl: selectedImageURL),
                            showImageViewer: $showImageViewer)
            }
        }
        .sheet(isPresented: $showWebView) {
            WebView(url: URL(string: post.url)!)
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
        
        return AnyView(VStack(spacing: 0) {
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

#if DEBUG
struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostViewPage(post: samplePost())
    }
}
#endif
