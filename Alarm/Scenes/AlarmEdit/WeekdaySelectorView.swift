//
//  WeekdaySelectorView.swift
//  Alarm
//
//  Created by 노가현 on 8/12/25.
//

import SnapKit
import Then
import UIKit

enum Weekday: Int, CaseIterable {
  case mon = 0, tue, wed, thu, fri, sat, sun
  var shortKo: String {
    switch self {
    case .mon: return "월"; case .tue: return "화"; case .wed: return "수"
    case .thu: return "목"; case .fri: return "금"; case .sat: return "토"; case .sun: return "일"
    }
  }

  var fullKo: String {
    switch self {
    case .mon: return "월요일"; case .tue: return "화요일"; case .wed: return "수요일"
    case .thu: return "목요일"; case .fri: return "금요일"; case .sat: return "토요일"; case .sun: return "일요일"
    }
  }
}

final class WeekdaySelectorView: UIView {
  // 외부 API
  var selectedDays: Set<Weekday> = [] { didSet { updateAll() } }
  var onChange: ((Set<Weekday>) -> Void)?

  // 색상
  private let mainColor = UIColor(named: "mainColor") ?? .systemBlue
  private let modalColor = UIColor(named: "modalColor") ?? .tertiarySystemFill
  private let sectionColor = UIColor(named: "SectionColor") ?? .label

  // 레이아웃 파라미터
  private let horizontalInset: CGFloat = 12
  private let preferredSize: CGFloat = 44
  private let minSize: CGFloat = 38
  private let minSpacing: CGFloat = 8
  private let maxSpacing: CGFloat = 16

  private let hStack = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .fill
    $0.distribution = .equalSpacing
    $0.spacing = 12
  }

  private var buttons: [UIButton] = []
  private var sizeConstraints: [Constraint] = [] // width/height 묶어서 관리

  override var intrinsicContentSize: CGSize {
    CGSize(width: UIView.noIntrinsicMetric, height: 56)
  }

  // MARK: Init

  override init(frame: CGRect) {
    super.init(frame: frame); setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder); setup()
  }

  // MARK: Setup

  private func setup() {
    addSubview(hStack)
    hStack.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset))
    }

    for day in Weekday.allCases {
      let button = UIButton(type: .system).then {
        $0.setTitle(day.shortKo, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        $0.tag = day.rawValue
        $0.layer.cornerRadius = preferredSize / 2
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 2
        $0.addTarget(self, action: #selector(toggleDay(_:)), for: .touchUpInside)
      }
      hStack.addArrangedSubview(button)

      // width/height 제약 저장해두고 나중에 업데이트
      button.snp.makeConstraints { make in
        sizeConstraints.append(make.width.equalTo(preferredSize).constraint)
        make.height.equalTo(preferredSize)
      }

      buttons.append(button)
    }
    updateAll()
  }

  // 가로 폭이 바뀔 때마다 버튼 크기/간격 재계산
  override func layoutSubviews() {
    super.layoutSubviews()
    relayoutForWidth(bounds.width)
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    relayoutForWidth(bounds.width)
  }

  private func relayoutForWidth(_ fullWidth: CGFloat) {
    let available = max(0, fullWidth - horizontalInset*2)
    let count = CGFloat(buttons.count) // 7

    // 1) 버튼 44 고정으로 간격 계산
    var buttonSize = preferredSize
    var spacing = floor((available - count*buttonSize) / (count - 1))

    if spacing < minSpacing {
      // 2) 간격 하한 유지하면서 버튼 크기를 줄여서 맞추기
      spacing = minSpacing
      buttonSize = floor((available - (count - 1)*spacing) / count)
      buttonSize = max(minSize, min(preferredSize, buttonSize))
    } else if spacing > maxSpacing {
      // 3) 너무 넓으면 상한까지만
      spacing = maxSpacing
    }

    // 반올림 오차로 마지막이 밀리지 않게 stack 간격만 적용
    hStack.spacing = spacing

    // 버튼 크기/코너 반경 업데이트
    for (i, c) in sizeConstraints.enumerated() {
      c.update(offset: buttonSize)
      buttons[i].layer.cornerRadius = buttonSize / 2
    }
    layoutIfNeeded()
  }

  // MARK: Actions

  @objc private func toggleDay(_ sender: UIButton) {
    guard let day = Weekday(rawValue: sender.tag) else { return }
    if selectedDays.contains(day) { selectedDays.remove(day) } else { selectedDays.insert(day) }
    update(button: sender, selected: selectedDays.contains(day))
    onChange?(selectedDays)
  }

  // MARK: Update

  private func updateAll() {
    for (i, b) in buttons.enumerated() {
      let day = Weekday(rawValue: i)!
      update(button: b, selected: selectedDays.contains(day))
    }
  }

  private func update(button: UIButton, selected: Bool) {
    if selected {
      button.backgroundColor = mainColor
      button.layer.borderColor = mainColor.cgColor
      button.setTitleColor(sectionColor, for: .normal)
      button.tintColor = sectionColor
      button.accessibilityTraits.insert(.selected)
    } else {
      button.backgroundColor = modalColor
      button.layer.borderColor = modalColor.cgColor
      button.setTitleColor(.white, for: .normal)
      button.tintColor = .white
      button.accessibilityTraits.remove(.selected)
    }
  }
}
