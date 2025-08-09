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
  }
  /*
   ┌────────────────────────────────────┐
   |  [도시명]                            |
   | -----------------------------------|
   |  [GMT/날짜정보] |  [오전/오후] | [시간]  |
   └────────────────────────────────────┘
   */
  private let cityLabel = UILabel().then {               // 도시명
    $0.font = .systemFont(ofSize: 20, weight: .semibold)
    $0.numberOfLines = 1
    $0.textColor = .label
  }
  private let timeDifferenceLabel = UILabel().then {     // 오늘, +0시간(GMT)
    $0.font = .systemFont(ofSize: 13, weight: .regular)
  }
  private let meridiemLabel = UILabel().then {           // 오전/오후
    $0.font = .systemFont(ofSize: 16, weight: .regular)
    $0.textColor = .label
    $0.setContentHuggingPriority(.required, for: .horizontal) // GMT가 늘어나거나 줄어들거나
  }
  private let timeLabel = UILabel().then {               // 시간
    $0.font = .systemFont(ofSize: 25, weight: .bold)
    $0.textColor = .label
    $0.setContentHuggingPriority(.required, for: .horizontal)
  }
  
  private let leftStackView = UIStackView().then {       // cityLabel + timeDifferenceLabel
    $0.axis = .vertical
    $0.spacing = 8
  }
  private let rightStackView = UIStackView().then {      // meridiemLabel + timeLabel
    $0.axis = .horizontal
    $0.spacing = 8
  }
  private let contentStackView = UIStackView().then {    // leftStackView + rightStackView
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
    timeDifferenceLabel.tintColor = UIColor(named: "mainColor")
    
    contentView.addSubview(containerView)
    containerView.addSubview(contentStackView)
    [leftStackView, rightStackView].forEach { contentStackView.addArrangedSubview($0) }
    [cityLabel, timeDifferenceLabel].forEach { leftStackView.addArrangedSubview($0) }
    [meridiemLabel, timeLabel].forEach { rightStackView.addArrangedSubview($0) }
    
  }
  
  private func setupLayout() {

  }
}
