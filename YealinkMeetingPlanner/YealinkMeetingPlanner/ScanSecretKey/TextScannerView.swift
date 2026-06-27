//
//  TextScannerView.swift
//  scantext
//
//  Created by Oschepkov Aleksandr on 27.06.2026.
//
//
//
import SwiftUI
import AVFoundation

struct QRScannerView: UIViewControllerRepresentable {
    let onScanSuccess: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let vc = QRScannerViewController()
        vc.onCodeScanned = { code in
            onScanSuccess(code)
            dismiss()
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}
