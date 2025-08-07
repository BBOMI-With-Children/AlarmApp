//
//  TimerViewController.swift
//  Alarm
//
//  Created by 노가현 on 8/5/25.
//

import SnapKit
import Then
import UIKit
import RxSwift

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
    TimerDataManager.shared.loadTimers() // 타이머 데이터 조회
    
    TimerDataManager.shared.timers // timers에 변동이 생기면
      .subscribe(onNext: { [weak self] items in
        self?.timerItems = items
        self?.timerTableView.reloadData() // 테이블뷰 새로고침
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

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "편집",
      primaryAction: nil,
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

  private func presentAddTimerViewController() {
    let addVC = AddTimerViewController()
    let nav = UINavigationController(rootViewController: addVC)
    nav.modalPresentationStyle = .formSheet
    present(nav, animated: true)
  }

}

// MARK: - UITableView

extension TimerViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // userDefault.count
    return timerItems.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard
      let cell = tableView.dequeueReusableCell(withIdentifier: TimerTableViewCell.reuseIdentifier, for: indexPath)
        as? TimerTableViewCell
    else {
      return UITableViewCell()
    }

    let item = timerItems[indexPath.row]
    cell.configureUI(with: item)

    return cell
  }
}
// MARK: Button Function
