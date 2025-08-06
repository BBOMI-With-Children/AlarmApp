//
//  TimerViewController.swift
//  Alarm
//
//  Created by 노가현 on 8/5/25.
//

import SnapKit
import UIKit
import Then

final class TimerViewController: UIViewController {
  // MARK: - Lifecycle

  private lazy var timerTableView = UITableView(frame: .zero, style: .plain).then {
    $0.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    $0.showsVerticalScrollIndicator = true
    $0.backgroundColor = .clear
  }

  let testTimerData: [TimerItem] = [
    TimerItem(
      time: 180,
      label: "4ㅕㄹㅋ햐캏캫ㅋㅎ탸아랴패ㅞㅓㅣ처근런하ㅓ니ㅓ널컬냫ㄴㅎㅛ려려녀쟈래ㅔ헤ㅗㅔㅗㅔㅠㅐㅓㅔㅠㅔㅠㅔ해겯ㄷㅅㄴㅅ아히허여너하파파챠오너아하뎌대하랴야래랴럏ㅇㅅ묘라하러파ㅠㅓ포초포ㅗ퍼포툐용",
      alarmName: "래디얼",
      isActive: true
    ),
    TimerItem(time: 300, label: "5분", alarmName: "래디얼", isActive: false),
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }

  // MARK: - Private Methods

  private func configureUI() {
    view.backgroundColor = .systemBackground
    title = "타이머"

    view.addSubview(timerTableView)
    timerTableView.dataSource = self
    timerTableView.register(TimerTableViewCell.self, forCellReuseIdentifier: "TimerCell")

    timerTableView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}

struct TimerItem {
  let time: TimeInterval
  let label: String
  let alarmName: String
  let isActive: Bool
}

extension TimerViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // userDefault.count
    return testTimerData.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimerCell", for: indexPath) as? TimerTableViewCell
    else {
      return UITableViewCell()
    }

    let item = testTimerData[indexPath.row]
    cell.configureUI(with: item)

    return cell
  }
}
