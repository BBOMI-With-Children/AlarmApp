//
//  StopWatchModel.swift
//  Alarm
//
//  Created by 김이든 on 8/10/25.
//

import Foundation

struct LapTime: Hashable {
  let id = UUID()
  let number: Int
  let time: TimeInterval
}
