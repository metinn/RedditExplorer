//
//  RoundedButtonView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 10.04.23.
//

import SwiftUI

struct RoundedButtonView: View {
    let iconName: String
    let title: String
    let trailingIconName: String?
    
    private let CornerRadius = 20.0
    
    @Environment(\.colorScheme) var currentMode
    
    init(iconName: String, title: String, trailingIconName: String? = nil) {
        self.iconName = iconName
        self.title = title
        self.trailingIconName = trailingIconName
    }
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .resizable()
                .frame(width: Space.medium,
                       height: Space.medium)
                .padding(Space.mini)
            
            Text(title)
                .lineLimit(1)
                .font(.footnote)
                .foregroundColor(currentMode == .light ? .black : .white)
            
            Spacer()
            
            if let trailingIconName {
                Image(systemName: trailingIconName)
                    .padding(Space.mini)
            }
        }
        .padding(.vertical, Space.mini)
        .padding(.horizontal, CornerRadius / 2)
        .frame(maxWidth: .infinity)
        .overlay {
            RoundedRectangle(cornerRadius: CornerRadius)
                .stroke(Color.blue, lineWidth: 1)
        }
    }
}

struct RoundedButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RoundedButtonView(iconName: "safari", title: "A Button", trailingIconName: "chevron.right")
            RoundedButtonView(iconName: "safari", title: "A Button")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
