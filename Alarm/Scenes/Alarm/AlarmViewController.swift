//
//  AlarmViewController.swift
//  Alarm
//
//  Created by 노가현 on 8/5/25.
//

import UIKit

final class AlarmViewController: UIViewController {
  private let tableView = UITableView()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    AlarmManager.shared.loadSampleData()

    tableView.frame = view.bounds
    tableView.dataSource = self
    view.addSubview(tableView)
  }
}

// MARK: - UITableViewDataSource

extension AlarmViewController: UITableViewDataSource {
  // 섹션별 행의 개수
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    AlarmManager.shared.alarms.count // 저장된 알람 개수
  }

  // 행에 표시할 셀
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell() // 셀 생성
    let alarm = AlarmManager.shared.alarms[indexPath.row] // 해당 위치의 알람 데이터
    cell.textLabel?.text = "\(alarm.time) - \(alarm.subtitle)" // 셀에 알람 시간, 부제목 표시
    return cell
  }
}
