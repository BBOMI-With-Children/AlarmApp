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
  private let timerLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = .systemFont(ofSize: 50, weight: .light)
  }
  
  private let userLabel = UILabel().then {
    $0.numberOfLines = 4
    $0.lineBreakMode = .byWordWrapping
    $0.font = .systemFont(ofSize: 16, weight: .light)
  }
  
  private let button = UIButton().then {
    $0.setTitle("", for: .normal)
    $0.setTitleColor(.systemOrange, for: .normal)
    // $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
    $0.tintColor = .systemOrange
    $0.contentHorizontalAlignment = .center
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
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupViews()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupViews() {
    contentView.addSubview(fullStack)
    [timerLabel, userLabel].forEach {
      labelStack.addArrangedSubview($0)
    }
    [labelStack, button].forEach {
      fullStack.addArrangedSubview($0)
    }
    
    fullStack.snp.makeConstraints {
      $0.top.equalToSuperview().inset(20)
      $0.bottom.equalToSuperview().inset(10)
      $0.leading.equalToSuperview().inset(20)
      $0.trailing.equalToSuperview().offset(-40)
    }
    
    timerLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalToSuperview()
    }
    
    userLabel.snp.makeConstraints {
      $0.bottom.equalToSuperview()
      $0.leading.equalToSuperview()
    }

    button.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.trailing.equalToSuperview()
    }
  }

  func configureUI(with item: TimerItem) {
    timerLabel.text = "\(Int(item.time)) 초"
    userLabel.text = "\(item.label)"
    button
      .setImage(item.isActive ? UIImage(systemName: "pause.fill") : UIImage(systemName: "play.fill"), for: .normal)
  }
}
