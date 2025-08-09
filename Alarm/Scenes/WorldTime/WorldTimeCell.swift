//
//  WorldTimeCell.swift
//  Alarm
//
//  Created by 서광용 on 8/7/25.
//

import SnapKit
import Then
import UIKit

final class WorldTimeCell: UITableViewCell {
  // MARK: - Properties
  
  static let id = "WorldTimeCell"
  
  private let containerView = UIView().then {
    $0.layer.cornerRadius = 16
    $0.layer.masksToBounds = true
    $0.backgroundColor = .section
  }

  /*
   ┌────────────────────────────────────┐
   |  [도시명]                            |
   | -----------------------------------|
   |  [GMT/날짜정보] |  [오전/오후] | [시간]  |
   └────────────────────────────────────┘
   */
  private let cityLabel = UILabel().then { // 도시명
    $0.font = .systemFont(ofSize: 20, weight: .semibold)
    $0.numberOfLines = 1
    $0.textColor = .label
  }

  private let timeDifferenceLabel = UILabel().then { // 오늘, +0시간(GMT)
    $0.font = .systemFont(ofSize: 13, weight: .regular)
  }

  private let meridiemLabel = UILabel().then { // 오전/오후
    $0.font = .systemFont(ofSize: 16, weight: .regular)
    $0.textColor = .label
    $0.setContentHuggingPriority(.required, for: .horizontal) // GMT가 늘어나거나 줄어들거나
  }

  private let timeLabel = UILabel().then { // 시간
    $0.font = .systemFont(ofSize: 25, weight: .bold)
    $0.textColor = .label
    $0.setContentHuggingPriority(.required, for: .horizontal)
  }
  
  private let leftStackView = UIStackView().then { // cityLabel + timeDifferenceLabel
    $0.axis = .vertical
    $0.alignment = .leading
    $0.distribution = .fillEqually
    $0.spacing = 4
  }

  private let rightStackView = UIStackView().then { // meridiemLabel + timeLabel
    $0.axis = .horizontal
    $0.alignment = .center
    $0.distribution = .fill
    $0.spacing = 2
  }

  private let contentStackView = UIStackView().then { // leftStackView + rightStackView
    $0.axis = .horizontal
  }
  
  // MARK: - Lifecycle
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
    setupLayout()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private Methods
  
  private func setupUI() {
    selectionStyle = .none // 셀 누름 방지
    timeDifferenceLabel.textColor = UIColor(named: "mainColor")
    
    contentView.addSubview(containerView)
    containerView.addSubview(contentStackView)
    [leftStackView, rightStackView].forEach { contentStackView.addArrangedSubview($0) }
    [cityLabel, timeDifferenceLabel].forEach { leftStackView.addArrangedSubview($0) }
    [meridiemLabel, timeLabel].forEach { rightStackView.addArrangedSubview($0) }
  }
  
  private func setupLayout() {
    containerView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(12)
    }
    
    contentStackView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configure(_ data: testDataModel) {
    cityLabel.text = data.city
    timeDifferenceLabel.text = data.subInfo
    meridiemLabel.text = data.meridiem
    timeLabel.text = data.time
  }
}
