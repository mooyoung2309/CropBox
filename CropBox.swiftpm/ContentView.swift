import SwiftUI

struct ContentView: View {
    let image: UIImage
    @State var cropArea: CGRect = .init(x: 0, y: 0, width: 100, height: 100)
    @State var imageViewSize: CGSize = .zero
    @State var croppedImage: UIImage?
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .overlay(alignment: .topLeading) {
                    GeometryReader { geometry in
                        CropBox(rect: $cropArea)
                            .onAppear {
                                self.imageViewSize = geometry.size
                            }
                            .onChange(of: geometry.size) {
                                self.imageViewSize = $0
                            }
                    }
                }
            
            Button("Crop", action: { croppedImage = self.crop(image: image, cropArea: cropArea, imageViewSize: imageViewSize) })
                .buttonStyle(.bordered)
                .font(.title)
                .foregroundStyle(.black)
            Spacer()
            if let croppedImage {
                Image(uiImage: croppedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
            }
            Spacer()
        }
    }
    
    private func crop(image: UIImage, cropArea: CGRect, imageViewSize: CGSize) -> UIImage? {
        let scaleX = image.size.width / imageViewSize.width * image.scale
        let scaleY = image.size.height / imageViewSize.height * image.scale
        let scaledCropArea = CGRect(
            x: cropArea.origin.x * scaleX,
            y: cropArea.origin.y * scaleY,
            width: cropArea.size.width * scaleX,
            height: cropArea.size.height * scaleY
        )

        guard let cutImageRef: CGImage = image.cgImage?.cropping(to: scaledCropArea) else {
            return nil
        }

        return UIImage(cgImage: cutImageRef)
    }
}
