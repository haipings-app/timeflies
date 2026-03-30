import AVKit
import QuickLook
import SwiftUI

struct ResourcePreviewView: View {
    let resource: SOPSavedResource
    let localURL: URL

    var body: some View {
        Group {
            if resource.kind == .video {
                VideoPlayer(player: AVPlayer(url: localURL))
                    .ignoresSafeArea(edges: .bottom)
            } else {
                QuickLookPreview(url: localURL)
            }
        }
        .navigationTitle(resource.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        context.coordinator.url = url
        uiViewController.reloadData()
    }

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        var url: URL

        init(url: URL) {
            self.url = url
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}
