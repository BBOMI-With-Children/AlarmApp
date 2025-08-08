//
//  TimerTableViewCell.swift
//  Alarm
//
//  Created by luca on 8/5/25.
//

import SnapKit
import Then
import UIKit

class TimerTableViewCell: UITableViewCell {
  static let reuseIdentifier = "TimerCell"

  var onToggleActive: (() -> Void)?

  private let timerLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = .systemFont(ofSize: 50, weight: .light)
  }

  private let userLabel = UILabel().then {
    $0.numberOfLines = 4
    $0.lineBreakMode = .byWordWrapping
    $0.font = .systemFont(ofSize: 14, weight: .light)
  }

  private let button = UIButton().then {
    $0.setTitle("", for: .normal)
    $0.setTitleColor(UIColor(named: "mainColor"), for: .normal)
    $0.tintColor = UIColor(named: "mainColor")
    $0.contentHorizontalAlignment = .center

    $0.layer.cornerRadius = 20
    $0.layer.borderWidth = 3
    $0.layer.borderColor = UIColor(named: "mainColor")?.cgColor
    $0.clipsToBounds = true
    // 􀊆 = Pause
  }

  private let labelStack = UIStackView().then {
    $0.alignment = .leading
    $0.axis = .vertical
    $0.spacing = 4
  }

  private let fullStack = UIStackView().then {
    $0.alignment = .fill
    $0.spacing = 20
    $0.axis = .horizontal
    $0.layer.cornerRadius = 8
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.backgroundColor = UIColor(named: "sectionColor")
    selectionStyle.self = .none
    backgroundColor = .clear
    contentView.layer.cornerRadius = 8
    setupViews()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupViews() {
    [timerLabel, userLabel, button].forEach {
      addSubview($0)
    }

    timerLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(10)
      $0.leading.equalToSuperview().inset(25)
    }

    button.snp.makeConstraints {
      $0.centerY.equalTo(timerLabel.snp.centerY)
      $0.trailing.equalToSuperview().inset(30)
      $0.height.width.equalTo(40)
    }

    userLabel.snp.makeConstraints {
      $0.top.equalTo(timerLabel.snp.bottom).offset(0)
      $0.leading.equalToSuperview().inset(25)
      $0.trailing.equalTo(button.snp.leading).offset(-10)
      $0.bottom.equalToSuperview().inset(20)
    }
  }

  func configureUI(with item: TimerItem) {
    timerLabel.text = formattedTime(item.time)
    userLabel.text = "\(item.label)"
    button // 활성 상태에 따른 아이콘 토글
      .setImage(item.isActive ? UIImage(systemName: "pause.fill") : UIImage(systemName: "play.fill"), for: .normal)
    button.removeTarget(nil, action: nil, for: .allEvents) // 재사용된 cell에서 중복 실행 방지를 위한 target remove
    button.addTarget(self, action: #selector(toggleActive), for: .touchUpInside) // 아이콘 토글
  }

  private func formattedTime(_ interval: TimeInterval) -> String {
    let timeInterval = Int(interval)
    let hours = timeInterval / 3600
    let minutes = (timeInterval % 3600) / 60
    let seconds = timeInterval % 60

    if hours == 0 {
      // 00:00
      return String(format: "%02d:%02d", minutes, seconds)
    } else if hours < 10 {
      // 0:00:00
      return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    } else {
      // 00:00:00
      return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
  }

  @objc private func toggleActive() {
    onToggleActive?() // onToggleActive 호출
  }
}
