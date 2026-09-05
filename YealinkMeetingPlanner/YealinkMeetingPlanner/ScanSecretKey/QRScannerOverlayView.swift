//
//  QRScannerOverlayView.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 27.06.2026.
//

import SwiftUI

// MARK: - Overlay with scanning frame (SwiftUI version)
struct QRScannerOverlayView: View {
    /// Guide layer to which other elements can be bound
    @State private var scanRectGuide: CGRect = .zero
    
    /// Размер рамки сканирования (квадрат)
    private let scanRectSize: CGFloat = 260
    private let cornerLength: CGFloat = 28
    private let cornerLineWidth: CGFloat = 5
    private let cornerRadius: CGFloat = 8
    
    var body: some View {
        ZStack {
            // 1. Darken entire area
            Rectangle()
                .fill(Color.black.opacity(0.55))
            
            // 2. Transparent window in the center
            Rectangle()
                .fill(.clear)
                .frame(width: scanRectSize, height: scanRectSize)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.green, lineWidth: cornerLineWidth)
                        .frame(width: scanRectSize, height: scanRectSize)
                )
            
            // 3. Scanning border
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
                    x: scanRectGuide.midX + (index % 2 == 0 ? -scanRectSize / 2 : scanRectSize / 2),
                    y: scanRectGuide.midY + (index < 2 ? -scanRectSize / 2 : scanRectSize / 2)
                )
            }
        }
        .onAppear {
            // Установка размеров рамки сканирования
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            scanRectGuide = CGRect(
                x: (screenWidth - scanRectSize) / 2,
                y: (screenHeight - scanRectSize) / 2,
                width: scanRectSize,
                height: scanRectSize
            )
        }
    }
}

#Preview {
    QRScannerOverlayView()
}