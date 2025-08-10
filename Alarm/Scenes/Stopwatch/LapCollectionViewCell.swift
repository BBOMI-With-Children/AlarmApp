//
//  LapCollectionViewCell.swift
//  Alarm
//
//  Created by 김이든 on 8/11/25.
//

import UIKit

final class LapCollectionViewCell: UICollectionViewCell {
  static let reuseIdentifier = "LapCollectionViewCell"

  private let lapNumberLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 16, weight: .medium)
    $0.textColor = .white
  }

  private let lapTimeLabel = UILabel().then {
    $0.font = .monospacedDigitSystemFont(ofSize: 16, weight: .regular)
    $0.textColor = .white
    $0.textAlignment = .right
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    [lapNumberLabel, lapTimeLabel].forEach {
      contentView.addSubview($0)
    }

    lapNumberLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(16)
      $0.centerY.equalToSuperview()
    }

    lapTimeLabel.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(16)
      $0.centerY.equalToSuperview()
    }
  }

  func configure(lapNumber: Int, lapTime: String) {
    lapNumberLabel.text = "랩 \(lapNumber)"
    lapTimeLabel.text = lapTime
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    lapNumberLabel.text = nil
    lapTimeLabel.text = nil
  }
}
