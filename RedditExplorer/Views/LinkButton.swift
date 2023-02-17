//
//  LinkButton.swift
//  RedditExplorer
//
//  Created by Metin Guler on 14.02.23.
//

import SwiftUI

struct LinkButton: View {
    @Environment(\.colorScheme) var currentMode
    @EnvironmentObject var homeVM: HomeViewModel
    let urlString: String
    
    var body: some View {
        Button {
            homeVM.showWebView(urlString)
        } label: {
            HStack {
                Image(systemName: "safari.fill")
                    .resizable()
                    .frame(width: Space.medium,
                           height: Space.medium)
                    .padding(Space.mini)
                
                Text(urlString)
                    .lineLimit(1)
                    .font(.footnote)
                    .foregroundColor(currentMode == .light ? .black : .white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .padding(Space.mini)
            }
            .padding(Space.mini)
            .frame(maxWidth: .infinity)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue, lineWidth: 1)
        }
        .padding(.horizontal)
    }
}

struct LinkButton_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            VStack {
                LinkButton(urlString: "example.com")
                    .previewLayout(.sizeThatFits)
                
                LinkButton(urlString: "https://www.reddit.com/hot.json?limit=10&raw_json=1")
                    .previewLayout(.sizeThatFits)
            }
            .preferredColorScheme($0)
        }
    }
}
