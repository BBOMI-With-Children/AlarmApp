//
//  AlarmManager.swift
//  Alarm
//
//  Created by 노가현 on 8/8/25.
//

import Foundation
import RxCocoa
import RxSwift
import UserNotifications

final class AlarmManager {
  static let shared = AlarmManager()

  private let key = "alarms"
  let alarms = BehaviorRelay<[Alarm]>(value: [])

  private init() {
    load()
    loadSampleDataIfEmpty()
    syncScheduledFromState()
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

    if alarm.isOn { schedule(alarm) }
  }

  func remove(id: UUID) {
    var list = alarms.value
    list.removeAll { $0.id == id }
    alarms.accept(list)
    save()

    cancel(id: id)
  }

  func remove(at index: Int) {
    var list = alarms.value
    guard list.indices.contains(index) else { return }

    // 삭제된 알람을 참조, 예약 취소
    let removed = list.remove(at: index)
    alarms.accept(list)
    save()

    cancel(id: removed.id)
  }

  func toggle(id: UUID) {
    var list = alarms.value
    guard let i = list.firstIndex(where: { $0.id == id }) else { return }

    list[i].isOn.toggle()
    let updated = list[i]
    alarms.accept(list)
    save()

    if updated.isOn {
      schedule(updated)
    } else {
      cancel(id: updated.id)
    }
  }

  func update(_ alarm: Alarm) {
    var list = alarms.value
    guard let idx = list.firstIndex(where: { $0.id == alarm.id }) else { return }

    list[idx] = alarm
    alarms.accept(list)
    save()

    // 기존 예약 제거 후, isOn일 때만 다시 예약
    cancel(id: alarm.id)
    if alarm.isOn { schedule(alarm) }
  }

  // MARK: - Scheduling

  // 저장된 상태 기준으로 알림센터 초기화, 켜진 알람만 재예약
  private func syncScheduledFromState() {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
    center.removeAllDeliveredNotifications()

    alarms.value.filter { $0.isOn }.forEach { schedule($0) }
  }

  // 알람 예약 (isOn이 true일 때만 호출)
  private func schedule(_ alarm: Alarm) {
    guard let tm = parseTimeComponents(from: alarm.time),
          let hour = tm.hour, let minute = tm.minute else { return }
    let center = UNUserNotificationCenter.current()

    let content = UNMutableNotificationContent()
    content.body = alarm.subtitle.isEmpty ? "알람" : alarm.subtitle
    content.sound = UNNotificationSound(named: .init("radial.caf"))
    if #available(iOS 15.0, *) { content.interruptionLevel = .timeSensitive }

    // subtitle을 해석해 반복 요일 결정
    let weekdays = parseWeekdays(from: alarm.subtitle)

    let base = "alarm.\(alarm.id.uuidString)"

    if weekdays.isEmpty {
      // "오늘" 또는 해석 불가 → 다음 발생 시각으로 1회성 예약
      let next = nextDate(forHour: hour, minute: minute)
      let dc = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: next)
      let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: false)
      let req = UNNotificationRequest(identifier: "\(base).once", content: content, trigger: trigger)
      center.add(req) { if let e = $0 { print("add once error:", e) } }
      return
    }

    // 요일 반복 예약
    for w in weekdays {
      var dc = DateComponents()
      dc.weekday = w
      dc.hour = hour
      dc.minute = minute
      let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
      let id = "\(base).weekday.\(w)"
      let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
      center.add(req) { if let e = $0 { print("add weekday error:", e) } }
    }
  }

  // 예약 취소
  private func cancel(id: UUID) {
    let center = UNUserNotificationCenter.current()

    var ids: [String] = [id.uuidString]

    let base = "alarm.\(id.uuidString)"
    ids.append("\(base).once")
    ids.append(contentsOf: (1 ... 7).map { "\(base).weekday.\($0)" })

    center.removePendingNotificationRequests(withIdentifiers: ids)
    center.removeDeliveredNotifications(withIdentifiers: ids)
  }

  // MARK: - Utils

  // 오전 7:00  → DateComponents(hour, minute)
  private func parseTimeComponents(from display: String) -> DateComponents? {
    let fKO = DateFormatter()
    fKO.locale = Locale(identifier: "ko_KR")
    fKO.dateFormat = "a h:mm"

    let fEN = DateFormatter()
    fEN.locale = Locale(identifier: "en_US_POSIX")
    fEN.dateFormat = "a h:mm"

    let date = fKO.date(from: display) ?? fEN.date(from: display)
    guard let date else { return nil }
    return Calendar.current.dateComponents([.hour, .minute], from: date)
  }

  // 오늘 기준 다음 발생 시각
  private func nextDate(forHour hour: Int, minute: Int) -> Date {
    let cal = Calendar.current
    let now = Date()
    let today = cal.date(bySettingHour: hour, minute: minute, second: 0, of: now)!
    return today > now ? today : cal.date(byAdding: .day, value: 1, to: today)!
  }

  // subtitle 파싱 → 반복 요일 집합
  private func parseWeekdays(from subtitle: String) -> Set<Int> {
    let s = subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
    if s.isEmpty { return [] }

    let sun = 1, mon = 2, tue = 3, wed = 4, thu = 5, fri = 6, sat = 7

    // 특수
    if s.contains("주중") { return [mon, tue, wed, thu, fri] }
    if s.contains("주말") { return [sat, sun] }
    if s.contains("오늘") { return [] } // 1회성

    // 한글 요일 문자만 스캔
    let cleaned = s
      .replacingOccurrences(of: "요일", with: "")
      .replacingOccurrences(of: "마다", with: "")
      .replacingOccurrences(of: " ", with: "")

    var result = Set<Int>()
    for ch in cleaned {
      switch ch {
      case "월": result.insert(mon)
      case "화": result.insert(tue)
      case "수": result.insert(wed)
      case "목": result.insert(thu)
      case "금": result.insert(fri)
      case "토": result.insert(sat)
      case "일": result.insert(sun)
      default: break
      }
    }
    return result
  }
}
