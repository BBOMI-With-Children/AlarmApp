//
//  WorldTimeViewController.swift
//  Alarm
//
//  Created by 노가현 on 8/5/25.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class WorldTimeViewController: UIViewController {
  // MARK: - Properties

  private let backgroundColor = UIColor(named: "backgroundColor")
  private let mainColor = UIColor(named: "mainColor")

  private let citySelectionVC = WorldTimeCitySelectionViewController()
  private let viewModel = WorldTimeViewModel()

  private lazy var tableView = UITableView().then {
    $0.separatorStyle = .none
    $0.register(WorldTimeCell.self, forCellReuseIdentifier: WorldTimeCell.id)
    $0.backgroundColor = backgroundColor
  }

  private let editButton = UIBarButtonItem(title: "편집", style: .plain, target: nil, action: nil)
  private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)

  private var isEditingMode = false

  private let disposeBag = DisposeBag()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupLayout()
    setupNavigationBar()
    bind()
    viewModel.loadTimeZonesFromDefaults()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.updateWorldTimes()
    viewModel.startMinuteUpdates()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.stopMinuteUpdates() // 중복 실행이나 백그라운드에서 되지 않도록 해제시킴
  }

  // MARK: - setupUI

  private func setupUI() {
    title = "세계 시계"
    navigationController?.navigationBar.prefersLargeTitles = true // LargeTitles
    navigationController?.navigationBar.largeTitleTextAttributes = [
      .font: UIFont.systemFont(ofSize: 28, weight: .bold)
    ]

    view.backgroundColor = backgroundColor
    view.addSubview(tableView)
  }

  // MARK: - setupLayout

  private func setupLayout() {
    tableView.snp.makeConstraints {
      $0.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }

  // MARK: - 네비게이션 바 추가

  private func setupNavigationBar() {
    navigationItem.leftBarButtonItem = editButton
    navigationItem.rightBarButtonItem = addButton
    editButton.tintColor = mainColor
    addButton.tintColor = mainColor
  }

  private func bind() {
    tableView.rx.setDelegate(self).disposed(by: disposeBag) // delegate

    // MARK: - 편집 모드

    editButton.rx.tap
      .subscribe(with: self) { vc, _ in
        vc.isEditingMode.toggle()
        vc.tableView.setEditing(vc.isEditingMode, animated: true)
        vc.editButton.title = vc.isEditingMode ? "완료" : "편집"
      }
      .disposed(by: disposeBag)

    // MARK: - cell에 데이터 바인딩

    viewModel.timesRelay
      .bind(to: tableView.rx.items(cellIdentifier: WorldTimeCell.id, cellType: WorldTimeCell.self)) { _, model, cell in
        cell.configure(model)
      }
      .disposed(by: disposeBag)

    // MARK: - 스와이프 삭제

    tableView.rx.itemDeleted
      .subscribe(with: self) { vc, indexPath in
        vc.viewModel.deleteCity(indexPath.row)
      }
      .disposed(by: disposeBag)

    // MARK: - 셀 위치 변경

    tableView.rx.itemMoved
      .subscribe(with: self) { vc, move in
        // sourceIndex: 드래그 시작한 셀의 위치, destinationIndex: 드롭 도착한 셀의 위치
        vc.viewModel.moveCity(fromIndex: move.sourceIndex.row, toIndex: move.destinationIndex.row)
      }
      .disposed(by: disposeBag)

    // MARK: - Modal 페이지로 이동

    addButton.rx.tap
      .subscribe(with: self) { vc, _ in
        vc.citySelectionVC.modalPresentationStyle = .automatic
        vc.present(vc.citySelectionVC, animated: true)
      }
      .disposed(by: disposeBag)

    // MARK: - Modal에서 누른 데이터 받기

    citySelectionVC.didSelectCity
      .subscribe(with: self) { vc, row in
        vc.viewModel.addCity(row)
      }
      .disposed(by: disposeBag)
  }
}

extension WorldTimeViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    "삭제"
  }
}
