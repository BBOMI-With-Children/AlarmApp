//
//  WorldTimeViewModel.swift
//  Alarm
//
//  Created by 서광용 on 8/9/25.
//

import Foundation
import RxCocoa
import RxSwift

struct WorldTimeItem {
  let timezoneID: String
  let city: String
  let gmt: String
  let meridiem: String
  let time: String
}

final class WorldTimeViewModel {
  let timesRelay = BehaviorRelay<[WorldTimeItem]>(value: [])
  private var minuteTimer: Disposable? // 구독 해제위해

  // MARK: UserDefaults

  private let storageKey = "worldTimes" // key값

  // TimeZones 저장
  private func saveTimeZonesForDefaults() {
    let ids = timesRelay.value.map { $0.timezoneID } // timezoneID를 ids에 넣어서 저장
    UserDefaults.standard.set(ids, forKey: storageKey)
  }

  // TimeZoneID를 도시명으로 사용 (ex: "Asia/Seoul" -> "Seoul")
  private func cityName(timezoneID: String) -> String {
    let city = timezoneID.split(separator: "/").last.map(String.init) ?? timezoneID // "New_York"
    return city.replacingOccurrences(of: "_", with: " ") // "New York"
  }

  // TimeZones 불러오기
  func loadTimeZonesFromDefaults() {
    let ids = UserDefaults.standard.stringArray(forKey: storageKey) ?? [] // storageKey값으로 받아옴
    let now = Date()
    let items: [WorldTimeItem] = ids.compactMap { id in
      guard let display = computeDisplay(timezoneID: id, now: now) else { return nil }
      return WorldTimeItem(
        timezoneID: id,
        city: cityName(timezoneID: id),
        gmt: display.gmt,
        meridiem: display.meridiem,
        time: display.time
      )
    }
    timesRelay.accept(items)
  }

  // MARK: - 공통 값 묶어서 계산: GMT(+/-n시간) / 오전/오후 / 시각

  private func computeDisplay(
    timezoneID: String,
    now: Date = Date(),
    locale: Locale = Locale(identifier: "ko_KR")
  ) -> (gmt: String, meridiem: String, time: String)? {
    // 타임존 생성 (타겟)
    guard let tz = TimeZone(identifier: timezoneID) else { return nil }

    // 날짜 기준(오늘/어제/내일) 계산
    let myTZ = TimeZone.current // 기기에 현재 설정된 타임존
    let myStart = Calendar.current.startOfDay(for: now) // 내 타임존의 자정

    var targetCal = Calendar.current // 현재 캘린더 (current가 기기의 현제 설정된 시스템)
    targetCal.timeZone = tz // 타겟의 timezone 적용해서, 그 도시 기준으로 변경
    let targetStart = targetCal.startOfDay(for: now) // target 타임존의 자정

    // 각자의 타임존의 자정을 비교하면, 그 도시 기준으로 내 위치가 오늘인지 내일인지 등 알 수 있음
    // dateComponents(_:from:to:) - 두 시각 사이를 지정한 단위로 분해해서 차이줌. 지금 day로 계산함
    let dayDiff = Calendar.current.dateComponents([.day], from: myStart, to: targetStart).day ?? 0
    let dayText: String = {
      switch dayDiff {
      case -1: return "어제"
      case 0: return "오늘"
      case 1: return "내일"
      default: return "이건 생각 못했는걸..?"
      }
    }()

    // GMT(+/- n시간)
    let secondsDiff = tz.secondsFromGMT(for: now) - myTZ.secondsFromGMT(for: now)
    let sign = secondsDiff >= 0 ? "+" : "-"
    let hours = abs(secondsDiff) / 3600 // 초 단위 절댓값을 사용해서 시간구함
    let gmt = "\(dayText), \(sign)\(hours)시간"

    // 오전/오후
    let ampmDF = DateFormatter()
    ampmDF.locale = locale // 표시 언어 (AM/PM 대신 오전/오후)
    ampmDF.timeZone = tz // 기준 시간대 (그 도시의 기준 시간)
    ampmDF.dateFormat = "a" // 오전/오후 ("a"가 오전/오후 지시자. 라고함 오..)
    let meridiem = ampmDF.string(from: now)

    // 시각
    let timeDF = DateFormatter()
    timeDF.locale = locale
    timeDF.timeZone = tz
    timeDF.dateFormat = "hh:mm" // 12시간제
    let time = timeDF.string(from: now)

    return (gmt, meridiem, time)
  }

  // MARK: - 도시 추가

  func addCity(_ row: CityRow) {
    var items = timesRelay.value
    // 중복 방지(timezone 기준)
    guard !items.contains(where: { $0.timezoneID == row.timezoneID }) else { return }

    // MARK: - 표시값 계산 (공통 함수 사용)

    let now = Date()
    guard let display = computeDisplay(timezoneID: row.timezoneID, now: now) else { return }

    // 추가!
    let item = WorldTimeItem(timezoneID: row.timezoneID, city: row.city, gmt: display.gmt, meridiem: display.meridiem, time: display.time)
    items.append(item)
    timesRelay.accept(items)
    saveTimeZonesForDefaults()
  }

  // MARK: - 도시 삭제

  func deleteCity(_ index: Int) {
    var items = timesRelay.value
    items.remove(at: index)
    timesRelay.accept(items)
    saveTimeZonesForDefaults()
  }

  // MARK: - 도시 인덱스 이동

  func moveCity(fromIndex: Int, toIndex: Int) {
    var items = timesRelay.value
    let moved = items.remove(at: fromIndex)
    items.insert(moved, at: toIndex)
    timesRelay.accept(items)
    saveTimeZonesForDefaults()
  }

  // MARK: - 분 단위 자동 갱신 (Timer)

  func startMinuteUpdates() {
    stopMinuteUpdates() // 이전에 돌던 타이머 있으면 중지
    let now = Date()
    let calendar = Calendar.current
    // 지금(now) 이후의 날짜 중에, second == 0인 시간을 구함 (다음 00초인 '분')
    // matchingPolicy: .nextTime -> 현재 시간 이후에 조건에 맞는 다음 시각을 찾음
    let nextMinute = calendar.nextDate(after: now, matching: DateComponents(second: 0), matchingPolicy: .nextTime) ?? now.addingTimeInterval(60)

    // .timeIntervalSince: 두 날짜의 차이를 초 단위로 반환함 (즉, 다음 분까지 남은 초가 delay에 들어가게됨)
    let delay = Int(ceil(nextMinute.timeIntervalSince(now) * 1000)) // ms단위로 변환해서 ceil로 소수점 올림 계산
    minuteTimer = Observable<Int>.timer(
      .milliseconds(delay), // 다음 분 00초에 첫 실행
      period: .seconds(60), // 이후 60초마다 실행
      scheduler: MainScheduler.instance
    ) // 타이머가 작동되는 60초마다 refreshDisplayedTimes 실행
    .subscribe(with: self) { vc, _ in
      vc.updateWorldTimes()
    }
  }

  // MARK: - 타이머 정지

  func stopMinuteUpdates() {
    minuteTimer?.dispose()
    minuteTimer = nil
  }

  // MARK: - 세계 시각 업데이트

  func updateWorldTimes() {
    let now = Date()

    // 데이터를 다시 받아와서 리프레쉬!
    let newItems = timesRelay.value.map { item -> WorldTimeItem in
      guard let display = computeDisplay(timezoneID: item.timezoneID, now: now) else { return item }
      return WorldTimeItem(timezoneID: item.timezoneID, city: item.city, gmt: display.gmt, meridiem: display.meridiem, time: display.time)
    }
    timesRelay.accept(newItems)
  }
}
