//
//  StopwatchViewController.swift
//  Alarm
//
//  Created by 노가현 on 8/5/25.
//

import UIKit
import SnapKit
import Then

final class StopwatchViewController: UIViewController {
  // MARK: - Properties
  
  private let stopwatchCircleView = StopwatchCircleView()
  
  let timeLabel = UILabel().then {
    $0.text = "00:00:00"
    $0.font = .systemFont(ofSize: 36, weight: .bold)
    $0.textColor = .white
    $0.textAlignment = .center
  }
  
  // 랩 타임 기록 구현 필요 (CollectionView list?)
  
  private let lapResetButton = UIButton().then {
      let image = UIImage(systemName: "arrow.clockwise")
      $0.setImage(image, for: .normal)
      $0.tintColor = .white
      $0.backgroundColor = .modal
  }
  
  private let playPauseButton = UIButton().then {
    let image = UIImage(systemName: "play.fill")
    $0.setImage(image, for: .normal)
    $0.tintColor = .background
    $0.backgroundColor = .main
  }
  
  private lazy var hStackView = UIStackView(arrangedSubviews: [lapResetButton, playPauseButton]).then {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.distribution = .equalSpacing
  }
  
  private lazy var vStackView = UIStackView(arrangedSubviews: [stopwatchCircleView, hStackView]).then {
    $0.axis = .vertical
    $0.alignment = .center
    $0.spacing = 16
    $0.distribution = .equalSpacing
  }
  
  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
    
      [lapResetButton, playPauseButton].forEach {
          $0.layer.cornerRadius = $0.bounds.width / 2
          $0.clipsToBounds = true
      }
  }

  // MARK: - Private Methods

  private func configureUI() {
    view.backgroundColor = .background
    
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    
    [timeLabel, vStackView].forEach {
      view.addSubview($0)
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
    
    hStackView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalTo(vStackView)
    }
    
    vStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(32)
      $0.directionalHorizontalEdges.equalToSuperview().inset(20)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
    }
    
    // 임시
    stopwatchCircleView.setProgress(0.7, animated: true)
    stopwatchCircleView.lineCap = .round
    timeLabel.text = "00:12:34"
  }
  
}
