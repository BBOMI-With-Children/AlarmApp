//
//  StopWatchModel.swift
//  Alarm
//
//  Created by 김이든 on 8/10/25.
//

import Foundation

struct StopWatchModel: Codable, Hashable {
  struct Lap: Codable, Hashable {
    let number: Int
    let time: TimeInterval
  }

  var isRunning: Bool
  var startDate: Date?
  var totalTime: TimeInterval
  var lastLapTotalTime: TimeInterval
  var laps: [Lap]
}
