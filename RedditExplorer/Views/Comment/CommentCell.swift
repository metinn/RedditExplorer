//
//  CommentCell.swift
//  RedditExplorer
//
//  Created by Metin Guler on 31.07.22.
//

import SwiftUI

struct CommentCell<Content>: View where Content : View {
    let depth: Int
    let isCollapsed: Bool
    @ViewBuilder var content: () -> Content
    
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
                content()

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
