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
    let ImageHeight: CGFloat = 300
    
    @ObservedObject var vm = PostCellViewModel()
    
    var body: some View {
        return VStack(spacing: VerticalSpace) {
            // Header
            HStack {
                PostHeaderView(post: post)
                Spacer()
            }
            .padding(.horizontal)
            
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
                        .frame(maxHeight: limitVerticalSpace ? ImageHeight : UIScreen.main.bounds.height - 200)
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
                    ZStack {
                        Color.gray
                            .frame(height: ImageHeight)
                        ProgressView()
                    }
                }
                .clipped()
            }
            
            // Text & Thumbnail
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: VerticalSpace) {
                    Text(post.title)
                        .font(.headline)
                    
                    if !post.selftext.isEmpty {
                        Text(post.selftext)
                            .font(.body)
                            .lineLimit(limitVerticalSpace ? 2 : nil)
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
            }.padding(.horizontal)
        }
        .contentShape(Rectangle())
        .padding(.vertical, VerticalSpace)
    }
}

#if DEBUG
struct PostCellView_Previews: PreviewProvider {
    static var previews: some View {
        PostCellView(post: samplePost(), limitVerticalSpace: false) { _ in
        }
    }
}
#endif
