//
//  PostCellView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 01.05.22.
//

import SwiftUI
import CachedAsyncImage
import AVKit

class PostCellViewModel: ObservableObject {
    var player: AVPlayer?

    func getPlayer(urlStr: String) -> AVPlayer? {
        if player == nil {
            player = AVPlayer(url: URL(string: urlStr)!)
        }
        return player
    }
}

struct PostCellView: View {
    let post: Post
    let limitVerticalSpace: Bool
    var autoPlayVideo: Bool = false
    let onImageTapped: (String)->Void
    @State var showVideoFull = false
    
    let VerticalSpace: CGFloat = 6
    
    @ObservedObject var vm = PostCellViewModel()
    
    var body: some View {
        return VStack(spacing: VerticalSpace) {
            // Header
            HStack {
                PostHeaderView(post: post)
                Spacer()
            }
            
            // Media Preview
            if autoPlayVideo && post.is_video, let video = post.media?.reddit_video {
                VideoPlayer(player: vm.getPlayer(urlStr: video.hls_url ?? video.fallback_url))
                    .frame(height: (UIScreen.main.bounds.width / CGFloat(video.width)) * CGFloat(video.height) )
                    .onDisappear {
                        vm.player?.pause()
                    }

            } else if let preview = post.preview,
               let imageUrl = URL(string: preview.images[0].source.url) {
                CachedAsyncImage(url: imageUrl) { resultImage in
                    resultImage
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: limitVerticalSpace ? 300 : .infinity)
                        .contentShape(Rectangle())
                        .ifCondition(!post.is_video) { view in
                            view.onTapGesture {
                                onImageTapped(imageUrl.absoluteString)
                            }
                        }
                        .overlay {
                            if post.is_video {
                                Image(systemName: "play")
                                    .padding()
                                    .foregroundColor(.black)
                                    .background(.white)
                                    .clipShape(Circle())
                            }
                        }
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
        .contentShape(Rectangle())
        .padding(.vertical, VerticalSpace)
    }
}

struct PostCellView_Previews: PreviewProvider {
    static var previews: some View {
        PostCellView(post: samplePost(), limitVerticalSpace: true) { _ in
        }
    }
}

extension View {
    @ViewBuilder
    func ifCondition<TrueContent: View>(_ condition: Bool, then trueContent: (Self) -> TrueContent) -> some View {
        if condition {
            trueContent(self)
        } else {
            self
        }
    }
}
