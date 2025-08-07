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
  
  private enum Section {
    case main
  }
  
  // MARK: - Properties
  private var isEditingMode = false
  private var items = ["서울", "도쿄", "런던"]
  private lazy var dataSource = makeDataSource()
  
  private let disposeBag = DisposeBag()
  
  private let collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: {
      var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
      config.headerMode = .none
      config.showsSeparators = false // 구분선 없음
      config.backgroundColor = UIColor(named: "backgroundColor")
      return UICollectionViewCompositionalLayout.list(using: config)
    }()
  )
  
  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureLayout()
    configureNavigationBar()
    applySnapshot()
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    collectionView.isEditing = editing // 콜렉션뷰 편집모드로 변경
  }

  // MARK: - Private Methods

  private func configureUI() {
    view.backgroundColor = UIColor(named: "backgroundColor")
    view.addSubview(collectionView)
  }
  
  private func configureLayout() {
    collectionView.snp.makeConstraints {
      $0.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  // 네비게이션 바
  private func configureNavigationBar() {
    title = "세계 시계"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "편집",
      style: .plain,
      target: self,
      action: #selector(didTapEditButton)
    )
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(didTapAddButton)
    )
  }
  
  // Diffable DataSource
  private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, String> {
    // 셀 등록
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, _, itemIdentifier in
      var configuration = cell.defaultContentConfiguration()
      configuration.text = itemIdentifier
      configuration.textProperties.font = .systemFont(ofSize: 16, weight: .regular)
      cell.contentConfiguration = configuration
      
      // 편집 모드일 때만 보이는 액세서리 (순서 변경, 삭제)
      cell.accessories = [
        .reorder(displayed: .whenEditing), // 셀 우측에 "드래그 핸들"을 띄워서 순서 변경 가능 (reorder가 드래그 핸들, 디스플레이에 편집 모드인 경우에만 띄움)
        .delete(displayed: .whenEditing) // 셀 촤측에 "삭제 버튼"을 띄워서 삭제 가능 (삭제버튼, 외 동일)
      ]
    }
    
    // 순서 변경 처리
    var reorderingHandlers = UICollectionViewDiffableDataSource<Section, String>.ReorderingHandlers() // ReorderingHandlers: canReorderItem,didReorder를 설정할 수 있는 구조체
    reorderingHandlers.canReorderItem = { _ in true } // 드래그 이동 가능하도록 허용. 무조건 true 반환
    reorderingHandlers.didReorder = { [weak self] transaction in // 셀의 순서를 변경할 때 호출되는 클로저. transaction에는 바뀐 순서 정보가 있음
      // transaction.difference는 사용자가 셀의 순서를 변경한 내용을 담고 있는 diff
      // items 배열에 이 difference를 적용(apply)해서, 새로운 순서가 반영된 배열(updatedItems)을 만들어냄
      guard let self, let updatedItems = items.applying(transaction.difference) else { return }
      items = updatedItems
      DispatchQueue.main.async {
        self.applySnapshot()
      }
    }
    
    // 데이터 소스? 생성. 셀 재사용 가능하도록
    let dataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
    }
    
    // 디퍼블 데이터소스에 셀 순서 변경 기능을 연결
    dataSource.reorderingHandlers = reorderingHandlers
    return dataSource
  }
  
  // Snapshot
  private func applySnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
    snapshot.appendSections([.main])
    snapshot.appendItems(items) // 더미 items 데이터
    dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  // MARK: - Actions
  
  @objc private func didTapEditButton() {
    isEditingMode.toggle()
    setEditing(isEditingMode, animated: true) // 오버라이드한 setEditing 메서드 호출
    navigationItem.leftBarButtonItem?.title = isEditingMode ? "완료" : "편집"
  }
  
  @objc private func didTapAddButton() {
    print("Modal 추가 예정 & Rx로")
  }
}
