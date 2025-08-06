//
//  AddTimerViewController.swift
//  Alarm
//
//  Created by luca on 8/6/25.
//

import UIKit
import Then
import SnapKit

class AddTimerViewController: UIViewController {
  let timerPicker = TimerPickerView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    setupViews()
    setupNavigationBar()
    addTarget()
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

  private func setupNavigationBar() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "시작", style: .plain, target: self, action: #selector(addTimer)
    ).then {
      $0.tintColor = UIColor(named: "mainColor")
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
  
  private func addTarget() {
    addTimer()
  }
  
  @objc private func addTimer() {
    let selectedSeconds = timerPicker.selectedTimeInterval()
    print(selectedSeconds)
  }
  
  @objc private func handleTimeChanged(_ sender: UIDatePicker) {
    print(sender.date)
  }
}