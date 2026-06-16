//
//  ScheduleRow.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 28.05.2026.
//

import SwiftUI
struct ScheduleRow: View {
    let time: String
    let isBusy: Bool
    let title: String?
    
    var body: some View {
        HStack {
            Text(time)
                .font(.subheadline)
                .frame(width: 50, alignment: .leading)
            
            Rectangle()
                .fill(isBusy ? Color.red.opacity(0.3) : Color.green.opacity(0.2))
                .frame(height: 36)
                .cornerRadius(6)
                .overlay(
                    HStack {
                        if isBusy, let title = title {
                            Text(title)
                                .font(.caption)
                                .bold()
                                .foregroundColor(.red)
                                .padding(.leading, 8)
                        } else {
                            Text("Свободно")
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.leading, 8)
                        }
                        Spacer()
                    }
                )
        }
    }
}
