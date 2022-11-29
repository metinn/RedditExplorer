//
//  PostViewPage.swift
//  RedditExplorer
//
//  Created by Metin Güler on 20.04.22.
//

import SwiftUI

class PostViewViewModel: ObservableObject {
    struct Row {
        var parents: Set<String>
        var level: Int
        var comment: Comment
    }
    
    let post: Post
    var api: RedditAPIProtocol.Type = RedditAPI.self
//    @Published var commentList: [Comment]?
    @Published var rows: [Row]?
    @Published var collapsedComments: [String] = []
    
    init(post: Post) {
        self.post = post
    }
    
    func fetchComments() {
        Task {
            do {
                let newComments = try await api.getComments(subreddit: post.subreddit, id: post.id, commentId: nil)
                
                let newRows = flattenComments(comments: newComments)
                
                DispatchQueue.main.async {
//                    self.commentList = newComments
                    self.rows = newRows
                }
                
            } catch let err {
                print("Error", err.localizedDescription)
            }
        }
    }
    
    func flattenComments(comments: [Comment]) -> [Row] {
        var rows = [Row]()
        for comment in comments {
            rows.append(contentsOf: getRows(comment: comment,
                                            level: 0,
                                            parents: []))
        }
        return rows
    }
    
    func getRows(comment: Comment, level: Int, parents: Set<String>) -> [Row] {
        var rows = [Row]()
        let newRow = Row(parents: parents, level: level, comment: comment)
        rows.append(newRow)
        
        if let replies = comment.replies?.data as? RedditListing {
            for replyObject in replies.children {
                if let reply = replyObject.data as? Comment {
                    
                    var mparents = parents
                    mparents.insert(comment.id)
                    rows.append(contentsOf: getRows(comment: reply,
                                                    level: level + 1,
                                                    parents: mparents))
                }
//            else if let more = replyObject.data as? MoreComment {
//                buildMoreComment(more, depth: depth, topParentId: topParentId)
//            }
            }
        }
        
        return rows
    }
    
//    func fetchMoreComment(id: String) async {
//        do {
//            guard
//                let new = try await api.getComments(subreddit: post.subreddit, id: post.id, commentId: id).first,
//                let index = commentList?.firstIndex(where: { $0.id == new.id })
//            else { return }
//
//            commentList?[index] = new
//
//        } catch let err {
//            print("Error", err.localizedDescription)
//        }
//    }
//
    func isCollapsed(_ commentId: String) -> Bool {
        return collapsedComments.contains { $0 == commentId }
    }
    
    func commentTapped(_ commentId: String) {
        withAnimation {
            if isCollapsed(commentId) {
                collapsedComments.removeAll { $0 == commentId }
            } else {
                collapsedComments.append(commentId)
            }
            
        }
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
            
            if vm.rows == nil {
                ProgressView()
            }
            
            if let rows = vm.rows {
                LazyVStack(spacing: 0) {
                    ForEach(rows, id: \.comment.id) { row in
                        
                        if row.parents.isDisjoint(with: Set(vm.collapsedComments)) {
//                            Button {
//
//                            } label: {
                                CommentView(comment: row.comment,
                                            postAuthor: vm.post.author,
                                            depth: row.level,
                                            isCollapsed: vm.isCollapsed(row.comment.id))
                                .onTapGesture {
                                    vm.commentTapped(row.comment.id)
                                }
//                            }.buttonStyle(.plain)
                        }
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
            vm.commentTapped(comment.id)
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
//                Task { await vm.fetchMoreComment(id: topParentId) }
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
