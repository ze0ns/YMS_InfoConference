//
//  QRScannerOverlayView.swift
//  scantext
//
//  Created by Oschepkov Aleksandr on 27.06.2026.
//

import SwiftUI
import AVFoundation

// MARK: - Оверлей с рамкой-прицелом
final class QRScannerOverlayView: UIView {
    /// Guide-слой, к которому можно привязывать другие элементы
    let scanRectGuide = UIView()
    
    /// Размер рамки сканирования (квадрат)
    private let scanRectSize: CGFloat = 260
    private let cornerLength: CGFloat = 28
    private let cornerLineWidth: CGFloat = 5
    private let cornerRadius: CGFloat = 8
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        scanRectGuide.backgroundColor = .clear
        addSubview(scanRectGuide)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let scanRect = CGRect(
            x: (bounds.width - scanRectSize) / 2,
            y: (bounds.height - scanRectSize) / 2,
            width: scanRectSize,
            height: scanRectSize
        )
        scanRectGuide.frame = scanRect
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let scanRect = CGRect(
            x: (bounds.width - scanRectSize) / 2,
            y: (bounds.height - scanRectSize) / 2,
            width: scanRectSize,
            height: scanRectSize
        )
        
        // 1. Затемнение всей области
        context.setFillColor(UIColor.black.withAlphaComponent(0.55).cgColor)
        context.fill(rect)
        
        // 2. Вырезаем прозрачное окно в центре (clear blend mode)
        context.setBlendMode(.clear)
        let clearPath = UIBezierPath(roundedRect: scanRect, cornerRadius: cornerRadius)
        context.addPath(clearPath.cgPath)
        context.fillPath()
        context.setBlendMode(.normal)
        
        // 3. Рисуем 4 уголка рамки
        let color = UIColor.systemGreen.cgColor
        context.setStrokeColor(color)
        context.setLineWidth(cornerLineWidth)
        context.setLineCap(.round)
        
        let corners: [(CGPoint, CGPoint)] = [
            // Верхний левый
            (CGPoint(x: scanRect.minX, y: scanRect.minY + cornerLength),
             CGPoint(x: scanRect.minX, y: scanRect.minY)),
            (CGPoint(x: scanRect.minX, y: scanRect.minY),
             CGPoint(x: scanRect.minX + cornerLength, y: scanRect.minY)),
            // Верхний правый
            (CGPoint(x: scanRect.maxX - cornerLength, y: scanRect.minY),
             CGPoint(x: scanRect.maxX, y: scanRect.minY)),
            (CGPoint(x: scanRect.maxX, y: scanRect.minY),
             CGPoint(x: scanRect.maxX, y: scanRect.minY + cornerLength)),
            // Нижний левый
            (CGPoint(x: scanRect.minX, y: scanRect.maxY - cornerLength),
             CGPoint(x: scanRect.minX, y: scanRect.maxY)),
            (CGPoint(x: scanRect.minX, y: scanRect.maxY),
             CGPoint(x: scanRect.minX + cornerLength, y: scanRect.maxY)),
            // Нижний правый
            (CGPoint(x: scanRect.maxX - cornerLength, y: scanRect.maxY),
             CGPoint(x: scanRect.maxX, y: scanRect.maxY)),
            (CGPoint(x: scanRect.maxX, y: scanRect.maxY),
             CGPoint(x: scanRect.maxX, y: scanRect.maxY - cornerLength))
        ]
        
        for (start, end) in corners {
            context.move(to: start)
            context.addLine(to: end)
            context.strokePath()
        }
    }
}
