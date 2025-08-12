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

  private let disposeBag = DisposeBag()
  private let viewModel = StopwatchViewModel()

  // 원형 뷰
  private let stopwatchCircleView = StopwatchCircleView()

  // 이미지 프로퍼티
  private let stopwatchImage = UIImage(systemName: "stopwatch.fill")
  private let trashImage = UIImage(systemName: "trash.fill")
  private let playImage = UIImage(systemName: "play.fill")
  private let pauseImage = UIImage(systemName: "pause.fill")

  // 시간 레이블
  private let timeLabel = UILabel().then {
    $0.text = "00:00:00"
    $0.font = .monospacedDigitSystemFont(ofSize: 36, weight: .medium)
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
    collectionView.register(LapCollectionViewCell.self, forCellWithReuseIdentifier: LapCollectionViewCell.reuseIdentifier)
    return collectionView
  }()

  // 컬렉션 뷰 데이터 소스
  private var dataSource: UICollectionViewDiffableDataSource<Int, StopWatchModel.Lap>!

  // 랩,재설정 버튼
  private let lapResetButton = UIButton().then {
    let image = UIImage(systemName: "stopwatch.fill")
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
    configureDataSource()
    bindViewModel()
  }

  // 버튼 cornerRadius 동적으로 관리
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    [lapResetButton, playPauseButton].forEach {
      $0.layer.cornerRadius = $0.bounds.width / 2
      $0.clipsToBounds = true
    }
  }

  // MARK: - Configure UI

  private func configureUI() {
    view.backgroundColor = .background

    navigationController?.setNavigationBarHidden(true, animated: false)

    [timeLabel, vStackView].forEach {
      view.addSubview($0)
    }

    stopwatchCircleView.snp.makeConstraints {
      $0.size.equalTo(300)
    }

    timeLabel.snp.makeConstraints {
      $0.centerY.equalTo(stopwatchCircleView)
      $0.horizontalEdges.equalTo(stopwatchCircleView).inset(20)
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
  }
}

// MARK: - CollectionView Setup

extension StopwatchViewController {
  // 컬렉션뷰에 데이터를 적용하는 함수
  private func applySnapshot(_ laps: [StopWatchModel.Lap]) {
    // 1. DiffableDataSource에서 사용할 스냅샷 생성
    //    제네릭: <SectionIdentifierType, ItemIdentifierType>
    //    여기서는 섹션을 Int로, 아이템을 LapTime으로 식별
    var snapshot = NSDiffableDataSourceSnapshot<Int, StopWatchModel.Lap>()
    // 2. 섹션 추가 (여기서는 단일 섹션 0번)
    snapshot.appendSections([0])
    // 3. 아이템을 섹션에 추가
    snapshot.appendItems(laps, toSection: 0)
    // 4. 스냅샷을 데이터소스에 적용 → 화면 갱신
    dataSource.apply(snapshot, animatingDifferences: true)
  }

  // DiffableDataSource를 생성하는 함수
  private func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Int, StopWatchModel.Lap>(collectionView: collectionView) { [weak self] collectionView, indexPath, lap in
      guard let self = self,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LapCollectionViewCell.reuseIdentifier, for: indexPath) as? LapCollectionViewCell
      else {
        return UICollectionViewCell()
      }
      cell.configure(lapNumber: lap.number, lapTime: self.viewModel.formatTime(lap.time))
      return cell
    }
  }
}

// MARK: - Rx Bind

extension StopwatchViewController {
  private func bindViewModel() {
    // 버튼 탭 → 토글 실행
    playPauseButton.rx.tap
      .bind { [weak self] in
        self?.viewModel.togglePlayPause()
      }
      .disposed(by: disposeBag)

    // isRunning → 버튼 이미지 변경
    viewModel.isRunning
      .map { [weak self] isRunning in
        isRunning ? self?.pauseImage : self?.playImage
      }
      .bind(to: playPauseButton.rx.image())
      .disposed(by: disposeBag)

    // isRunning → 재설정 버튼 이미지 변경
    viewModel.isRunning
      .map { [weak self] isRunning in
        isRunning ? self?.stopwatchImage : self?.trashImage
      }
      .bind(to: lapResetButton.rx.image())
      .disposed(by: disposeBag)

    // timePassed → 밀리세컨드 포맷으로 변환 후 표시
    viewModel.timePassed
      .map { [weak self] time in
        self?.viewModel.formatTime(time) ?? "00:00:00"
      }
      .bind(to: timeLabel.rx.text)
      .disposed(by: disposeBag)

    // 랩,재설정 버튼 활성화/비활성화
    viewModel.timePassed
      .map { $0 > 0 } // Double → Bool 변환
      .bind(to: lapResetButton.rx.isEnabled) // 버튼 활성/비활성 바인딩
      .disposed(by: disposeBag)

    // 랩타임 기록 및 재설정
    lapResetButton.rx.tap
      .withLatestFrom(viewModel.isRunning) // 버튼 탭 시 현재 상태 가져오기
      .bind { [weak self] isRunning in
        if isRunning {
          // 실행 중 → 랩타임 기록
          self?.viewModel.recordLap()
        } else {
          // 정지 상태 → 시간 리셋
          self?.viewModel.resetTimer()
        }
      }
      .disposed(by: disposeBag)

    // CollectionView 갱신
    viewModel.laps
      .observe(on: MainScheduler.instance)
      .bind { [weak self] laps in
        self?.applySnapshot(laps)
      }
      .disposed(by: disposeBag)

    // 원형 UI Progress
    viewModel.timePassed
      .map { [weak self] time in
        self?.viewModel.circleProgress(time) ?? 0
      }
      .bind(to: stopwatchCircleView.rx.progress)
      .disposed(by: disposeBag)
  }
}
