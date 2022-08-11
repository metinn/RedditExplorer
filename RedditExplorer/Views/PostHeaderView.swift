//
//  PostHeaderView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 25.04.22.
//

import SwiftUI

struct PostHeaderView: View {
    var post: Post
    
    var body: some View {
        HStack {
            Text(post.subreddit_name_prefixed)
            Text(timeSince(post.created_utc))
        }.font(.caption)
    }
}

struct PostHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        PostHeaderView(post: Post(id: "1", title: "Post Title", name: "Author 1", selftext: "", selftext_html: nil, thumbnail: "", url: "", author: "", subreddit: "", subreddit_name_prefixed: "r/tifu", ups: 132, upvote_ratio: 0.87, num_comments: 0, stickied: false, created_utc: 0, preview: nil, is_video: false, link_flair_text: nil, is_original_content: false, spoiler: false, replies: nil, media: nil))
    }
}
