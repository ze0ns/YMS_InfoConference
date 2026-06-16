//
//  ConfModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 06.06.2026.
//


import Foundation
struct ConfModel: Identifiable, Hashable {
  var id: UUID = .init()
  var timePeriod: String
  var fioIniciator: String
}
