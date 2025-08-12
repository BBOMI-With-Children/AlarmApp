//
//  AlarmEditViewController.swift
//  Alarm
//
//  Created by 노가현 on 8/12/25.
//

import UIKit

final class AlarmEditViewController: UIViewController {
  enum Mode { case create, edit(Alarm) }

  var onSave: ((Alarm) -> Void)?
  private let mode: Mode

  init(mode: Mode) {
    self.mode = mode
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor(named: "backgroundColor") ?? .systemBackground
    title = "알람 편집"

    // 좌/우 버튼을 configuration 기반으로 만들어서 10pt 아래로 내리기
    let left = UIButton(type: .system)
    var leftConfig = UIButton.Configuration.plain()
    leftConfig.title = "취소"
    leftConfig.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0) // ⬇️ 10
    left.configuration = leftConfig
    left.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

    let right = UIButton(type: .system)
    var rightConfig = UIButton.Configuration.plain()
    rightConfig.title = "저장"
    rightConfig.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0) // ⬇️ 10
    right.configuration = rightConfig
    right.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

    // 버튼 색상(틴트)
    if let main = UIColor(named: "mainColor") {
      left.tintColor = main
      right.tintColor = main
    }

    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: left)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: right)

    // placeholder
    let placeholder = UIView()
    placeholder.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(placeholder)
    NSLayoutConstraint.activate([
      placeholder.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      placeholder.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      placeholder.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      placeholder.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // 네비게이션 바 appearance
    let bg = UIColor(named: "backgroundColor") ?? .systemBackground
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = bg
    appearance.titleTextAttributes = [
      .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
      .foregroundColor: UIColor.white
    ]
    appearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 10)

    if let navBar = navigationController?.navigationBar {
      navBar.standardAppearance = appearance
      navBar.scrollEdgeAppearance = appearance
      navBar.compactAppearance = appearance
      navBar.tintColor = UIColor(named: "mainColor")
    }
  }

  // MARK: - Actions

  @objc private func cancelTapped() { dismiss(animated: true) }

  @objc private func saveTapped() {
    switch mode {
    case .create:
      let new = Alarm(time: "오전 7:00", subtitle: "주중", isOn: true)
      if new.time == "오전 7:00", new.subtitle == "주중", new.isOn == true {
        showNoChangesAlert()
        return
      }
      onSave?(new)

    case .edit(let old):
      var updated = old
      updated.time = "오전 7:00" // TODO: 실제 입력값으로 대체
      if updated == old {
        showNoChangesAlert()
        return
      }
      onSave?(updated)
    }
    dismiss(animated: true)
  }

  private func showNoChangesAlert() {
    let alert = UIAlertController(title: nil, message: "저장할 변경 사항이 없습니다.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    present(alert, animated: true)
  }
}
