//
//  StopWatchUserDefaults.swift
//  Alarm
//
//  Created by 김이든 on 8/12/25.
//

import Foundation

final class StopWatchUserDefaults {
  private let key = "stopwatch.model"

  func save(_ model: StopWatchModel) {
    guard let data = try? JSONEncoder().encode(model) else { return }
    UserDefaults.standard.set(data, forKey: key)
  }

  func load() -> StopWatchModel? {
    guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
    return try? JSONDecoder().decode(StopWatchModel.self, from: data)
  }

  func clear() {
    UserDefaults.standard.removeObject(forKey: key)
  }
}
