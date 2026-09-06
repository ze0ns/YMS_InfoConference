import SwiftUI

// MARK: - Оверлей с рамкой сканирования
struct QRScannerOverlayView: View {
    private let scanRectSize = LayoutDimensions.scannerScanRectSize
    private let cornerLength: CGFloat = 28
    private let cornerLineWidth: CGFloat = 5
    private let cornerRadius: CGFloat = 8

    var body: some View {
        GeometryReader { proxy in
            let scanCenter = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)

            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.55))

                Rectangle()
                    .fill(.clear)
                    .frame(width: scanRectSize, height: scanRectSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.green, lineWidth: cornerLineWidth)
                            .frame(width: scanRectSize, height: scanRectSize)
                    )

                ForEach(0..<4) { index in
                    HStack {
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: cornerLineWidth, height: cornerLength)
                            .cornerRadius(cornerRadius)

                        Rectangle()
                            .fill(Color.green)
                            .frame(width: cornerLength, height: cornerLineWidth)
                            .cornerRadius(cornerRadius)
                    }
                    .position(
                        x: scanCenter.x + (index % 2 == 0 ? -scanRectSize / 2 : scanRectSize / 2),
                        y: scanCenter.y + (index < 2 ? -scanRectSize / 2 : scanRectSize / 2)
                    )
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

#Preview {
    QRScannerOverlayView()
}