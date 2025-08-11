//
//  WorldTimeCitySelectionViewModel.swift
//  Alarm
//
//  Created by 서광용 on 8/11/25.
//

import Foundation
import RxCocoa
import RxSwift

struct CityRow {
  let timezoneID: String // "Asia/Seoul"
  let city: String // "Seoul"
  let continent: String // "Asia"
  var displayText: String { "\(city), \(continent)" } // 셀에 보일 형식
}

final class WorldTimeCitySelectionViewModel {
  init() {
    loadCityList()
  }

  // 출력(검색 적용된 리스트. 구독 대상)
  let rows = BehaviorRelay<[CityRow]>(value: [])

  // 원본 전체
  private var all: [CityRow] = []

  // MARK: - 타임존 로드

  private func loadCityList() {
    // 불필요한 표기 삭제 (Etc, GMT)
    let ids = TimeZone.knownTimeZoneIdentifiers
      .filter { !$0.hasPrefix("Etc/") && !$0.contains("GMT") }

    all = ids.map { id in
      let city = cityName(id)
      let continent = continentName(id)
      return CityRow(timezoneID: id, city: city, continent: continent)
    }
    // localizedCompare: 시스템 언어 설정에 맞춰 가나다/ABC 순으로 비교. orderedAscending(오름차순 정렬)
    all.sort { $0.displayText.localizedCompare($1.displayText) == .orderedAscending }
    rows.accept(all)
  }

  // MARK: - 서치바 검색 기능

  func filter(_ keyword: String) {
    guard !keyword.isEmpty else { return rows.accept(all) }
    let k = keyword.lowercased() // 소문자
    // 입력한 소문자(k)가 포함되는지 필터링
    let filtered = all.filter { $0.city.lowercased().contains(k) || $0.continent.lowercased().contains(k) }
    rows.accept(filtered) // 검색한걸로 rows 변경
  }

  // MARK: - 도시 이름

  private func cityName(_ tzID: String) -> String {
    let raw = tzID.split(separator: "/").last.map { String($0) } ?? tzID
    return raw.replacingOccurrences(of: "_", with: " ") // New_York가 있다면 New Work로
  }

  // MARK: - 대륙 이름

  private func continentName(_ tzID: String) -> String {
    return tzID.split(separator: "/").first.map(String.init) ?? "Other"
    }
  }

