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

  // MARK: - UI

  private let datePicker: UIDatePicker = {
    let p = UIDatePicker()
    p.datePickerMode = .time
    p.preferredDatePickerStyle = .wheels // 휠
    p.minuteInterval = 1
    p.locale = Locale(identifier: "en_US_POSIX") // AM/PM 휠 보이도록 고정
    p.translatesAutoresizingMaskIntoConstraints = false

    p.setValue(UIColor.white, forKey: "textColor")
    return p
  }()

  // MARK: - Formatters

  private lazy var outputFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "ko_KR") // 저장은 "오전/오후 h:mm"
    f.dateFormat = "a h:mm"
    return f
  }()

  private lazy var parserKO: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "ko_KR")
    f.dateFormat = "a h:mm"
    return f
  }()

  private lazy var parserEN: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "a h:mm"
    return f
  }()

  // MARK: - Init

  init(mode: Mode) {
    self.mode = mode
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor(named: "backgroundColor") ?? .systemBackground
    title = "알람 편집"

    // 좌/우 버튼
    let left = UIButton(type: .system)
    var leftConfig = UIButton.Configuration.plain()
    leftConfig.title = "취소"
    leftConfig.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
    left.configuration = leftConfig
    left.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

    let right = UIButton(type: .system)
    var rightConfig = UIButton.Configuration.plain()
    rightConfig.title = "저장"
    rightConfig.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
    right.configuration = rightConfig
    right.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

    if let main = UIColor(named: "mainColor") {
      left.tintColor = main
      right.tintColor = main
    }
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: left)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: right)

    // 시간 휠 배치 (상단바 바로 아래)
    view.addSubview(datePicker)
    NSLayoutConstraint.activate([
      datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
      datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      datePicker.heightAnchor.constraint(equalToConstant: 216) // iOS 기본 휠 높이로
    ])

    // 편집 모드면 기존 값으로 프리셋
    if case let .edit(alarm) = mode {
      if let d = parseDisplayTime(alarm.time) {
        // 날짜의 시/분만 맞추고, 날짜는 오늘로 (날짜 Todo)
        datePicker.setDate(d, animated: false)
      }
    }
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
    // 휠에서 고른 시간을 오전/오후 h:mm으로 변환
    let display = outputFormatter.string(from: datePicker.date)

    switch mode {
    case .create:
      let new = Alarm(time: display, subtitle: "주중", isOn: true)
      onSave?(new)

    case let .edit(old):
      var updated = old
      updated.time = display
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

  // MARK: - Helpers

  // 오전 7:00, AM 7:00 문자열을 Date로 파싱
  private func parseDisplayTime(_ s: String) -> Date? {
    if let d = parserKO.date(from: s) ?? parserEN.date(from: s) {
      // 오늘 날짜에 시/분만 덮어쓰기
      let cal = Calendar.current
      let comps = cal.dateComponents([.hour, .minute], from: d)
      return cal.date(bySettingHour: comps.hour ?? 0, minute: comps.minute ?? 0, second: 0, of: Date())
    }
    return nil
  }
}
