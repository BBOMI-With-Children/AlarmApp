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

  override func viewDidLoad() {
    super.viewDidLoad()

    requestNotificationPermission()  // 알림 권한 요청
    UNUserNotificationCenter.current().delegate = self
    TimerDataManager.shared.loadTimers()  // 타이머 데이터 조회

    TimerDataManager.shared.timers  // timers 구독
      .subscribe(onNext: { [weak self] items in  // timers에 새로운 데이터가 들어오면 호출
        self?.timerItems = items  // 최신 데이터를 VC 상태에 반영
        self?.timerTableView.reloadData()  // 테이블뷰 새로고침
      })
      .disposed(by: disposeBag)

    // 타이머(1초마다 이벤트 발생)
    Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
      .subscribe(onNext: { _ in
        // 현재 저장된 데이터 조회
        guard var items = try? TimerDataManager.shared.timers.value() else { return }
        var changed = false  // 값 변화 추적
        var finished: [TimerItem] = []  // 0이 된 타이머들

        for i in items.indices {  // 데이터 중
          if items[i].isActive, items[i].time > 0 {  // 타이머 진행 중 + 시간이 0보다 크면
            items[i].time -= 1  // 시간 1 감소
            changed = true  // 값 변화 확인

            if items[i].time == 0 {
              finished.append(items[i])
            }
          }
        }

        finished.forEach {
          self.notifyTimerFinished($0)
        }

        if !finished.isEmpty {
          let finishiedIds = Set(finished.map { $0.id })
          items.removeAll { finishiedIds.contains($0.id) }
          changed = true
        }

        if changed {  // 변화 감지
          TimerDataManager.shared.timers.onNext(items)  // 변경된 데이터 전달. 다른 구독자에게 갱신 요청
          TimerDataManager.shared.saveTimers()  // userDefault 저장
        }
      }).disposed(by: disposeBag)

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

  // 내비게이션바 버튼
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

    // navigationItem.leftBarButtonItem = UIBarButtonItem(
    //   title: "편집",
    //   primaryAction: nil,
    //   menu: nil
    // ).then {
    //   $0.tintColor = UIColor(named: "mainColor")
    // }

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
        print("\(err)")
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
    content.sound = .defaultRingtone

    let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: nil)
    UNUserNotificationCenter.current().add(request) { err in
      if let err = err {
        print("\(err)")
      }
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
      guard var items = try? TimerDataManager.shared.timers.value() else { return }  // timers 데이터(배열) 조회
      if let idx = items.firstIndex(where: { $0.id == item.id }) {  // 현재 cell item과 동일한 타이머 인덱스 조회
        items[idx].isActive.toggle()  // 활성화 토글

        if items[idx].isActive == false {  // 타이머 셀이 일시정지될 때
          items.sort(by: timerCellSort)  // 짧은 시간 순 정렬
        }

        TimerDataManager.shared.timers.onNext(items)  // 변경된 데이터 전달. 다른 구독자에게 갱신 요청
        TimerDataManager.shared.saveTimers()  // userDefault 저장
      }
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
