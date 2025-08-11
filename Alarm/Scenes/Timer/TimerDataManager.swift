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

  private var items: [TimerItem] = []  // 데이터 저장소

  private let subject = BehaviorSubject<[TimerItem]>(value: []) // 값이 변화할 때마다 결과 방출.
  var timers: Observable<[TimerItem]> { subject.asObservable() }

  private let queue = DispatchQueue(label: "TimerManager.queue") // 순서대로 처리하기 위한 큐

  private init() {}

  func loadTimers() {  // 초기 조회(userDefault에서 읽고 items에 담아 onNext로 방출해 구독 동기화
    queue.sync {
      self.items = Self.loadFromUserDefaults()
      self.subject.onNext(self.items)
    }
  }

  private func saveTimers() { // userDefault에 저장
    Self.saveToUserDefaults(items)
  }

  @discardableResult
  func mutate<T>(_ block: (inout [TimerItem]) -> T) -> T {
    queue.sync {
      let result = block(&items)  // 배열 직접 수정(수정 + 결과 계산)
      subject.onNext(items)       // 변경 방출
      saveTimers()                // 저장
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
