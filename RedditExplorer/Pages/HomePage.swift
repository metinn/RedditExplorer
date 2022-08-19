//
//  HomePage.swift
//  RedditExplorer
//
//  Created by Metin Guler on 14.08.22.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    let tabList: [HomeViewModel.Tab] = [
        .list(.hot),
        .list(.top),
        .list(.rising),
        .subreddits]
    @Published var selectedTab: HomeViewModel.Tab = .list(.hot)
    
    var selectedImageURL: String = ""
    @Published var showImageViewer: Bool = false
    
    enum Tab: Hashable {
        case list(SortBy)
        case subreddits
        
        var title: String {
            switch self {
            case .list(let sortBy):
                return sortBy.rawValue
            case .subreddits:
                return "Subreddits"
            }
        }
    }
    
    func showImage(_ imageUrl: String) {
        withAnimation {
            selectedImageURL = imageUrl
            showImageViewer = true
        }
    }
}

struct HomePage: View {
    @Environment(\.colorScheme) var currentMode
    @StateObject var vm = HomeViewModel()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Tabs
                    TabView(selection: $vm.selectedTab) {
                        ForEach(vm.tabList, id: \.self) { tab in
                            switch tab {
                            case .list(let sortBy):
                                PostListPage(vm: PostListViewModel(sortBy: sortBy, subReddit: nil))
                            case .subreddits:
                                SubredditsPage()
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Tab bar,
                    VStack {
                        Spacer()
                        tabBar(geometry)
                    }
                }
                .navigationBarHidden(true)
                .ignoresSafeArea()
            }
        }
        .navigationViewStyle(.stack)
        .overlay {
            if vm.showImageViewer {            
                ImageViewer(imageUrl: vm.selectedImageURL,
                            showImageViewer: $vm.showImageViewer)
            }
        }
        .environmentObject(vm)
    }
    
    func tabBar(_ geometry: GeometryProxy) -> some View {
        return HStack {
            ForEach(vm.tabList, id: \.self) { tab in
                Text(tab.title)
                    .opacity(vm.selectedTab == tab ? 1.0 : 0.4)
                    .onTapGesture {
                        vm.selectedTab = tab
                    }
            }
        }
        .padding()
        .frame(height: 40)
        .background(currentMode == .light ? .teal : .indigo)
        .cornerRadius(10)
        .shadow(radius: 10)
        .padding(.bottom, geometry.safeAreaInsets.bottom + 30)
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
