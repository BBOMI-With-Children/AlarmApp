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
    // view.backgroundColor = UIColor(named: "backgroundColor")

    tableView.backgroundColor = UIColor(named: "backgroundColor")

    title = "알람"
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationBar.largeTitleTextAttributes = [
      .font: UIFont.systemFont(ofSize: 28, weight: .bold)
    ]

    let mainColor = UIColor(named: "mainColor")

    // 편집 버튼
    let editButton = UIBarButtonItem(
      title: "편집",
      style: .plain,
      target: self,
      action: #selector(toggleEditing) // 토글
    )
    editButton.tintColor = mainColor
    navigationItem.leftBarButtonItem = editButton

    // 추가 버튼
    let addButton = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(tapAdd) // 알람 추가 메서드 호출
    )
    addButton.tintColor = mainColor
    navigationItem.rightBarButtonItem = addButton

    // 샘플 데이터 불러오기
    AlarmManager.shared.loadSampleData()

    tableView.frame = view.bounds
    tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // 화면 크기에 맞게 자동 조정
    tableView.dataSource = self
    view.addSubview(tableView)
  }

  // MARK: - Actions

  // 편집 버튼을 눌렀을 때 호출, 테이블뷰 편집 모드 토글
  @objc private func toggleEditing() {
    tableView.setEditing(!tableView.isEditing, animated: true)
    navigationItem.leftBarButtonItem?.title = tableView.isEditing ? "완료" : "편집"
  }

  // + 버튼을 눌렀을 때 호출, 임시 알람 추가
  @objc private func tapAdd() {
    let new = Alarm(time: "오전 6:00", subtitle: "주중", isOn: true) // 임시 알람 생성
    AlarmManager.shared.add(new) // AlarmManager에 추가
    let newIndex = IndexPath(row: AlarmManager.shared.alarms.count - 1, section: 0)
    tableView.insertRows(at: [newIndex], with: .automatic) // 테이블뷰에 행 추가
  }
}

// MARK: - UITableViewDataSource

extension AlarmViewController: UITableViewDataSource {
  // 섹션별 행 개수 반환
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    AlarmManager.shared.alarms.count
  }

  // 행에 표시할 셀 반환
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    cell.backgroundColor = UIColor(named: "backgroundColor")
    let alarm = AlarmManager.shared.alarms[indexPath.row]
    cell.textLabel?.text = "\(alarm.time) - \(alarm.subtitle)" // 알람 시간, 부제목 표시
    return cell
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    true // 행 편집 가능
  }

  // 삭제 버튼
  func tableView(_ tableView: UITableView,
                 commit editingStyle: UITableViewCell.EditingStyle,
                 forRowAt indexPath: IndexPath)
  {
    // 삭제 동작일 때
    guard editingStyle == .delete else { return }
    // 삭제할 알람 id 가져오기
    let id = AlarmManager.shared.alarms[indexPath.row].id
    // 데이터에서 알람 삭제
    AlarmManager.shared.remove(id: id)
    // 테이블 뷰에서 셀 삭제
    tableView.deleteRows(at: [indexPath], with: .automatic)
  }
}
