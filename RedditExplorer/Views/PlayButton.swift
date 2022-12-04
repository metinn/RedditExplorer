//
//  PlayButton.swift
//  RedditExplorer
//
//  Created by Metin Guler on 26.11.22.
//

import SwiftUI

struct PlayButton: View {
    var body: some View {
        Image(systemName: "play")
            .padding()
            .foregroundColor(.white)
            .background(.gray.opacity(0.9))
            .cornerRadius(12)
            .shadow(color: .white, radius: 10)
    }
}

struct PlayButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayButton()
    }
}
