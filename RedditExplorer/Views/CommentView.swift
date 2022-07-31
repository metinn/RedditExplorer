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
        HStack() {
            // Left border
            if depth > 0 {
                // TODO: this takes too much vertical space, makes preview confusing
                RoundedRectangle(cornerRadius: 1.5)
                    .foregroundColor(Color(hue: 1.0 / Double(depth), saturation: 1.0, brightness: 1.0))
                    .frame(width: 3)
            }
            
            // Content
            VStack(alignment: .leading) {
                HStack {
                    authorText
                    Image(systemName: "arrow.up")
                    Text("\(comment.score)")
                }
                .font(.caption)
                .opacity(0.75)
                
                Text(isCollapsed ? "" : comment.body)

                RoundedRectangle(cornerRadius: 1.5)
                    .foregroundColor(Color.gray)
                    .frame(height: 0.5)
                    .padding(.vertical, 2)
            }
            
            // Expand icon
            if isCollapsed {
                Image(systemName: "chevron.down")
                    .padding(.trailing, 10)
            }
        }
        .padding(.leading, CGFloat(depth * 10))
        .padding(.vertical, 3)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
        .contentShape(Rectangle())
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
