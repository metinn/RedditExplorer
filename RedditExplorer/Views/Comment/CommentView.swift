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
            HStack {
                authorText
                Image(systemName: "arrow.up")
                Text("\(comment.score)")
            }
            .font(.caption)
            .opacity(0.75)
            
            Text(isCollapsed ? "" : comment.body)
        }
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            CommentView(comment: Comment(id: UUID().uuidString, author: "you", score: 122, body: "A Comment", replies: nil), postAuthor: "me", depth: 0, isCollapsed: false)
                .previewLayout(.sizeThatFits)
        }
    }
}
