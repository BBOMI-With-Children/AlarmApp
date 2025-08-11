//
//  AlarmCell.swift
//  Alarm
//
//  Created by 노가현 on 8/11/25.
//

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

    cardView.backgroundColor = UIColor(named: "sectionColor")
    cardView.layer.cornerRadius = 18
    cardView.layer.masksToBounds = true

    titleStack.axis = .horizontal
    titleStack.alignment = .firstBaseline
    titleStack.spacing = 8

    labelsVStack.axis = .vertical
    labelsVStack.alignment = .leading
    labelsVStack.spacing = 4

    ampmLabel.font = .systemFont(ofSize: 14, weight: .semibold)
    ampmLabel.textColor = .secondaryLabel
    ampmLabel.setContentHuggingPriority(.required, for: .horizontal)
    ampmLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

    timeLabel.font = .systemFont(ofSize: 32, weight: .regular)
    timeLabel.textColor = .label
    timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

    subtitleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
    subtitleLabel.textColor = UIColor(named: "mainColor") ?? .systemBlue
    subtitleLabel.numberOfLines = 1

    toggleSwitch.onTintColor = UIColor(named: "mainColor") ?? .systemBlue
    toggleSwitch.addTarget(self, action: #selector(onSwitchChanged), for: .valueChanged)

    contentView.addSubview(cardView)
    [labelsVStack, toggleSwitch].forEach { cardView.addSubview($0) }

    [ampmLabel, timeLabel].forEach { titleStack.addArrangedSubview($0) }
    labelsVStack.addArrangedSubview(titleStack)
    labelsVStack.addArrangedSubview(subtitleLabel)
    labelsVStack.setCustomSpacing(6, after: titleStack)
  }

  private func setupLayout() {
    [cardView, labelsVStack, toggleSwitch].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

    let baselineConstraint = ampmLabel.firstBaselineAnchor.constraint(equalTo: timeLabel.firstBaselineAnchor)
    baselineConstraint.priority = .required
    baselineConstraint.isActive = true

    NSLayoutConstraint.activate([
      // 카드 패딩
      cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
      cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
      cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

      // 레이블 스택 패딩
      labelsVStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
      labelsVStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
      labelsVStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
      labelsVStack.trailingAnchor.constraint(lessThanOrEqualTo: toggleSwitch.leadingAnchor, constant: -12),

      // 스위치
      toggleSwitch.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
      toggleSwitch.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
    ])
  }

  @objc private func onSwitchChanged() {
    onToggle?(toggleSwitch.isOn)
  }
}
