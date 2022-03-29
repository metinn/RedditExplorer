//
//  PostDataView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 19.03.22.
//

import SwiftUI

struct PostDataView: View {
    @Environment(\.colorScheme) var currentMode
    @State var post: Post
    
    let SpaceIconText: CGFloat = 1
    let SpaceIconGroup: CGFloat = 10
    
    var body: some View {
        HStack(spacing: 0) {
            Group {
                Image(systemName: "arrow.up")
                    .padding(.trailing, SpaceIconText)
                Text("\(post.ups)")
                    .padding(.trailing, SpaceIconGroup)
            }
            .font(.footnote)
            
            Group {
                Image(systemName: "percent")
                    .padding(.trailing, SpaceIconText)

                Text(String(format: "%2.0f", post.upvote_ratio * 100))
                    .padding(.trailing, SpaceIconGroup)
            }
            .font(.caption)
            
            Group {
                Image(systemName: "text.bubble")
                    .padding(.trailing, SpaceIconText)
                Text(String(format: "%i", post.num_comments))
            }
            .font(.footnote)
        }
    }
}

struct PostDataView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            PostDataView(post: Post(id: "1", title: "Post Title", name: "Author 1", selftext: "", selftext_html: nil, thumbnail: "", url: "", author: "", subreddit: "", subreddit_name_prefixed: "r/tifu", ups: 412, upvote_ratio: 0.76, num_comments: 22, stickied: false, created_utc: 0, preview: nil, link_flair_text: nil, is_original_content: false, spoiler: false, replies: nil))
                .preferredColorScheme($0)
        }
    }
}
