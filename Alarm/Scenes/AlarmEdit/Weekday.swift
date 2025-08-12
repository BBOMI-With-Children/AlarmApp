//
//  Weekday.swift
//  Alarm
//
//  Created by 노가현 on 8/12/25.
//

import Foundation

// 월(0) ~ 일(6)
enum Weekday: Int, CaseIterable, Hashable {
  case mon = 0, tue, wed, thu, fri, sat, sun

  // 월 ~ 일
  var shortKo: String {
    ["월", "화", "수", "목", "금", "토", "일"][rawValue]
  }

  // 월요일 ~ 일요일
  var fullKo: String {
    ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"][rawValue]
  }

  // UNCalendar weekday(1=일 ~ 7=토) 매핑
  var rawValueForCalendar: Int {
    // 월(0)→2, 화→3, ..., 토→7, 일(6)→1
    [2, 3, 4, 5, 6, 7, 1][rawValue]
  }

  // UNCalendar weekday에서 Weekday로 역매핑
  init?(calendarWeekday: Int) {
    let map: [Int: Int] = [1: 6, 2: 0, 3: 1, 4: 2, 5: 3, 6: 4, 7: 5]
    guard let r = map[calendarWeekday] else { return nil }
    self.init(rawValue: r)
  }

  // 자주 쓰는 집합
  static let weekdays: Set<Weekday> = [.mon, .tue, .wed, .thu, .fri]
  static let weekend: Set<Weekday> = [.sat, .sun]
}
