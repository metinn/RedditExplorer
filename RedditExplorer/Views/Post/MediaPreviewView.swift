//
//  MediaPreviewView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 21.12.22.
//

import SwiftUI
import CachedAsyncImage
import SwiftUIGIF

class MediaPreviewViewModel: ObservableObject {
    let post: Post
    
    @Published var gifData: Data? = nil
    var imageUrl: URL? {
        URL(string: getPreviewImageUrls().first ?? "")
    }
    
    var isAKindOfVideo: Bool { post.videoUrl != nil || post.hasYoutubeLink }
    
    init(post: Post) {
        self.post = post
    }
    
    func loadPreview() {
        if post.isGIF {
            loadGIF(urlString: post.url)
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
    
    func getPreviewImageUrls() -> [String] {
        guard let preview = post.preview else { return [] }
        
        return preview.images.compactMap { imageSource in
            imageSource.resolutions
                .sorted { $0.width > $1.width }
                .middle?.url
        }
    }
    
    func getOriginalImages() -> [String] {
        post.preview?.images.compactMap { $0.source.url } ?? []
    }
}

struct MediaPreviewView: View {
    static let ImageHeight: CGFloat = 300
    @StateObject var vm: MediaPreviewViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    
    static func hasPreview(post: Post) -> Bool {
        return post.preview != nil || post.isGIF
    }
    
    var body: some View {
        VStack {
            if let data = vm.gifData {
                GIFImage(data: data)
            } else if let imageUrl = vm.imageUrl {
                buildImagePreview(imageUrl)
            } else {
                EmptyView()
            }
        }
        .onAppear {
            vm.loadPreview()
        }
    }
    
    @ViewBuilder
    func buildImagePreview(_ imageUrl: URL) -> some View {
        CachedAsyncImage(url: imageUrl) { resultImage in
            resultImage
                .resizable()
                .scaledToFill()
                .frame(height: MediaPreviewView.ImageHeight)
                .contentShape(Rectangle())
                .ifCondition(vm.isAKindOfVideo, then: { im in
                    im.overlay {
                        PlayButton()
                    }
                })
                .onTapGesture {
                    if let url = vm.post.videoUrl {
                        homeVM.showVideo(url)
                    } else if vm.post.hasYoutubeLink {
                        homeVM.showWebView(vm.post.url)
                    } else {
                        homeVM.showImage(vm.getOriginalImages().first ?? "")
                    }
                }
        } placeholder: {
            ZStack {
                Color.gray
                    .frame(height: MediaPreviewView.ImageHeight)
                ProgressView()
            }
        }
        .clipped()
    }
}

#if DEBUG
struct MediaPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        MediaPreviewView(vm: MediaPreviewViewModel(post: samplePost()))
    }
}
#endif
