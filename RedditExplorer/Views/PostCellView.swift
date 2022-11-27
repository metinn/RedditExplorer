//
//  PostCellView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 01.05.22.
//

import SwiftUI
import CachedAsyncImage
import AVKit
import SwiftUIGIF

class PostCellViewModel: ObservableObject {
    let post: Post
    let limitVerticalSpace: Bool
    let onImageTapped: (String)->Void
    @Published var showVideoFullscreen = false
    @Published var showWebView = false
    @Published var isVideoPlaying: Bool = false
    @Published var isVideoMuted: Bool = false
    var player: AVPlayer? = nil
    
    @Published var gifData: Data? = nil
    @Published var imageUrl: URL? = nil
    
    var isAKindOfVideo: Bool { post.videoUrl != nil || hasYoutubeLink }
    var hasYoutubeLink: Bool { post.domain.contains("youtube.com") || post.domain.contains("youtu.be") }
    
    init(post: Post, limitVerticalSpace: Bool, onImageTapped: @escaping (String)->Void) {
        self.post = post
        self.limitVerticalSpace = limitVerticalSpace
        self.onImageTapped = onImageTapped
    }
    
    func loadPreview() {
        if post.isGIF {
            loadGIF(urlString: post.url)
        } else if let url = URL(string: getPreviewImageUrls().first ?? "") {
            self.imageUrl = url
        }
    }
    
    func loadGIF(urlString: String) {
        guard let gifUrl = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: gifUrl) { data, _, _ in
            DispatchQueue.main.async {
                self.gifData = data
            }
        }.resume()
    }
    
    func prepareAndShowVideo() {
        guard
            let videoUrl = post.videoUrl,
            let url = URL(string: videoUrl)
        else { return }
        
        player = AVPlayer(url: url)
        showVideoFullscreen = true
    }
    
    func getPreviewImageUrls() -> [String] {
        guard let preview = post.preview else { return [] }
        
        //TODO: better logic to pick resolution
        return preview.images.compactMap { imageSource in
            imageSource.resolutions.filter { $0.width >= 240 }
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
            if let data = vm.gifData {
                GIFImage(data: data)
                    .aspectRatio(1.5, contentMode: .fit)
            } else if let imageUrl = vm.imageUrl {
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
            }
            .padding(.horizontal)
        }
        .contentShape(Rectangle())
        .onAppear{
            vm.loadPreview()
        }
        .padding(.vertical, VerticalSpace)
        .sheet(isPresented: $vm.showVideoFullscreen) {
            VideoPlayer(player: vm.player!)
                .ignoresSafeArea()
                .onAppear {
                    vm.player?.isMuted = false
                    vm.player?.play()
                    vm.isVideoMuted = false
                }
                .onDisappear {
                    vm.player?.pause()
                    vm.player = nil
                }
        }
        .sheet(isPresented: $vm.showWebView) {
            WebView(url: URL(string: vm.post.url)!)
        }
    }
    
    @ViewBuilder
    func buildImagePreview(_ imageUrl: URL) -> some View {
        CachedAsyncImage(url: imageUrl) { resultImage in
            resultImage
                .resizable()
                .scaledToFill()
                .frame(maxHeight: ImageHeight)
                .contentShape(Rectangle())
                .ifCondition(vm.isAKindOfVideo, then: { im in
                    im.overlay {
                        PlayButton()
                    }
                })
                .onTapGesture {
                    if vm.post.videoUrl != nil {
                        vm.prepareAndShowVideo()
                    } else if vm.hasYoutubeLink {
                        vm.showWebView = true
                    } else {
                        vm.onImageTapped(vm.getOriginalImages().first ?? "")
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
}

#if DEBUG
struct PostCellView_Previews: PreviewProvider {
    static var previews: some View {
        PostCellView(vm: PostCellViewModel(post: samplePost(), limitVerticalSpace: false, onImageTapped: {_ in}))
        .previewLayout(.sizeThatFits)
    }
}
#endif
