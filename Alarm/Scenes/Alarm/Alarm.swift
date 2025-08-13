//
//  Alarm.swift
//  Alarm
//
//  Created by 노가현 on 8/8/25.
//

import Foundation

struct Alarm: Codable, Equatable, Identifiable {
  let id: UUID
  var time: String // 알람 시간
  var subtitle: String // 반복 주기
  var isOn: Bool // 알람 ON/OFF

  init(id: UUID = UUID(), time: String, subtitle: String, isOn: Bool) {
    self.id = id
    self.time = time
    self.subtitle = subtitle
    self.isOn = isOn
  }
}
