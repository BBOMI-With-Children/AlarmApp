//
//  AlarmViewController.swift
//  Alarm
//
//  Created by 노가현 on 8/5/25.
//

import RxCocoa
import RxSwift
import UIKit

final class AlarmViewController: UIViewController {
  private let tableView = UITableView()
  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let bg = UIColor(named: "backgroundColor")
    let mainColor = UIColor(named: "mainColor")
    
    // MARK: - UI 설정
    
    view.backgroundColor = bg
    tableView.backgroundColor = bg
    tableView.frame = view.bounds
    tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    tableView.separatorStyle = .none
    tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    tableView.rowHeight = 112
    tableView.register(AlarmCell.self, forCellReuseIdentifier: AlarmCell.id)
    view.addSubview(tableView)

    // MARK: - 네비게이션 바 설정
    
    title = "알람"
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationBar.largeTitleTextAttributes = [
      .font: UIFont.systemFont(ofSize: 28, weight: .bold)
    ]
    
    // 편집 버튼
    let editButton = UIBarButtonItem(title: "편집", style: .plain, target: nil, action: nil)
    editButton.tintColor = mainColor
    navigationItem.leftBarButtonItem = editButton
    
    // 추가 버튼
    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    addButton.tintColor = mainColor
    navigationItem.rightBarButtonItem = addButton
    
    // MARK: - 데이터 로드
    
    _ = AlarmManager.shared // init 시 load(), 샘플 데이터 처리
    
    // MARK: - 테이블뷰 데이터 바인딩
    
    AlarmManager.shared.alarms
      .asDriver()
      .drive(tableView.rx.items(
        cellIdentifier: AlarmCell.id,
        cellType: AlarmCell.self
      )) { _, alarm, cell in
        cell.configure(alarm)
        cell.onToggle = { _ in
          AlarmManager.shared.toggle(id: alarm.id)
        }
      }
      .disposed(by: disposeBag)

    // MARK: - 편집 버튼 탭 시 편집 모드 토글
    
    editButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self else { return }
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        self.navigationItem.leftBarButtonItem?.title = self.tableView.isEditing ? "완료" : "편집"
      })
      .disposed(by: disposeBag)
    
    // MARK: - + 버튼 탭 시 알람 추가
    
    addButton.rx.tap
      .subscribe(onNext: {
        let new = Alarm(time: "오전 6:00", subtitle: "주중", isOn: true) // 더미
        AlarmManager.shared.add(new)
      })
      .disposed(by: disposeBag)
    
    // MARK: - 셀 삭제

    tableView.rx.itemDeleted
      .subscribe(onNext: { indexPath in
        AlarmManager.shared.remove(at: indexPath.row)
      })
      .disposed(by: disposeBag)
  }
}
