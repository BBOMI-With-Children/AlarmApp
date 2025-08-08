//
//  TimerDataManager.swift
//  Alarm
//
//  Created by luca on 8/7/25.
//

import Foundation
import RxSwift

final class TimerDataManager {  // 타이머 데이터 저장/조회
  static let shared = TimerDataManager()
  private init() {}
  private let key = "savedTimers"

  let timers = BehaviorSubject<[TimerItem]>(value: [])

  func saveTimers() {  // userDefault 전체 배열 저장
    if let items = try? timers.value(),
      let data = try? JSONEncoder().encode(items)
    {
      UserDefaults.standard.set(data, forKey: key)
    }
  }

  func loadTimers() {  // userDefault 조회
    if let data = UserDefaults.standard.data(forKey: key),
      let loaded = try? JSONDecoder().decode([TimerItem].self, from: data)
    {
      timers.onNext(loaded)
    }
  }

  func addTimer(_ timer: TimerItem) {  // 배열에 데이터 추가
    var current = (try? timers.value()) ?? []
    current.append(timer)
    current = sortTimers(current)
    timers.onNext(current)
    saveTimers()
  }

  func removeTimer(at index: Int) {
    var current = (try? timers.value()) ?? []
    guard current.indices.contains(index) else { return }
    current.remove(at: index)
    timers.onNext(current)
    saveTimers()
  }

  func sortTimers(_ items: [TimerItem]) -> [TimerItem] {
    return items.sorted { lhs, rhs in
      if lhs.time == rhs.time {
        return lhs.id.uuidString < rhs.id.uuidString
      }
      return lhs.time < rhs.time
    }
  }
}

// MARK: - UITableViewDataStruct

struct TimerItem: Codable {
  let id: UUID
  var time: TimeInterval
  let label: String
  var isActive: Bool
}
