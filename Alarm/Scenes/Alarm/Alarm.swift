//
//  Alarm.swift
//  Alarm
//
//  Created by 노가현 on 8/8/25.
//

import Foundation

struct Alarm: Codable, Equatable {
    var id: UUID = UUID() // 알람 식별자 (저장/불러오기 할 때 복원 가능하도록 var로 선언)
    var time: String // 알람 시간
    var subtitle: String // 반복 주기
    var isOn: Bool // 알람 ON/OFF
}
