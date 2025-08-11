//
//  WorldTimeCitySelectionViewModel.swift
//  Alarm
//
//  Created by 서광용 on 8/11/25.
//

import Foundation
import RxSwift
import RxCocoa

struct CityRow {
  let timezoneID: String   // "Asia/Seoul"
  let city: String         // "서울"
  let country: String      // "대한민국"
  var displayText: String { "\(city), \(country)" } // 셀에 보일 형식
}

final class WorldTimeCitySelectionViewModel {
  init() {
    loadCityList()
  }
  
  // 출력(검색 적용된 리스트. 구독 대상)
  let rows = BehaviorRelay<[CityRow]>(value: [])

  // 원본 전체
  private var all: [CityRow] = []

  // 국가 매핑
  private let countryNames: [String:String] = [
    "Asia/Seoul": "대한민국",
    "Asia/Tokyo": "일본",
    "America/New_York": "미국",
    "Europe/London": "영국",
    "Europe/Paris": "프랑스",
    "Europe/Berlin": "독일",
    "Australia/Sydney": "호주",
    "Asia/Hong_Kong": "홍콩",
    "Asia/Bangkok": "태국"
  ]

  private let locale = Locale(identifier: "ko_KR")

  // MARK: - 타임존 로드
  private func loadCityList() {
    // 불필요한 표기 삭제 (Etc, GMT)
    let ids = TimeZone.knownTimeZoneIdentifiers
      .filter { !$0.hasPrefix("Etc/") && !$0.contains("GMT") }

    all = ids.map { id in
      let city = cityName(id)
      let country = countryNames[id] ?? continentName(id)
      return CityRow(timezoneID: id, city: city, country: country)
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
    let filtered = all.filter { $0.city.lowercased().contains(k) || $0.country.lowercased().contains(k) }
    rows.accept(filtered) // 검색한걸로 rows 변경
  }

  // MARK: - 도시 이름만 사용
  private func cityName(_ tzID: String) -> String {
    let raw = tzID.split(separator: "/").last.map { String($0) } ?? tzID
    return raw.replacingOccurrences(of: "_", with: " ") // New_York가 있다면 New Work로
  }

  // MARK: - 대륙 이름만 사용
  private func continentName(_ tzID: String) -> String {
    let region = tzID.split(separator: "/").first.map(String.init) ?? "기타"
    switch region {
    case "Asia": return "아시아"
    case "Europe": return "유럽"
    case "America": return "아메리카"
    case "Africa": return "아프리카"
    case "Australia": return "오세아니아"
    case "Pacific": return "태평양"
    default: return region
    }
  }
}