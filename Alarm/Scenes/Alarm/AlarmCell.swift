//
//  AlarmCell.swift
//  Alarm
//
//  Created by 노가현 on 8/11/25.
//

import SnapKit
import Then
import UIKit

final class AlarmCell: UITableViewCell {
  static let id = "AlarmCell"

  // 토글 이벤트 전달
  var onToggle: ((Bool) -> Void)?

  // MARK: - UI

  private let cardView = UIView()
  private let titleStack = UIStackView()
  private let ampmLabel = UILabel()
  private let timeLabel = UILabel()
  private let subtitleLabel = UILabel()
  private let labelsVStack = UIStackView()
  private let toggleSwitch = UISwitch()

  // MARK: - Init

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
    setupLayout()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  // MARK: - Configure

  func configure(_ alarm: Alarm) {
    // "오전 6:00" 형식
    let parts = alarm.time.split(separator: " ")
    if parts.count >= 2 {
      ampmLabel.text = String(parts[0])
      timeLabel.text = parts.dropFirst().joined(separator: " ")
    } else {
      ampmLabel.text = ""
      timeLabel.text = alarm.time
    }

    subtitleLabel.text = alarm.subtitle
    toggleSwitch.isOn = alarm.isOn
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    onToggle = nil
  }

  // MARK: - Private

  private func setupUI() {
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    selectionStyle = .none

    cardView.do {
      $0.backgroundColor = UIColor(named: "sectionColor")
      $0.layer.cornerRadius = 18
      $0.layer.masksToBounds = true
    }

    titleStack.do {
      $0.axis = .horizontal
      $0.alignment = .firstBaseline
      $0.spacing = 8
    }

    labelsVStack.do {
      $0.axis = .vertical
      $0.alignment = .leading
      $0.spacing = 4
    }

    ampmLabel.do {
      $0.font = .systemFont(ofSize: 14, weight: .semibold)
      $0.textColor = .secondaryLabel
      $0.setContentHuggingPriority(.required, for: .horizontal)
      $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    timeLabel.do {
      $0.font = .systemFont(ofSize: 32, weight: .regular)
      $0.textColor = .label
      $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    subtitleLabel.do {
      $0.font = .systemFont(ofSize: 14, weight: .semibold)
      $0.textColor = UIColor(named: "mainColor") ?? .systemBlue
      $0.numberOfLines = 1
    }

    toggleSwitch.do {
      $0.onTintColor = UIColor(named: "mainColor") ?? .systemBlue
      $0.addTarget(self, action: #selector(onSwitchChanged), for: .valueChanged)
    }

    contentView.addSubview(cardView)
    [labelsVStack, toggleSwitch].forEach { cardView.addSubview($0) }

    [ampmLabel, timeLabel].forEach { titleStack.addArrangedSubview($0) }
    labelsVStack.addArrangedSubview(titleStack)
    labelsVStack.addArrangedSubview(subtitleLabel)
    labelsVStack.setCustomSpacing(6, after: titleStack)
  }

  private func setupLayout() {
    // 첫 번째 베이스라인 정렬
    ampmLabel.snp.makeConstraints { make in
      make.firstBaseline.equalTo(timeLabel.snp.firstBaseline)
    }

    // 카드 패딩
    cardView.snp.makeConstraints { make in
      make.top.equalTo(contentView.snp.top).offset(6)
      make.bottom.equalTo(contentView.snp.bottom).inset(6)
      make.leading.equalTo(contentView.snp.leading).offset(16)
      make.trailing.equalTo(contentView.snp.trailing).inset(16)
    }

    // 레이블 스택 패딩
    labelsVStack.snp.makeConstraints { make in
      make.top.equalTo(cardView.snp.top).offset(12)
      make.leading.equalTo(cardView.snp.leading).offset(20)
      make.bottom.equalTo(cardView.snp.bottom).inset(12)
      make.trailing.lessThanOrEqualTo(toggleSwitch.snp.leading).offset(-12)
    }

    // 스위치
    toggleSwitch.snp.makeConstraints { make in
      make.centerY.equalTo(cardView.snp.centerY)
      make.trailing.equalTo(cardView.snp.trailing).inset(20)
    }
  }

  @objc private func onSwitchChanged() {
    onToggle?(toggleSwitch.isOn)
  }
}
