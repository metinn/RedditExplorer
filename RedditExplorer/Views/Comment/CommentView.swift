//
//  CommentView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 19.07.22.
//

import SwiftUI

struct CommentView: View {
    let comment: Comment
    let postAuthor: String
    let depth: Int
    let isCollapsed: Bool
    
    var authorText: some View {
        if comment.author == postAuthor {
            return Text(comment.author).foregroundColor(.accentColor).bold()
        } else {
            return Text(comment.author)
        }
    }
    
    var body: some View {
        CommentCell(depth: depth, isCollapsed: isCollapsed) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: Constants.Space.IconGroup) {
                    authorText
                    HStack(spacing: Constants.Space.IconText) {
                        Image(systemName: "arrow.up")
                        Text("\(comment.score)")
                    }
                }
                .font(.caption)
                .opacity(0.75)
                
                Text(isCollapsed ? "" : comment.body)
            }
            .padding(.vertical, 6)
        }
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            CommentView(comment: Comment(id: UUID().uuidString, author: "you", score: 122, body: "A Comment", replies: nil), postAuthor: "me", depth: 0, isCollapsed: false)
                .previewLayout(.sizeThatFits)
            
            CommentView(comment: Comment(id: UUID().uuidString, author: "you", score: 76, body: "A Comment", replies: nil), postAuthor: "me", depth: 2, isCollapsed: false)
                .previewLayout(.sizeThatFits)
        }
    }
}
