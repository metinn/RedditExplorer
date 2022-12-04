//
//  CommentCell.swift
//  RedditExplorer
//
//  Created by Metin Guler on 31.07.22.
//

import SwiftUI

struct CommentFrame<Content>: View where Content : View {
    let depth: Int
    let isCollapsed: Bool
    @ViewBuilder var content: () -> Content
    
    let CommentDepth = 10
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Content
            HStack {
                content()
                
                // Expand icon
                if isCollapsed {
                    Spacer()
                    Image(systemName: "chevron.down")
                }
            }
            .padding(.horizontal, 10)

            RoundedRectangle(cornerRadius: 1.5)
                .foregroundColor(Color.gray)
                .frame(height: 0.5)
        }
        // leading depth line
        .overlay(alignment: .leading) {
                Rectangle()
                    .frame(width: 2, alignment: .leading)
                    .foregroundColor(colorForDepth(depth))
        }
        .padding(.leading, CGFloat(depth * CommentDepth))
        .contentShape(Rectangle())
    }
    
    func colorForDepth(_ depth: Int) -> Color {
        guard depth > 0 else { return Color.gray }
        
        return Color(hue: 1.0 / Double(depth),
                     saturation: 1.0,
                     brightness: 1.0)
    }
}

struct CommentCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CommentFrame(depth: 0, isCollapsed: false, content: {
                Text("A text")
            })
            .previewLayout(.sizeThatFits)
            CommentFrame(depth: 1, isCollapsed: false, content: {
                Text("A text")
            })
            .previewLayout(.sizeThatFits)
            CommentFrame(depth: 2, isCollapsed: false, content: {
                Text("A text")
            })
            .previewLayout(.sizeThatFits)
            CommentFrame(depth: 3, isCollapsed: true, content: {
                Text("A text")
            })
            .previewLayout(.sizeThatFits)
        }
    }
}
