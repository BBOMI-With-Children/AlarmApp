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

  private let viewModel = WorldTimeViewModel()
  private let tableView = UITableView()

  private let editButton = UIBarButtonItem(title: "편집", style: .plain, target: nil, action: nil)
  private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)

  private var isEditingMode = false
  private let itemsRelay = BehaviorRelay<[String]>(value: ["서울", "도쿄", "런던", "파리", "로마"])

  private let disposeBag = DisposeBag()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupLayout()
    setupNavigationBar()
    bind()
  }

  // MARK: - Private Methods

  private func setupUI() {
    title = "세계 시계"
    navigationController?.navigationBar.prefersLargeTitles = true // LargeTitles
    navigationController?.navigationBar.largeTitleTextAttributes = [
      .font: UIFont.systemFont(ofSize: 28, weight: .bold)
    ]

    view.backgroundColor = backgroundColor
    view.addSubview(tableView)
    tableView.backgroundColor = backgroundColor
    tableView.register(WorldTimeCell.self, forCellReuseIdentifier: WorldTimeCell.id)
  }

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
    // MARK: - 편집 모드

    editButton.rx.tap
      .withUnretained(self) // [weak self]처럼 약한 참조 + nil이면 자동으로 이벤트 무시
      .subscribe(onNext: { vc, _ in
        vc.isEditingMode.toggle()
        vc.tableView.setEditing(vc.isEditingMode, animated: true)
        vc.editButton.title = vc.isEditingMode ? "완료" : "편집"
      })
      .disposed(by: disposeBag)

    // MARK: - cell에 데이터 바인딩

    viewModel.timesRelay
      .bind(to: tableView.rx.items(cellIdentifier: WorldTimeCell.id, cellType: WorldTimeCell.self)) { _, model, cell in
        cell.configure(model)
      }
      .disposed(by: disposeBag)

    // MARK: - 스와이프 삭제

    tableView.rx.itemDeleted
      .withUnretained(self)
      .subscribe(onNext: { vc, indexPath in
        var newItems = vc.itemsRelay.value
        newItems.remove(at: indexPath.row)
        vc.itemsRelay.accept(newItems) // accept는 덮어쓰기 느낌 (교체)
      })
      .disposed(by: disposeBag)

    // MARK: - 셀 위치 변경

    tableView.rx.itemMoved
      .withUnretained(self)
      .subscribe(onNext: { vc, move in
        var newItems = vc.itemsRelay.value
        // sourceIndex: 드래그 시작한 셀의 위치, destinationIndex: 드롭 도착한 셀의 위치
        let moved = newItems.remove(at: move.sourceIndex.row) // 값을 꺼내면서 배열에서 삭제
        newItems.insert(moved, at: move.destinationIndex.row)
        vc.itemsRelay.accept(newItems)
      })
      .disposed(by: disposeBag)

    // MARK: - Modal 페이지로 이동

    addButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { _, _ in
        print("Tap")
        // TODO: Modal 페이지로 이동 구현
      })
      .disposed(by: disposeBag)
  }
}
