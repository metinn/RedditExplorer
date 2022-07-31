//
//  CommentView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 19.07.22.
//

import SwiftUI

struct CommentView: View {
    let comment: PostViewPageViewModel.Comment
    let postAuthor: String
    
    var authorText: some View {
        if comment.author == postAuthor {
            return Text(comment.author ?? "-a-").foregroundColor(.accentColor).bold()
        } else {
            return Text(comment.author ?? "-a-")
        }
    }
    
    var body: some View {
        HStack() {
            // Left border
            if comment.nestLevel > 0 {
                // TODO: this takes too much vertical space, makes preview confusing
                RoundedRectangle(cornerRadius: 1.5)
                    .foregroundColor(Color(hue: 1.0 / Double(comment.nestLevel), saturation: 1.0, brightness: 1.0))
                    .frame(width: 3)
            }
            // Content
            VStack(alignment: .leading) {
                if comment.kind == .comment {
                    HStack {
                        authorText
                        Image(systemName: "arrow.up")
                        Text("\(comment.score ?? 0)")
                    }
                    .font(.caption)
                    .opacity(0.75)
                    
                    Text(comment.isCollapsed ? "" : comment.body)
                } else if comment.kind == .moreComment {
                    Text("\(comment.count ?? 0) more")
                        .foregroundColor(.blue)
                }
                
                RoundedRectangle(cornerRadius: 1.5)
                    .foregroundColor(Color.gray)
                    .frame(height: 0.5)
                    .padding(.vertical, 2)
            }
            
            // Expand icon
            if comment.isCollapsed {
                Image(systemName: "chevron.down")
                    .padding(.trailing, 10)
            }
        }
        .padding(.leading, CGFloat(comment.nestLevel * 10))
        .padding(.vertical, 3)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
        .contentShape(Rectangle())
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            CommentView(comment: PostViewPageViewModel.Comment(id: "id", author: "eskimo", score: 42, body: "meaningful comment kasmdkas", nestLevel: 0, isCollapsed: false, kind: .comment, count: nil), postAuthor: "joe")
                .previewLayout(.sizeThatFits)
            CommentView(comment: PostViewPageViewModel.Comment(id: "id", author: "eskimo", score: 42, body: "meaningful comment", nestLevel: 2, isCollapsed: true, kind: .comment, count: nil), postAuthor: "joe")
                .previewLayout(.sizeThatFits)
            CommentView(comment: PostViewPageViewModel.Comment(id: "id", author: "", score: 0, body: "", nestLevel: 3, isCollapsed: false, kind: .moreComment, count: 8), postAuthor: "joe")
                .previewLayout(.sizeThatFits)
        }
    }
}
