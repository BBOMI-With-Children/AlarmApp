//
//  StopWatchViewModel.swift
//  Alarm
//
//  Created by 김이든 on 8/8/25.
//

import Foundation
import RxCocoa
import RxSwift

final class StopwatchViewModel {
  // 현재 타이머가 실행 중인지 알려주는 상태 (true: 실행중, false: 멈춤)
  let isRunning = BehaviorRelay<Bool>(value: false)
  // 스톱워치가 시작된 이후 경과된 시간 (TimeInterval은 초 단위: Double 타입)
  let timePassed = BehaviorRelay<TimeInterval>(value: 0)
  // 랩타임
  let laps = BehaviorRelay<[LapTime]>(value: [])

  // 구독 해제를 원하는 시점을 직접 제어할 수 있어서 DisposeBag 대신 사용
  private var timerDisposable: Disposable?
  // 타이머 시작 시점 (Date 객체)
  private var startDate: Date?
  // 이전에 실행됐던 경과 시간(초)을 누적 저장
  private var totalTime: TimeInterval = 0
  // 이전 랩타임 시점의 전체 시간
  private var lastLapTotalTime: TimeInterval = 0
}

// MARK: - 타이머 로직

extension StopwatchViewModel {
  // 타이머 실행, 중지 버튼 누를 때마다 호출
  func togglePlayPause() {
    isRunning.value ? stopTimer() : startTimer() // 실행 중이면 멈춤 처리 / 멈춰 있으면 시작 처리
  }

  // 타이머 시작
  private func startTimer() {
    isRunning.accept(true) // 실행 상태를 true로 변경
    startDate = Date() // 현재 시각 저장 (타이머 시작 기준점)

    // 0.01초마다 실행되는 타이머 구독 생성
    timerDisposable = Observable<Int>.interval(.milliseconds(10), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        guard let self, let startDate = self.startDate else { return }
        // 현재 시간과 시작 시간 차이 + 누적 시간 계산
        let currentPassedTime = Date().timeIntervalSince(startDate) + self.totalTime
        // timePassed 업데이트
        self.timePassed.accept(currentPassedTime)
      })
  }

  // 타이머 중지
  private func stopTimer() {
    isRunning.accept(false) // 실행 상태 false로 변경
    if let startDate = startDate {
      // 지금까지 흐른 시간(현재 시각 - 시작 시각)을 누적 시간에 더함
      totalTime += Date().timeIntervalSince(startDate)
    }
    // 타이머 구독 해제 (메모리 누수 방지)
    timerDisposable?.dispose()
    timerDisposable = nil
    startDate = nil // 시작 시각 초기화
  }

  // 타이머 초기화
  func resetTimer() {
    stopTimer()
    totalTime = 0
    timePassed.accept(0)
    laps.accept([]) // 랩타임 목록 초기화
    lastLapTotalTime = 0
  }
}

// MARK: - 랩타임 로직

extension StopwatchViewModel {
  func recordLap() {
    let currentTotalTime = timePassed.value
    let lapDuration = currentTotalTime - lastLapTotalTime

    let lapNumber = laps.value.count + 1
    let newLap = LapTime(number: lapNumber, time: lapDuration)

    var updatedLaps = laps.value
    updatedLaps.insert(newLap, at: 0) // 최신 랩이 위로 오도록
    laps.accept(updatedLaps)

    lastLapTotalTime = currentTotalTime
  }
}

// MARK: - UI 표시용 함수

extension StopwatchViewModel {
  func formatTime(_ time: TimeInterval) -> String {
    let totalMilliseconds = Int(time * 100)
    let totalSeconds = totalMilliseconds / 100
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    let milliseconds = totalMilliseconds % 100

    return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
  }
}
