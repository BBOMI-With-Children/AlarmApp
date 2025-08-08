//
//  StopwatchViewController.swift
//  Alarm
//
//  Created by 노가현 on 8/5/25.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class StopwatchViewController: UIViewController {
  // MARK: - Properties
  
  // 더미데이터
  private(set) var items = (1 ... 20).map { "랩 \($0)" }
  
  // 원형 뷰
  private let stopwatchCircleView = StopwatchCircleView()
  
  // 시간 레이블
  private let timeLabel = UILabel().then {
    $0.text = "00:00:00"
    $0.font = .systemFont(ofSize: 36, weight: .bold)
    $0.textColor = .white
    $0.textAlignment = .center
  }
  
  // 컬렉션 뷰
  private lazy var collectionView: UICollectionView = {
    // 리스트 레이아웃 구성
    var config = UICollectionLayoutListConfiguration(appearance: .plain)
    config.backgroundColor = .background
    // 구분선 inset 0 으로 해서 화면 가운데에 맞게 설정
    config.itemSeparatorHandler = { _, sectionSeparatorConfiguration in
      var s = sectionSeparatorConfiguration
      s.topSeparatorInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
      s.bottomSeparatorInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
      return s
    }

    let layout = UICollectionViewCompositionalLayout.list(using: config)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    return collectionView
  }()

  // 컬렉션 뷰 데이터 소스
  lazy var dataSource = makeDataSource(collectionView)
  
  // 랩,재설정 버튼
  private let lapResetButton = UIButton().then {
    let image = UIImage(systemName: "arrow.clockwise")
    $0.setImage(image, for: .normal)
    $0.tintColor = .white
    $0.backgroundColor = .modal
  }
  
  // 시작, 중단 버튼
  private let playPauseButton = UIButton().then {
    let image = UIImage(systemName: "play.fill")
    $0.setImage(image, for: .normal)
    $0.tintColor = .background
    $0.backgroundColor = .main
  }
  
  // 버튼 담는 horizontal 스택뷰
  private lazy var hStackView = UIStackView(arrangedSubviews: [lapResetButton, playPauseButton]).then {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.distribution = .equalSpacing
  }
  
  // 원형(시간), 컬렉션뷰, horizontal버튼스택뷰 담는 vertical 스택뷰
  private lazy var vStackView = UIStackView(arrangedSubviews: [stopwatchCircleView, hStackView, collectionView]).then {
    $0.axis = .vertical
    $0.alignment = .center
    $0.spacing = 16
    $0.distribution = .equalSpacing
  }
  
  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    collectionViewSetup()
  }
  
  // 버튼 cornerRadius 동적으로 관리
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    for item in [lapResetButton, playPauseButton] {
      item.layer.cornerRadius = item.bounds.width / 2
      item.clipsToBounds = true
    }
  }

  // MARK: - Configure UI

  private func configureUI() {
    view.backgroundColor = .background
    
    navigationController?.setNavigationBarHidden(true, animated: false)
    
    for item in [timeLabel, vStackView] {
      view.addSubview(item)
    }
    
    stopwatchCircleView.snp.makeConstraints {
      $0.size.equalTo(240)
    }
    
    timeLabel.snp.makeConstraints {
      $0.center.equalTo(stopwatchCircleView)
    }
    
    lapResetButton.snp.makeConstraints {
      $0.size.equalTo(74)
    }
    
    playPauseButton.snp.makeConstraints {
      $0.size.equalTo(74)
    }
    
    collectionView.snp.makeConstraints {
      $0.height.equalTo(240)
      $0.directionalHorizontalEdges.equalToSuperview()
    }
    
    hStackView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalTo(vStackView)
    }
    
    vStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(32)
      $0.directionalHorizontalEdges.equalToSuperview().inset(20)
      $0.bottom.equalTo(view.safeAreaLayoutGuide)
    }
    
    // 임시
    stopwatchCircleView.setProgress(0.7, animated: true)
    timeLabel.text = "00:12:34"
  }
  
  // MARK: - CollectionView Setup
  
  // 컬렉션뷰에 데이터를 적용하는 함수
  private func collectionViewSetup() {
    // 1. DiffableDataSource에서 사용할 스냅샷 생성
    //    제네릭: <SectionIdentifierType, ItemIdentifierType>
    //    여기서는 섹션을 Int로, 아이템을 String으로 식별
    var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
    // 2. 섹션 추가 (여기서는 단일 섹션 0번)
    snapshot.appendSections([0])
    // 3. 아이템을 섹션에 추가 (거꾸로 순서로 표시하기 위해 reversed() 사용)
    snapshot.appendItems(items.reversed(), toSection: 0)
    // 4. 스냅샷을 데이터소스에 적용 → 화면 갱신
    dataSource.apply(snapshot)
  }

  // DiffableDataSource를 생성하는 함수
  private func makeDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, String> {
    // 1. 셀 등록(CellRegistration)
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, _, text in
      // 셀의 기본 콘텐츠 구성 (텍스트, 이미지, 보조 텍스트 등)
      var configuration = cell.defaultContentConfiguration()
      configuration.text = text // 셀의 주 텍스트
      cell.contentConfiguration = configuration
          
      // 셀의 배경 구성
      var background = UIBackgroundConfiguration.listPlainCell()
      background.backgroundColor = .background
      cell.backgroundConfiguration = background
    }

    // 2. DiffableDataSource 생성
    //    제네릭: <SectionIdentifierType, ItemIdentifierType>
    //    셀을 어떻게 만들어서 반환할지 cellProvider 클로저로 정의
    let dataSource = UICollectionViewDiffableDataSource<Int, String>(
      collectionView: collectionView
    ) { collectionView, indexPath, text in
      // cellRegistration을 사용해 셀 dequeue + 구성
      collectionView.dequeueConfiguredReusableCell(
        using: cellRegistration,
        for: indexPath,
        item: text
      )
    }

    // 3. 완성된 데이터소스 반환
    return dataSource
  }
}
