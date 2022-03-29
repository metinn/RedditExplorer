//
//  PostCellView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 01.05.22.
//

import SwiftUI
import CachedAsyncImage

struct PostCellView: View {
    let post: Post
    let limitVerticalSpace: Bool
    
    let VerticalSpace: CGFloat = 6
    
    var body: some View {
        return VStack(spacing: VerticalSpace) {
            // Header
            HStack {
                PostHeaderView(post: post)
                Spacer()
            }
            
            // Media Preview
            if let preview = post.preview,
               let imageUrl = URL(string: preview.images[0].source.url) {
                CachedAsyncImage(url: imageUrl) { resultImage in
                    resultImage
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: limitVerticalSpace ? 300 : .infinity)
                } placeholder: {
                    ProgressView()
                }
                .clipped()
            }
            
            // Text & Thumbnail
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: VerticalSpace) {
                    Text(post.title)
                        .font(.body)
                    
                    if !post.selftext.isEmpty {
                        Text(post.selftext)
                            .font(.footnote)
                            .lineLimit(2)
                    }
                    
                    PostDataView(post: post)
                }
                Spacer()
                
                if post.preview == nil && post.thumbnail.contains("https") {
                    if let thumbnailUrl = URL(string: post.thumbnail) {
                        AsyncImage(url: thumbnailUrl)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(5.0)
                    }
                }
            }
        }
        .padding(.vertical, VerticalSpace)
    }
}

struct PostCellView_Previews: PreviewProvider {
    static var previews: some View {
        PostCellView(post: samplePost(), limitVerticalSpace: true)
    }
}
