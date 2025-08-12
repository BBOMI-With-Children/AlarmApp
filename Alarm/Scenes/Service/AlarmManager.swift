//
//  AlarmManager.swift
//  Alarm
//
//  Created by 노가현 on 8/8/25.
//

import Foundation
import RxCocoa
import RxSwift

final class AlarmManager {
  static let shared = AlarmManager()

  private let key = "alarms"
  let alarms = BehaviorRelay<[Alarm]>(value: [])

  private init() {
    load()
    loadSampleDataIfEmpty()
  }

  // MARK: - Persistence

  private func load() {
    guard let data = UserDefaults.standard.data(forKey: key),
          let decoded = try? JSONDecoder().decode([Alarm].self, from: data) else { return }
    alarms.accept(decoded)
  }

  private func save() {
    guard let data = try? JSONEncoder().encode(alarms.value) else { return }
    UserDefaults.standard.set(data, forKey: key)
  }

  func loadSampleDataIfEmpty() {
    guard alarms.value.isEmpty else { return }
    let samples: [Alarm] = [
      .init(time: "오전 9:00", subtitle: "주중", isOn: false),
      .init(time: "오전 11:00", subtitle: "주중", isOn: false),
      .init(time: "오후 2:00", subtitle: "주중", isOn: false),
      .init(time: "오후 8:00", subtitle: "주중", isOn: false),
    ]
    alarms.accept(samples)
    save()
  }

  // MARK: - CRUD

  func add(_ alarm: Alarm) {
    var list = alarms.value
    list.append(alarm)
    alarms.accept(list)
    save()
  }

  func remove(id: UUID) {
    var list = alarms.value
    list.removeAll { $0.id == id }
    alarms.accept(list)
    save()
  }

  func remove(at index: Int) {
    var list = alarms.value
    guard list.indices.contains(index) else { return }
    list.remove(at: index)
    alarms.accept(list)
    save()
  }

  func toggle(id: UUID) {
    var list = alarms.value
    if let i = list.firstIndex(where: { $0.id == id }) {
      list[i].isOn.toggle()
      alarms.accept(list)
      save()
    }
  }

  func update(_ alarm: Alarm) {
    var list = alarms.value
    if let idx = list.firstIndex(where: { $0.id == alarm.id }) {
      list[idx] = alarm
      alarms.accept(list)
      save()
    }
  }
}
