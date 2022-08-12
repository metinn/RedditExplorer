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
    
    var body: some View {
        HStack(spacing: Constants.Space.IconGroup) {
            
            HStack(spacing: Constants.Space.IconText) {
                Image(systemName: "arrow.up")
                Text("\(post.ups)")
            }
            .font(.footnote)
            
            HStack(spacing: Constants.Space.IconText) {
                Image(systemName: "percent")
                Text(String(format: "%2.0f", post.upvote_ratio * 100))
            }
            .font(.caption)
            
            HStack(spacing: Constants.Space.IconText) {
                Image(systemName: "text.bubble")
                Text(String(format: "%i", post.num_comments))
            }
            .font(.footnote)
        }
    }
}

struct PostDataView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            PostDataView(post: Post(id: "1", title: "Post Title", name: "Author 1", selftext: "", selftext_html: nil, thumbnail: "", url: "", author: "", subreddit: "", subreddit_name_prefixed: "r/tifu", ups: 412, upvote_ratio: 0.76, num_comments: 22, stickied: false, created_utc: 0, preview: nil, is_video: false, link_flair_text: nil, is_original_content: false, spoiler: false, replies: nil, media: nil))
                .preferredColorScheme($0)
                .previewLayout(.sizeThatFits)
        }
    }
}
