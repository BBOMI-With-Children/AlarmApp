//
//  AlarmManager.swift
//  Alarm
//
//  Created by 노가현 on 8/8/25.
//

import Foundation

final class AlarmManager {
  static let shared = AlarmManager()
  private init() { load() }

  private let key = "alarms"
  private(set) var alarms: [Alarm] = []

  // 샘플 데이터
  func loadSampleData() {
    alarms = [
      Alarm(time: "오전 9:00", subtitle: "주중", isOn: false),
      Alarm(time: "오전 11:00", subtitle: "주중", isOn: false),
      Alarm(time: "오후 2:00", subtitle: "주중", isOn: false),
      Alarm(time: "오후 8:00", subtitle: "주중", isOn: false)
    ]
    save()
  }

  // UserDefaults에서 데이터 불러오기
  func load() {
    if let data = UserDefaults.standard.data(forKey: key),
       let decoded = try? JSONDecoder().decode([Alarm].self, from: data)
    {
      alarms = decoded
    }
  }

  // UserDefaults에 데이터 저장
  func save() {
    if let data = try? JSONEncoder().encode(alarms) {
      UserDefaults.standard.set(data, forKey: key)
    }
  }

  // 알람 추가
  func add(_ alarm: Alarm) {
    alarms.append(alarm)
    save()
  }

  // 알람 삭제
  func remove(id: UUID) {
    alarms.removeAll { $0.id == id }
    save()
  }

  // 알람 ON/OFF 토글
  func toggle(id: UUID) {
    guard let index = alarms.firstIndex(where: { $0.id == id }) else { return }
    alarms[index].isOn.toggle()
    save()
  }

  func move(from: Int, to: Int) {
    var list = alarms
    let item = list.remove(at: from)
    list.insert(item, at: to)
    alarms = list
    save()
  }
}
