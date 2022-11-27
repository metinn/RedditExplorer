//
//  PostViewPage.swift
//  RedditExplorer
//
//  Created by Metin Güler on 20.04.22.
//

import SwiftUI

class PostViewViewModel: ObservableObject {
    let post: Post
    var api: RedditAPIProtocol.Type = RedditAPI.self
    @Published var commentList: [Comment]?
    @Published var collapsedComments: [String] = []
    
    init(post: Post) {
        self.post = post
    }
    
    func fetchComments() {
        Task {
            do {
                let newComments = try await api.getComments(subreddit: post.subreddit, id: post.id, commentId: nil)
                DispatchQueue.main.async {
                    self.commentList = newComments
                }
                
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
}

struct PostViewPage: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @StateObject var vm: PostViewViewModel
    
    var body: some View {
        ScrollView {
            PostCellView(vm: PostCellViewModel(post: vm.post, limitVerticalSpace: false) { imageUrl in
                homeVM.showImage(imageUrl)
            })
            
            // Link button
            Button {
                homeVM.showWebView(vm.post.url)
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
            
            if vm.commentList == nil {
                ProgressView()
            }
            
            if let comments = vm.commentList {
                LazyVStack(spacing: 0) {
                    ForEach(comments, id: \.id) { comment in
                        buildComment(comment: comment, depth: 0, topParentId: comment.id)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.fetchComments()
        }
    }
    
    // TODO: Remove AnyView if possible (is anyview giving us performance hit?)
    // WWDC21 Demystfiy swiftui 14:00 suggests adding @ViewBuilder but it does not work as long as it recursively calls its self
    func buildComment(comment: Comment, depth: Int, topParentId: String) -> AnyView {
        let collapsed = vm.isCollapsed(comment.id)
        
        // comment
        let commentView = Button {
            if vm.isCollapsed(comment.id) {
                vm.collapsedComments.removeAll { $0 == comment.id }
            } else {
                vm.collapsedComments.append(comment.id)
            }
        } label: {
            CommentView(comment: comment,
                        postAuthor: vm.post.author,
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
                Task { await vm.fetchMoreComment(id: topParentId) }
            }
    }
}

#if DEBUG
struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostViewPage(vm: PostViewViewModel(post: samplePost()))
    }
}
#endif
