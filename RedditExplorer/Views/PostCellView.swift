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
    
    let post: Post
    let limitVerticalSpace: Bool
    var expandedMode: Bool
    let onImageTapped: (String)->Void
    @Published var showVideoFullscreen = false
    @Published var isVideoPlaying: Bool = false
    @Published var isVideoMuted: Bool = false
    
    init(post: Post, limitVerticalSpace: Bool, expandedMode: Bool = false, onImageTapped: @escaping (String)->Void) {
        self.post = post
        self.limitVerticalSpace = limitVerticalSpace
        self.expandedMode = expandedMode
        self.onImageTapped = onImageTapped
    }

    func getPlayer() -> AVPlayer? {
        if player == nil {
            guard
                let video = post.media?.reddit_video,
                let url = URL(string: video.hls_url ?? video.fallback_url)
            else { return nil }
            player = AVPlayer(url: url)
        }
        return player
    }
    
    func getPreviewImageUrls() -> [String] {
        guard let preview = post.preview else { return [] }
        
        return preview.images.compactMap { imageSource in
            imageSource.resolutions.filter { $0.width > 320 }
                .sorted { $0.width > $1.width }
                .last?.url
        }
    }
    
    func getOriginalImages() -> [String] {
        post.preview?.images.compactMap { $0.source.url } ?? []
    }
}

struct PostCellView: View {
    let VerticalSpace: CGFloat = 6
    let ImageHeight: CGFloat = 300
    
    @StateObject var vm: PostCellViewModel
    
    var body: some View {
        return VStack(spacing: VerticalSpace) {
            // Header
            HStack {
                PostHeaderView(post: vm.post)
                Spacer()
            }
            .padding(.horizontal)
            
            // Media Preview
            if vm.post.is_video,
                let video = vm.post.media?.reddit_video,
                let player = vm.getPlayer() {
                
                buildVideoPreview(player, video)
                
            } else if let imageUrl = URL(string: vm.getPreviewImageUrls().first ?? "") {
                buildImagePreview(imageUrl)
            }
            
            // Text & Thumbnail
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: VerticalSpace) {
                    Text(vm.post.title)
                        .font(.headline)
                    
                    if !vm.post.selftext.isEmpty {
                        Text(vm.post.selftext)
                            .font(.body)
                            .lineLimit(vm.limitVerticalSpace ? 2 : nil)
                    }
                    
                    PostDataView(post: vm.post)
                }
                Spacer()
                
                if vm.post.preview == nil && vm.post.thumbnail.contains("https") {
                    if let thumbnailUrl = URL(string: vm.post.thumbnail) {
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
        .fullScreenCover(isPresented: $vm.showVideoFullscreen) {
            VideoPlayer(player: vm.player!)
                .ignoresSafeArea()
                .onAppear {
                    vm.player?.isMuted = false
                    vm.isVideoMuted = false
                }
                .onDisappear {
                    vm.player?.pause()
                }
        }
    }
    
    @ViewBuilder
    func buildVideoPreview(_ player: AVPlayer, _ video: Post.Media.RedditVideo) -> some View {
        VideoPlayer(player: player)
            .aspectRatio(vm.expandedMode ? video.aspectRatio : 1.5,
                         contentMode: .fit)
            .onAppear {
                vm.player?.isMuted = !vm.expandedMode
                vm.isVideoMuted = vm.player?.isMuted ?? false
                vm.player?.play()
                vm.isVideoPlaying = true
            }
            .onDisappear {
                vm.player?.pause()
            }
            .onTapGesture {
                if !vm.expandedMode {
                    vm.showVideoFullscreen = true
                }
            }
        
        if vm.expandedMode {
            buildVideoControls()
        }
    }
    
    @ViewBuilder
    func buildImagePreview(_ imageUrl: URL) -> some View {
        CachedAsyncImage(url: imageUrl) { resultImage in
            resultImage
                .resizable()
                .scaledToFill()
                .frame(maxHeight: vm.limitVerticalSpace ? ImageHeight : UIScreen.main.bounds.height - 200)
                .contentShape(Rectangle())
                .onTapGesture {
                    vm.onImageTapped(vm.getOriginalImages().first ?? "")
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
    
    @ViewBuilder
    func buildVideoControls() -> some View {
        HStack {
            Button {
                vm.showVideoFullscreen = true
            } label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .padding()
                    .foregroundColor(.white)
                    .background(.gray.opacity(0.5))
                    .cornerRadius(12)
            }
            
            Button {
                if vm.isVideoPlaying {
                    vm.player?.pause()
                    vm.isVideoPlaying = false
                } else {
                    vm.player?.play()
                    vm.isVideoPlaying = true
                }
            } label: {
                Image(systemName: vm.isVideoPlaying ? "pause" : "play")
                    .padding()
                    .foregroundColor(.white)
                    .background(.gray.opacity(0.5))
                    .cornerRadius(12)
            }
            
            Button {
                vm.player?.isMuted.toggle()
                vm.isVideoMuted = vm.player?.isMuted ?? false
            } label: {
                Image(systemName: vm.player?.isMuted == true ? "speaker.fill" : "speaker.slash.fill")
                    .padding()
                    .foregroundColor(.white)
                    .background(.gray.opacity(0.5))
                    .cornerRadius(12)
            }
        }
    }
}

#if DEBUG
struct PostCellView_Previews: PreviewProvider {
    static var previews: some View {
        PostCellView(vm: PostCellViewModel(post: samplePost(), limitVerticalSpace: false, onImageTapped: {_ in}))
        .previewLayout(.sizeThatFits)
    }
}
#endif
