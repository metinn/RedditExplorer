//
//  PostViewPage.swift
//  RedditExplorer
//
//  Created by Metin Güler on 20.04.22.
//

import SwiftUI

class PostViewViewModel: ObservableObject {
    struct Row {
        let id: String
        var parents: Set<String>
        var depth: Int
        let object: RedditObject
    }
    
    let post: Post
    var api: RedditAPIProtocol.Type = RedditAPI.self
    @Published var rows: [Row]?
    @Published var collapsedComments: Set<String> = []
    @Published var moreCommentInFetch: String?
    
    init(post: Post) {
        self.post = post
    }
    
    func fetchComments() {
        Task {
            do {
                let newComments = try await api.getComments(subreddit: post.subreddit, id: post.id, commentId: nil)
                let newRows = flattenComments(comments: newComments)
                
                DispatchQueue.main.async {
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
                                            depth: 0,
                                            parents: []))
        }
        return rows
    }
    
    func getRows(comment: Comment, depth: Int, parents: Set<String>) -> [Row] {
        var rows = [Row]()
        let newRow = Row(id: comment.id,
                         parents: parents,
                         depth: depth,
                         object: comment)
        rows.append(newRow)
        
        if let replies = comment.replies?.data as? RedditListing {
            var newParents = parents
            newParents.insert(comment.id)
            
            for replyObject in replies.children {
                
                if let reply = replyObject.data as? Comment {
                    rows.append(contentsOf: getRows(comment: reply,
                                                    depth: depth + 1,
                                                    parents: newParents))
                }
                else if let more = replyObject.data as? MoreComment {
                    rows.append(Row(id: more.id,
                                    parents: newParents,
                                    depth: depth + 1,
                                    object: more))
                }
            }
        }
        
        return rows
    }
    
    func fetchMoreComment(idToFetch: String, row: PostViewViewModel.Row) async {
        guard moreCommentInFetch == nil else { return }
        DispatchQueue.main.async { self.moreCommentInFetch = row.id }
        defer { DispatchQueue.main.async { self.moreCommentInFetch = nil } }
        
        let commentId = idToFetch.replacingOccurrences(of: "t1_", with: "")
        do {
            // fetch parent comment with all replies
            guard
                let more = row.object as? MoreComment,
                let newComment = try await api.getComments(subreddit: post.subreddit,
                                                           id: post.id,
                                                           commentId: commentId)
                    .first
            else { return }
            
            // convert comments to rows
            let newRows = getRows(comment: newComment, depth: row.depth - 1, parents: row.parents)
                .filter { more.children.contains($0.id) }
                
            withAnimation {
                // remove parent comment and insert it back with all replies
                if let indexOfMore = rows?.firstIndex(where: { $0.id == row.id }) {
                    rows?.remove(at: indexOfMore)
                    rows?.insert(contentsOf: newRows, at: indexOfMore)
                }
            }
            
        } catch let err {
            print("Error", err.localizedDescription)
        }
    }

    func isCollapsed(_ commentId: String) -> Bool {
        return collapsedComments.contains { $0 == commentId }
    }
    
    func commentTapped(_ commentId: String) {
        withAnimation {
            if isCollapsed(commentId) {
                collapsedComments.remove(commentId)
            } else {
                collapsedComments.insert(commentId)
            }
        }
    }
}

//MARK: - View
struct PostViewPage: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @StateObject var vm: PostViewViewModel
    
    var body: some View {
        ScrollView {
            // Media Preview
            MediaPreviewView(vm: MediaPreviewViewModel(post: vm.post))
            
            // Post
            PostView(vm: PostViewModel(post: vm.post, limitVerticalSpace: false))
            
            links
            
            Divider()
            
            comments
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("r/" + vm.post.subreddit)
        .onAppear {
            vm.fetchComments()
        }
    }
    
    var links: some View {
        VStack {
            // user and subreddit link
            HStack {
                NavigationLink(destination: PostListPage(vm: PostListViewModel(listing: .user(vm.post.author)))) {
                    RoundedButtonView(iconName: "person.fill", title: vm.post.author)
                }
                
                NavigationLink(destination: PostListPage(vm: PostListViewModel(listing: .subreddit(vm.post.subreddit)))) {
                    RoundedButtonView(iconName: "square.stack.fill", title: vm.post.subreddit)
                }
            }
            .padding(.horizontal)
            
            // Post Link
            LinkButton(urlString: vm.post.url)
        }
    }
    
    @ViewBuilder
    var comments: some View {
        if let rows = vm.rows {
            LazyVStack(spacing: 0) {
                ForEach(rows, id: \.id) { row in
                    
                    if row.parents.isDisjoint(with: vm.collapsedComments) {
                        if let comment = row.object as? Comment {
                            buildComment(comment, row: row)
                        } else if let more = row.object as? MoreComment {
                            buildMoreComment(more, row: row)
                        }
                    }
                    
                }
            }
        } else {
            ProgressView()
        }
    }
    
    func buildComment(_ comment: Comment, row: PostViewViewModel.Row) -> some View {
        Button {
            vm.commentTapped(row.id)
        } label: {
            CommentView(comment: comment,
                        postAuthor: vm.post.author,
                        depth: row.depth,
                        isCollapsed: vm.isCollapsed(row.id))
        }.buttonStyle(.plain)
    }
    
    func buildMoreComment(_ more: MoreComment, row: PostViewViewModel.Row) -> some View {
        return MoreCommentView(count: more.count, depth: row.depth, isLoading: vm.moreCommentInFetch == more.id)
            .onTapGesture {
                Task { await vm.fetchMoreComment(idToFetch: more.parent_id, row: row) }
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
