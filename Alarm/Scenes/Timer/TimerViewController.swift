//
//  TimerViewController.swift
//  Alarm
//
//  Created by 노가현 on 8/5/25.
//

import RxSwift
import SnapKit
import Then
import UIKit
import UserNotifications

final class TimerViewController: UIViewController {
  // MARK: - Lifecycle

  private lazy var timerTableView = UITableView(frame: .zero, style: .plain).then {
    $0.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = true
    $0.backgroundColor = .clear
  }

  private let disposeBag = DisposeBag()
  private var timerItems: [TimerItem] = []

  // 시스템 예약된 알림 추적(중복 방지)
  private var scheduledAlarmIds = Set<UUID>()

  override func viewDidLoad() {
    super.viewDidLoad()

    // 앱 재진입 시, 이미 울린 알림을 확인해 타이머 정리
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(sweepDeliveredNotificationsAndCleanup),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )

    requestNotificationPermission()  // 알림 권한 요청
    UNUserNotificationCenter.current().delegate = self
    TimerDataManager.shared.loadTimers()  // 타이머 데이터 조회

    TimerDataManager.shared.timers  // timers 구독
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] items in
        self?.timerItems = items  // 최신 스냅숏 반영
        self?.timerTableView.reloadData()

        // 활성 타이머에 대해 시스템 알림 예약 동기화
        let active = items.filter { $0.isActive && $0.time > 0 }
        let activeIds = Set(active.map { $0.id })

        // 새로 활성화된 타이머 예약
        let toSchedule = activeIds.subtracting(self?.scheduledAlarmIds ?? [])
        toSchedule.forEach { id in
          if let item = items.first(where: { $0.id == id }) {
            self?.scheduleSystemAlarm(for: item)
            self?.scheduledAlarmIds.insert(id)
          }
        }

        // 비활성/삭제/0초 도달 타이머는 예약 취소
        let toCancel = (self?.scheduledAlarmIds ?? []).subtracting(activeIds)
        toCancel.forEach { id in
          self?.cancelSystemAlarm(forId: id)
          self?.scheduledAlarmIds.remove(id)
        }
      })
      .disposed(by: disposeBag)

    // 타이머(1초마다 이벤트 처리)
    Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        var finished: [TimerItem] = []
        TimerDataManager.shared.mutate { items in
          var justFinished: [TimerItem] = []
          for i in items.indices {
            if items[i].isActive, items[i].time > 0 {
              items[i].time -= 1
              if items[i].time == 0 { justFinished.append(items[i]) }
            }
          }
          if !justFinished.isEmpty {
            let ids = Set(justFinished.map { $0.id })
            // 포그라운드 즉시 배너/사운드 표시를 위해 시스템 예약 알림 취소 후, 항목 제거
            for id in ids { self.cancelSystemAlarm(forId: id); self.scheduledAlarmIds.remove(id) }
            // 셀 제거
            items.removeAll { ids.contains($0.id) }
          }
          finished = justFinished
        }
        // 포그라운드: 즉시 배너/사운드 표시
        finished.forEach { self.notifyTimerFinished($0) }
      })
      .disposed(by: disposeBag)
    configureUI()
    setupNavigationBar()
  }

  // MARK: - Private Methods

  private func configureUI() {
    view.backgroundColor = UIColor(named: "backgroundColor")
    title = "타이머"

    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.largeTitleDisplayMode = .always

    view.addSubview(timerTableView)
    timerTableView.dataSource = self
    timerTableView.register(TimerTableViewCell.self, forCellReuseIdentifier: TimerTableViewCell.reuseIdentifier)

    timerTableView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }

  // 상단 내비게이션바 버튼
  private func setupNavigationBar() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      systemItem: .add,
      primaryAction: UIAction { [weak self] _ in
        self?.presentAddTimerViewController()
      },
      menu: nil
    ).then {
      $0.tintColor = UIColor(named: "mainColor")
    }

    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = UIColor(named: "backgroundColor")

    appearance.shadowColor = .clear

    navigationController?.navigationBar.standardAppearance = appearance
    navigationController?.navigationBar.scrollEdgeAppearance = appearance
  }

  // 타이머 추가 페이지 전환
  private func presentAddTimerViewController() {
    let addVC = AddTimerViewController()
    let nav = UINavigationController(rootViewController: addVC)
    nav.modalPresentationStyle = .formSheet
    present(nav, animated: true)
  }

  // 타이머 셀의 정렬
  private func timerCellSort(_ a: TimerItem, _ b: TimerItem) -> Bool {
    if a.time == b.time { return a.id.uuidString < b.id.uuidString }
    return a.time < b.time
  }

  // 권한 요청
  private func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, err in
      if let err = err {  // 에러일 때
        print("requestNotificationPermission: \(err)")
      } else {
        print("\(granted)")  // 권한 파악
      }
    }
  }

  // 타이머 끝나면 알람
  private func notifyTimerFinished(_ item: TimerItem) {
    let content = UNMutableNotificationContent()
    content.title = "타이머"
    content.body = item.label
    content.sound = UNNotificationSound(named: UNNotificationSoundName("radial.caf"))
    let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: nil)
    UNUserNotificationCenter.current().add(request) { err in
      if let err = err { print("notifyTimerFinished: \(err)") }
    }
  }

  // 앱 활성화 시, 이미 울린 알림을 확인하여 해당 타이머 삭제
  @objc private func sweepDeliveredNotificationsAndCleanup() {
    UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] delivered in
      guard let self = self else { return }
      let firedIds = delivered.map { UUID(uuidString: $0.request.identifier) }.compactMap { $0 }
      if firedIds.isEmpty { return }
      TimerDataManager.shared.mutate { items in
        items.removeAll { firedIds.contains($0.id) }
      }
      // 정리한 알림은 알림 센터 목록에서도 제거
      let idStrings = firedIds.map { $0.uuidString }
      UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: idStrings)
      // 예약 추적도 정리
      firedIds.forEach { self.scheduledAlarmIds.remove($0) }
    }
  }
}

// MARK: - UITableView

extension TimerViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return timerItems.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell =
      tableView.dequeueReusableCell(
        withIdentifier: TimerTableViewCell.reuseIdentifier,
        for: indexPath
      ) as! TimerTableViewCell

    let item = timerItems[indexPath.row]
    cell.configureUI(with: item)

    cell.onToggleActive = { [weak self] in  // 클로저 설정
      guard let self = self else { return }
      TimerDataManager.shared.mutate { items in
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
          items[idx].isActive.toggle()
          if items[idx].isActive {
            self.scheduleSystemAlarm(for: items[idx])
            self.scheduledAlarmIds.insert(items[idx].id)
          } else {
            self.cancelSystemAlarm(forId: items[idx].id)
            self.scheduledAlarmIds.remove(items[idx].id)
          }
          if items[idx].isActive == false {
            items.sort(by: self.timerCellSort)
          }
        }
      }  // timers 데이터(배열) 조회
    }
    return cell
  }
}

extension TimerViewController: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound])
  }
}

extension TimerViewController {
  // 시스템 로컬 알림 예약(백그라운드/종료 상태에서도 울림)
  fileprivate func scheduleSystemAlarm(for item: TimerItem) {
    let seconds = max(1, Int(item.time))
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
    let content = UNMutableNotificationContent()
    content.title = "타이머"
    content.body = item.label
    content.sound = UNNotificationSound(named: UNNotificationSoundName("radial.caf"))
    let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
  }

  fileprivate func cancelSystemAlarm(forId id: UUID) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
  }
}
