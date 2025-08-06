//
//  TimerPickerView.swift
//  Alarm
//
//  Created by luca on 8/6/25.
//

import SnapKit
import Then
import UIKit

final class TimerPickerView: UIView {
  private let timerPicker = UIPickerView()
  private let hours = Array(0...23)
  private let minutes = Array(0...59)
  private let seconds = Array(0...59)

  private let hourLabel = UILabel().then {
    $0.text = "시간"
  }
  private let minuteLabel = UILabel().then {
    $0.text = "분"
  }
  private let secondLabel = UILabel().then {
    $0.text = "초"
  }

  private let userLabel = UILabel().then {
    $0.text = "레이블"
    $0.setContentHuggingPriority(.required, for: .horizontal)
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  private let userTextField = UITextField().then {
    $0.placeholder = "타이머"
    $0.clearButtonMode = .whileEditing
    $0.textColor = .gray
    $0.returnKeyType = .done
    $0.textAlignment = .right
    $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
  }

  private let userStack = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 8
  }
  //
  // private let alarmLabel = UILabel().then {
  //   $0.text = "알람"
  // }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupPicker()
    setupLabels()
    userTextField.delegate = self
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupPicker() {
    addSubview(timerPicker)
    timerPicker.delegate = self
    timerPicker.dataSource = self
    timerPicker.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(50)
    }
  }

  private func setupLabels() {
    [hourLabel, minuteLabel, secondLabel, userStack].forEach {
      addSubview($0)
    }

    [userLabel, userTextField].forEach {
      userStack.addArrangedSubview($0)
    }

    // hourLabel.snp.makeConstraints {
    //   $0.centerY.equalTo(timerPicker)
    //   // $0.leading.equalTo(timerPicker).offset(10)
    // }

    // minuteLabel.snp.makeConstraints {
    //   $0.centerY.equalTo(timerPicker)
    //   // $0.leading.equalTo(timerPicker).offset(10)
    // }

    // secondLabel.snp.makeConstraints {
    //   $0.centerY.equalTo(timerPicker)
    //   // $0.trailing.equalTo(timerPicker).inset(10)
    // }
    //
    // timerPicker.snp.makeConstraints {
    //   $0.leading.equalToSuperview().offset(50)
    //   $0.trailing.equalToSuperview().offset(-50)
    // }

    userStack.snp.makeConstraints {
      $0.top.equalTo(timerPicker.snp.bottom)
      $0.horizontalEdges.equalToSuperview().inset(30)
    }
  }

  private var pickerComponentWidth: CGFloat {
    UIScreen.main.bounds.width / 3
  }

  var selectedHour: Int {
    timerPicker.selectedRow(inComponent: 0)
  }

  var selectedMinute: Int {
    timerPicker.selectedRow(inComponent: 1)
  }

  var selectedSecond: Int {
    timerPicker.selectedRow(inComponent: 2)
  }

  func selectedTimeInterval() -> TimeInterval {
    TimeInterval(selectedHour * 3600 + selectedMinute * 60 + selectedSecond)
  }
}

extension TimerPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 3
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch component {
    case 0: return hours.count
    case 1: return minutes.count
    case 2: return seconds.count
    default: return 0
    }
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    switch component {
    case 0: return "\(hours[row])"
    case 2: return "\(minutes[row])"
    case 1: return "\(seconds[row])"
    default: return nil
    }
  }

  func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
    return pickerView.frame.width / 3
  }
}

extension TimerPickerView: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    userTextField.resignFirstResponder()
    return true
  }
}