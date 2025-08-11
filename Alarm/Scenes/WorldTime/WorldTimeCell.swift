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
    $0.font = .systemFont(ofSize: 24, weight: .medium)
    $0.numberOfLines = 1
    $0.textColor = .label
  }

  private let timeDifferenceLabel = UILabel().then { // 오늘, +0시간(GMT)
    $0.font = .systemFont(ofSize: 14, weight: .regular)
  }

  private let meridiemLabel = UILabel().then { // 오전/오후
    $0.font = .systemFont(ofSize: 20, weight: .light)
    $0.textColor = .label
  }

  private let timeLabel = UILabel().then { // 시간
    $0.font = .systemFont(ofSize: 40, weight: .light)
    $0.textColor = .label
  }
  
  private let leftStackView = UIStackView().then { // cityLabel + timeDifferenceLabel
    $0.axis = .vertical
    $0.alignment = .leading
    $0.distribution = .fillProportionally
    $0.spacing = 2
  }

  private let contentStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
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
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    meridiemLabel.isHidden = editing
    timeLabel.isHidden = editing
    backgroundColor = UIColor(named: "backgroundColor")
  }
  
  // MARK: - setupUI
  
  private func setupUI() {
    contentView.backgroundColor = UIColor(named: "backgroundColor")
    selectionStyle = .none // 셀 누름 방지
    timeDifferenceLabel.textColor = UIColor(named: "mainColor")
    
    contentView.addSubview(containerView)
    [contentStackView, meridiemLabel].forEach { containerView.addSubview($0) }
    [leftStackView, timeLabel].forEach { contentStackView.addArrangedSubview($0) }
    [cityLabel, timeDifferenceLabel].forEach { leftStackView.addArrangedSubview($0) }
  }
  
  // MARK: - setupLayout

  private func setupLayout() {
    containerView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(4)
      $0.leading.trailing.equalToSuperview().inset(12)
    }
    
    contentStackView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    meridiemLabel.snp.makeConstraints {
      $0.trailing.equalTo(timeLabel.snp.leading).offset(-4)
      $0.lastBaseline.equalTo(timeLabel.snp.lastBaseline)
    }
    
    timeLabel.snp.makeConstraints {
      $0.trailing.equalToSuperview()
      $0.centerY.equalToSuperview()
    }
  }
  
  // MARK: - Configure

  func configure(_ data: testDataModel) {
    cityLabel.text = data.city
    timeDifferenceLabel.text = data.subInfo
    meridiemLabel.text = data.meridiem
    timeLabel.text = data.time
  }
}
