//
//  WorldTimeViewModel.swift
//  Alarm
//
//  Created by 서광용 on 8/9/25.
//

import RxCocoa
import RxSwift

struct testDataModel {
  let city: String
  let subInfo: String
  let meridiem: String
  let time: String
}

final class WorldTimeViewModel {
  // 더미 데이터
  let timesRelay = BehaviorRelay<[testDataModel]>(value: [
    .init(city: "호브드", subInfo: "오늘, -2시간", meridiem: "오후", time: "09:34"),
    .init(city: "과테말라 시티", subInfo: "오늘, -15시간", meridiem: "오전", time: "08:34"),
    .init(city: "괌", subInfo: "내일, +1시간", meridiem: "오전", time: "00:35"),
    .init(city: "고텐부르크", subInfo: "오늘, -7시간", meridiem: "오후", time: "04:35")
  ])

  func deleteItem(_ index: Int) {
    var items = timesRelay.value
    items.remove(at: index)
    timesRelay.accept(items)
  }

  func moveItem(fromIndex: Int, toIndex: Int) {
    var items = timesRelay.value
    let moved = items.remove(at: fromIndex)
    items.insert(moved, at: toIndex)
    timesRelay.accept(items)
  }
}
