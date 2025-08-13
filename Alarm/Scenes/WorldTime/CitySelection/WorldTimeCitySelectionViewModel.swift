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

struct CitySection {
  let title: String // "A" ~ "Z"
  var rows: [CityRow]
}

final class WorldTimeCitySelectionViewModel {
  init() {
    loadCityList()
  }
  
  // 출력(검색 적용된 리스트. 구독 대상)
  let rows = BehaviorRelay<[CityRow]>(value: [])
  // 알파벳 리스트 (A~Z)
  let sections = BehaviorRelay<[CitySection]>(value: [])
  
  // 원본 전체
  private var all: [CityRow] = []
  
  // MARK: 섹션 그룹화 (A~Z만)
  
  private func group(_ list: [CityRow]) -> [CitySection] {
    // A~Z키생성
    let alpha = (65...90).compactMap { String(UnicodeScalar($0)) } // 65~90: A~Z
    
    // cityGroup 섹션
    var cityGroup: [String: [CityRow]] = [:]
    for row in list {
      let trimmed = row.city.trimmingCharacters(in: .whitespacesAndNewlines) // 공백이랑 개행 제거하고
      guard let ch = trimmed.uppercased().first, ("A"..."Z").contains(ch) else { // 대만자 & 첫 값만 가져와서 포함되나 확인
        continue // 알파벳 아니면 건너뛰기
      }
      let key = String(ch)
      cityGroup[key, default: []].append(row) // 딕셔너리라 순서 x. 정렬 필요
    }
    
    // 정렬하고 배열 생성
    var result: [CitySection] = []
    for k in alpha { // A~Z 반복
      if var arr = cityGroup[k] {
        arr.sort { $0.displayText.localizedCompare($1.displayText) == .orderedAscending }
        result.append(CitySection(title: k, rows: arr))
      }
    }
    return result
  }
  
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
    sections.accept(group(all)) // 처음에 데이터 불러올 때 같이 그룹화도 진행
  }
  
  // MARK: - 서치바 검색 기능
  
  func filter(_ keyword: String) {
    guard !keyword.isEmpty else { return sections.accept(group(all)) }
    let k = keyword.lowercased() // 소문자
    // 입력한 소문자(k)가 포함되는지 필터링
    let filtered = all.filter { $0.city.lowercased().contains(k) || $0.continent.lowercased().contains(k) }
    sections.accept(group(filtered)) // 검색하여 sections 변경
  }
  
  // MARK: - 도시 이름
  
  private func cityName(_ tzID: String) -> String {
    let raw = tzID.split(separator: "/").last.map { String($0) } ?? "Other"
    return raw.replacingOccurrences(of: "_", with: " ") // New_York가 있다면 New Work로
  }
  
  // MARK: - 대륙 이름
  
  private func continentName(_ tzID: String) -> String {
    return tzID.split(separator: "/").first.map(String.init) ?? "Other"
  }
}
