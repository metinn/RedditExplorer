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
        HStack(alignment: .top) {
            // Left border
            if comment.nestLevel > 0 {
                RoundedRectangle(cornerRadius: 1.5)
                    .foregroundColor(Color(hue: 1.0 / Double(comment.nestLevel), saturation: 1.0, brightness: 1.0))
                    .frame(width: 3)
            }
            // Content
            VStack(alignment: .leading) {
                HStack {
                    authorText
                    Image(systemName: "arrow.up")
                    Text("\(comment.score ?? 0)")
                }
                .font(.caption)
                .opacity(0.75)
                
                Text(comment.isCollapsed ? "" : comment.body)
                
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
            CommentView(comment: PostViewPageViewModel.Comment(id: "id", author: "eskimo", score: 42, body: "meaningful comment", nestLevel: 2, isCollapsed: false), postAuthor: "joe")
                .previewLayout(.fixed(width: /*@START_MENU_TOKEN@*/375.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/80.0/*@END_MENU_TOKEN@*/))
            CommentView(comment: PostViewPageViewModel.Comment(id: "id", author: "eskimo", score: 42, body: "meaningful comment", nestLevel: 2, isCollapsed: true), postAuthor: "joe")
                .previewLayout(.fixed(width: /*@START_MENU_TOKEN@*/375.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/60.0/*@END_MENU_TOKEN@*/))
        }
    }
}
