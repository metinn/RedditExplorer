//
//  ContentView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 19.03.22.
//

import SwiftUI
import Combine

@MainActor
class PostListViewModel: ObservableObject {
    let listing: ListingType
    var isFetchInProgress = false
    
    private var api: RedditAPIProtocol.Type = RedditAPI.self
    
    @Published var posts: [Post] = []
    @Published var sortBy: SortBy
    @Published var isSortingOptionsPresented = false
    
    var cancelables: Set<AnyCancellable> = []
    
    init(listing: ListingType) {
        self.listing = listing
        sortBy = listing.sortingOptions.first ?? .top
        
        $sortBy.receive(on: DispatchQueue.main).sink { [weak self] _ in
            Task { await self?.refreshPosts() }
        }
        .store(in: &cancelables)
    }
    
    var title: String {
        switch listing {
        case .subreddit(let string):
            if let string {
                return "r/" + string
            } else {
                return "Front Page"
            }
        case .user(let string):
            return string
        }
    }
    
    func fetchNextPosts() async {
        // TODO: better way? when scrolling to fast down, it is possible to get same request more then once
        guard !isFetchInProgress else { return }
        isFetchInProgress = true
        defer { isFetchInProgress = false }
        
        do {
            let newPosts = try await api.getPosts(sortBy, listing: listing, after: posts.last?.name, limit: 10)
            self.posts.append(contentsOf: newPosts)
        } catch let err {
            print("Error: \(err.localizedDescription)")
        }
    }
    
    func refreshPosts() async {
        self.posts = []
        // Wait a bit for user to see. Because we cannot cancel the drag gesture, user have to do it
        try? await Task.sleep(nanoseconds:  500 * 1000 * 1000)
        await fetchNextPosts()
    }
}

struct PostListPage: View {
    @StateObject var vm: PostListViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @Environment(\.colorScheme) var currentMode
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(vm.posts, id: \.url) { post in
                    buildPostCell(post)
                }
                
                ProgressView()
                    .onAppear {
                        Task { await vm.fetchNextPosts() }
                    }
            }
            .onRefresh {
                await vm.refreshPosts()
            }
        }
        .navigationTitle(vm.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(vm.sortBy.rawValue.localizedCapitalized) {
                    vm.isSortingOptionsPresented = true
                }
            }
        }
        .confirmationDialog("", isPresented: $vm.isSortingOptionsPresented) {
            ForEach(vm.listing.sortingOptions) { sortBy in
                Button(sortBy.rawValue.localizedCapitalized) {
                    vm.sortBy = sortBy
                }
            }
        } message: {
            Text("Pick a sort option")
        }
    }
    
    func buildPostCell(_ post: Post) -> some View {
        return VStack() {
            NavigationLink(destination: PostViewPage(vm: PostViewViewModel(post: post))) {
                VStack {
                    if MediaPreviewView.hasPreview(post: post) {
                        MediaPreviewView(vm: MediaPreviewViewModel(post: post))
                    }
                    
                    PostView(vm: PostViewModel(post: post, limitVerticalSpace: true))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            //Divider
            Color.gray
                .opacity(0.2)
                .frame(height: Space.small)
        }
    }
}

#if DEBUG
struct PostList_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            PostListPage(vm: PostListViewModel(listing: .subreddit(nil)))
                .preferredColorScheme($0)
        }
    }
}
#endif
