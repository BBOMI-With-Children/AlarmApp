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

  private var items: [TimerItem] = []  // 데이터 배열

  private let subject = BehaviorSubject<[TimerItem]>(value: [])
  var timers: Observable<[TimerItem]> { subject.asObservable() }

  private let queue = DispatchQueue(label: "TimerManager.queue")

  private init() {}

  func loadTimers() {  // 초기 조회
    queue.sync {
      self.items = Self.loadFromUserDefaults()
      self.subject.onNext(self.items)
    }
  }

  private func saveTimers() {
    Self.saveToUserDefaults(items)
  }

  @discardableResult
  func mutate<T>(_ block: (inout [TimerItem]) -> T) -> T {
    queue.sync {
      let result = block(&items)
      subject.onNext(items)
      saveTimers()
      return result
    }
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

extension TimerDataManager {
  fileprivate static let key = "savedTimers"

  fileprivate static func loadFromUserDefaults() -> [TimerItem] {
    guard let data = UserDefaults.standard.data(forKey: key),
      let decoded = try? JSONDecoder().decode([TimerItem].self, from: data)
    else {
      return []
    }
    return decoded
  }

  fileprivate static func saveToUserDefaults(_ items: [TimerItem]) {
    guard let data = try? JSONEncoder().encode(items) else { return }
    UserDefaults.standard.set(data, forKey: key)
  }
}

// MARK: - UITableViewDataStruct

struct TimerItem: Codable {
  let id: UUID
  var time: TimeInterval
  let label: String
  var isActive: Bool
}
