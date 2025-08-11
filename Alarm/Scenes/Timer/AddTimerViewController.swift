//
//  AddTimerViewController.swift
//  Alarm
//
//  Created by luca on 8/6/25.
//

import SnapKit
import Then
import UIKit

class AddTimerViewController: UIViewController {
  let timerPicker = TimerPickerView()

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    setupViews()
    setupNavigationBar()
    timerPicker.onTimeChanged = { [weak self] _ in
      self?.toggleStartButtonState()
    }
    toggleStartButtonState()
  }

  private func configureUI() {
    view.backgroundColor = UIColor(named: "backgroundColor")
    title = "타이머"
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.largeTitleDisplayMode = .always
  }

  private func setupViews() {
    view.addSubview(timerPicker)
    timerPicker.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.horizontalEdges.equalToSuperview()
      $0.centerX.equalToSuperview()
    }
  }

  private func toggleStartButtonState() {
    let enabled = timerPicker.selectedTimeInterval() > 0
    navigationItem.rightBarButtonItem?.isEnabled = enabled
  }

  // 내비게이션 버튼
  private func setupNavigationBar() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "시작",
      style: .plain,
      target: self,
      action: #selector(addTimer)
    ).then {
      $0.tintColor = UIColor(named: "mainColor")
      $0.isEnabled = false
    }

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "취소",
      primaryAction: UIAction { [weak self] _ in
        self?.dismiss(animated: true)
      },
      menu: nil
    ).then {
      $0.tintColor = UIColor(named: "mainColor")
    }
  }

  // MARK: Button function

  @objc private func addTimer() {  // 타이머 추가(userDefault에 저장) 액션
    guard timerPicker.selectedTimeInterval() > 0 else { return }
    let selectedSeconds = timerPicker.selectedTimeInterval()
    let time = timerPicker.selectedTimeComponents()
    var userLabelText = timerPicker.userLabelText()
    if userLabelText.isEmpty {
      if time.hour != 0 {
        userLabelText += "\(time.hour)시간"
      }
      if time.minute != 0 {
        userLabelText += " \(time.minute)분"
      }
      if time.second != 0 {
        userLabelText += " \(time.second)초"
      }
    }

    let newItem = TimerItem(
      id: UUID(),
      time: selectedSeconds,
      label: userLabelText,
      isActive: true
    )

    // userDefault에 저장
    TimerDataManager.shared.mutate { items in
      items.append(newItem)
    }
    dismiss(animated: true)
  }
}
