//
//  QRScannerOverlayView.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 27.06.2026.
//

import SwiftUI

// MARK: - Overlay with scanning frame (SwiftUI version)
struct QRScannerOverlayView: View {
    /// Размер рамки сканирования (квадрат)
    private let scanRectSize = LayoutDimensions.scannerScanRectSize
    private let cornerLength: CGFloat = 28
    private let cornerLineWidth: CGFloat = 5
    private let cornerRadius: CGFloat = 8

    var body: some View {
        GeometryReader { proxy in
            let scanCenter = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)

            ZStack {
                // 1. Затемнение всей области
                Rectangle()
                    .fill(Color.black.opacity(0.55))

                // 2. Прозрачное окно в центре
                Rectangle()
                    .fill(.clear)
                    .frame(width: scanRectSize, height: scanRectSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.green, lineWidth: cornerLineWidth)
                            .frame(width: scanRectSize, height: scanRectSize)
                    )

                // 3. Уголки рамки сканирования
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