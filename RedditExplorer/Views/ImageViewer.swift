//
//  ImageViewer.swift
//  RedditExplorer
//
//  Created by Metin Guler on 10.08.22.
//

import SwiftUI
import PDFKit

class ImageViewerViewModel: ObservableObject {
    enum LoadingState {
        case loading, success, failure
    }
    
    var imageUrl: String
    var img: UIImage?
    @Published var loadingState = LoadingState.loading
    
    init(imageUrl: String) {
        self.imageUrl = imageUrl
    }
    
    func loadImage() {
        Task {
            guard
                let url = URL(string: imageUrl),
                let (data, _) = try? await URLSession.shared.data(from: url),
                let newImage = UIImage(data: data)
            else {
                DispatchQueue.main.async { self.loadingState = .failure }
                return
            }

            DispatchQueue.main.async {
                withAnimation {
                    self.img = newImage
                    self.loadingState = .success
                }
            }
        }
    }
}

struct ImageViewer: View {
    @StateObject var vm: ImageViewerViewModel
    @Binding var showImageViewer: Bool
    
    @State var imageOffset: CGSize = .zero
    @GestureState var magnifyBy = 1.0
    @State var bgOpacity: Double = 1
    
    let minDragYForClose: CGFloat = 250
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(bgOpacity)
                .ignoresSafeArea()
            
            switch vm.loadingState {
            case .loading:
                ProgressView()
            case .success:
                ZoomableImageView(image: vm.img ?? UIImage())
                    .offset(imageOffset)
                    .opacity(bgOpacity)
                    .scaleEffect(magnifyBy)
                    .gesture(dragging)
            case .failure:
                Image(systemName: "exclamationmark.icloud")
                    .resizable()
                    .foregroundColor(.white)
                    .scaledToFill()
                    .frame(width: 100, height: 100)
            }
        }
        .overlay(closeButton, alignment: .bottom)
        .onAppear {
            vm.loadImage()
        }
    }
    
    var closeButton: some View {
        Button {
            withAnimation {
                showImageViewer.toggle()
            }
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(.black)
                .padding(20)
                .background(.white.opacity(0.4))
                .clipShape(Circle())
        }
        .padding()
    }
    
    var dragging: some Gesture {
        DragGesture().onChanged({ update in
            imageOffset = update.translation
            
            withAnimation {
                let maxTranslation = UIScreen.main.bounds.height / 2
                let translationY = min(maxTranslation, abs(update.predictedEndTranslation.height))
                bgOpacity = (maxTranslation - translationY) / maxTranslation
            }
        }).onEnded({ end in
            withAnimation {
                if abs(end.predictedEndTranslation.height) > minDragYForClose {
                    imageOffset = end.predictedEndTranslation
                    showImageViewer = false
                    bgOpacity = 0
                } else {
                    imageOffset = .zero
                    bgOpacity = 1
                }
            }
        })
    }
}

struct ImageViewer_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewer(vm: ImageViewerViewModel(imageUrl: "https://via.placeholder.com/800x600"),
                    showImageViewer: Binding<Bool>.init(get: { true }, set: { _ in }))
    }
}

/// TODO: make a coordinator to see scaleFactor from swiftui view. Don't let
/// DragGesture work unless scaleFactor is 1
struct ZoomableImageView: UIViewRepresentable {
    let image: UIImage

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.backgroundColor = .clear
        view.autoScales = true
        
        if let page = PDFPage(image: image) {
            let document = PDFDocument()
            document.insert(page, at: 0)
            view.document = document
        }
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        // updates not needed for now
    }
}
