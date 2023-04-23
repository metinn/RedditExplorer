//
//  SubredditCellView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 16.04.23.
//

import SwiftUI
import CachedAsyncImage

struct SubredditCellView: View {
    let subreddit: Subreddit
    
    var body: some View {
        NavigationLink(destination: PostListPage(vm: PostListViewModel(listing: .subreddit(subreddit.display_name)))) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: Space.medium) {
                    image
                    
                    VStack(alignment: .leading) {
                        Text(subreddit.title)
                        Text(subreddit.display_name)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.bottom, Space.mini)
                        Text(subreddit.public_description)
                            .font(.footnote)
                            .lineLimit(3)
                    }
                    Spacer()
                }
                .padding()
                .contentShape(Rectangle())
                
                Divider()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var image: some View {
        CachedAsyncImage(url: subreddit.iconUrl) { phase in
            Group {
                if let image = phase.image {
                    image
                        .resizable()
                } else {
                    Image(systemName: "photo")
                }
            }
            .frame(width: 50, height: 50)
        }
    }
}

struct SubredditCellView_Previews: PreviewProvider {
    static var previews: some View {
        SubredditCellView(subreddit: Subreddit(id: "id_12345",
                                               display_name: "apple",
                                               title: "Apple",
                                               public_description: "Discover the innovative world of Apple and shop everything iPhone, iPad, Apple Watch, Mac, and Apple TV, plus explore accessories, entertainment, and expert device support.",
                                               community_icon: "https://www.apple.com/favicon.ico"))
    }
}
