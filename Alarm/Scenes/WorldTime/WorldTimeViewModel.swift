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
  let city: String
  let gmt: String
  let meridiem: String
  let time: String
}

final class WorldTimeViewModel {
  let timesRelay = BehaviorRelay<[WorldTimeItem]>(value: [])

  func addCity(_ row: CityRow) {
    // TODO: 로직이 몰려서.. 다 끝낸 이후 쪼갤 예정
    // 중복 방지(city 기준)
    let items = timesRelay.value
    if items.contains(where: { $0.city == row.city }) { return }

    // MARK: - 타임존 통해서 GMT 계산

    // 타임존 생성 (타겟)
    guard let tz = TimeZone(identifier: row.timezoneID) else { return } // 받아온 timeZoneID로 생성
    let now = Date()
    var targetCal = Calendar.current // 현재 캘린더
    targetCal.timeZone = tz // 타겟의 timezone 적용해서, 그 도시 기준으로 변경

    let myStart = Calendar.current.startOfDay(for: now) // 내 타임존의 자정
    let targetStart = targetCal.startOfDay(for: now) // 타킷 타임존의 자정
    // 각자의 타임존의 자정을 비교하면, 그 도시 기준으로 내 위치가 오늘인지 내일인지 등 알 수 있음
    // dateComponents(_:from:to:) - 두 시각 사이를 지정한 단위로 분해해서 차이줌. 지금 day로 계산함
    let dayDiff = Calendar.current.dateComponents([.day], from: myStart, to: targetStart).day ?? 0

    var GMTDayText: String {
      switch dayDiff {
      case -1: return "어제"
      case 0: return "오늘"
      case 1: return "내일"
      default: return "이건 생각 못했는걸..?"
      }
    }

    let seconds = tz.secondsFromGMT(for: now)
    let sign = seconds >= 0 ? "+" : "-"
    let absSec = abs(seconds) // 초 단위 절댓값으로 (어차피 부호는 위에서 구하니까)
    let hours = absSec / 3600 // 시간구함

    let gmt = "\(GMTDayText), \(sign)\(hours)시간" // 오늘, +12시간

    // MARK: - 오전/오후, 시각
  }

  func deleteCity(_ index: Int) {
    var items = timesRelay.value
    items.remove(at: index)
    timesRelay.accept(items)
  }

  func moveCity(fromIndex: Int, toIndex: Int) {
    var items = timesRelay.value
    let moved = items.remove(at: fromIndex)
    items.insert(moved, at: toIndex)
    timesRelay.accept(items)
  }
}
