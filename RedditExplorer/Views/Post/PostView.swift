//
//  PostView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 01.05.22.
//

import SwiftUI
import SwiftUIGIF

class PostViewModel: ObservableObject {
    let post: Post
    let limitVerticalSpace: Bool
    
    var attributedSelfText: AttributedString? {
        guard !post.selftext.isEmpty else { return nil }
        return Markdown.getAttributedString(from: post.selftext)
    }
    
    init(post: Post, limitVerticalSpace: Bool) {
        self.post = post
        self.limitVerticalSpace = limitVerticalSpace
    }
}

struct PostView: View {
    let VerticalSpace: CGFloat = 6
    let ImageHeight: CGFloat = 300
    
    @StateObject var vm: PostViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    
    var body: some View {
        return VStack(spacing: VerticalSpace) {
            // Header
            HStack {
                PostHeaderView(post: vm.post)
                Spacer()
            }
            .padding(.horizontal)
            
            // Text & Thumbnail
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: VerticalSpace) {
                    Text(vm.post.title)
                        .font(.headline)
                    
                    if let attrStr = vm.attributedSelfText {
                        Text(attrStr)
                            .font(.body)
                            .lineLimit(vm.limitVerticalSpace ? 2 : nil)
                            .environment(\.openURL, OpenURLAction { url in
                                homeVM.showWebView(url.absoluteString)
                                return .handled
                              })
                    } else if !vm.post.selftext.isEmpty {
                        Text(vm.post.selftext)
                            .font(.body)
                            .lineLimit(vm.limitVerticalSpace ? 2 : nil)
                    }
                    
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
            
            PostFooterView(post: vm.post)
                .frame(maxWidth: .infinity)
        }
        .contentShape(Rectangle())
        .padding(.vertical, VerticalSpace)
    }
}

#if DEBUG
struct PostCellView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(vm: PostViewModel(post: samplePost(), limitVerticalSpace: false))
        .previewLayout(.sizeThatFits)
    }
}
#endif
