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
    $0.setTitleColor(.systemOrange, for: .normal)
    // $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
    $0.tintColor = .systemOrange
    $0.contentHorizontalAlignment = .center
    
    // $0.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    $0.layer.cornerRadius = 20
    $0.layer.borderWidth = 3
    $0.layer.borderColor = UIColor.systemOrange.cgColor
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
    $0.backgroundColor = .blue
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.backgroundColor = .blue
    contentView.layer.cornerRadius = 8
    setupViews()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupViews() {
    // contentView.addSubview(fullStack)
    // [timerLabel, userLabel].forEach {
    //   labelStack.addArrangedSubview($0)
    // }
    // [labelStack, button].forEach {
    //   fullStack.addArrangedSubview($0)
    // }
    // 
    // fullStack.snp.makeConstraints {
    //   $0.top.equalToSuperview().inset(20)
    //   $0.bottom.equalToSuperview().inset(10)
    //   $0.leading.equalToSuperview().inset(20)
    //   $0.trailing.equalToSuperview().offset(-40)
    // }
    [timerLabel, userLabel, button].forEach {
      addSubview($0)
    }

    timerLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(20)
      $0.leading.equalToSuperview().inset(10)
    }
    
    button.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().inset(20)
      $0.height.width.equalTo(40)
    }
    
    userLabel.snp.makeConstraints {
      $0.top.equalTo(timerLabel.snp.bottom).offset(10)
      $0.leading.equalToSuperview().inset(10)
      $0.trailing.equalTo(button.snp.leading).offset(-10)
      $0.bottom.equalToSuperview().inset(10)
    }
    
    // timerLabel.snp.makeConstraints {
    //   $0.top.equalToSuperview()
    //   $0.leading.equalToSuperview()
    // }
    // 
    // userLabel.snp.makeConstraints {
    //   $0.bottom.equalToSuperview()
    //   $0.leading.equalToSuperview()
    // }
   
    // button.snp.makeConstraints {
    //   $0.top.equalToSuperview()
    //   $0.trailing.equalToSuperview()
    // }
  }

  func configureUI(with item: TimerItem) {
    timerLabel.text = "\(Int(item.time)) 초"
    userLabel.text = "\(item.label)"
    button
      .setImage(item.isActive ? UIImage(systemName: "pause.fill") : UIImage(systemName: "play.fill"), for: .normal)
  }
}
