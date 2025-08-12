//
//  AlarmEditViewController.swift
//  Alarm
//
//  Created by 노가현 on 8/12/25.
//

import SnapKit
import Then
import UIKit

final class AlarmEditViewController: UIViewController {
  enum Mode { case create, edit(Alarm) }

  var onSave: ((Alarm) -> Void)?
  private let mode: Mode

  // MARK: - UI

  private let datePicker = UIDatePicker().then {
    $0.datePickerMode = .time
    $0.preferredDatePickerStyle = .wheels
    $0.minuteInterval = 1
    $0.locale = Locale(identifier: "en_US_POSIX") // AM/PM
    $0.setValue(UIColor.white, forKey: "textColor")
  }

  // 요일 선택 뷰
  private let weekdayView = WeekdaySelectorView()

  private lazy var cancelButton = UIButton(type: .system).then {
    var cfg = UIButton.Configuration.plain()
    cfg.title = "취소"
    cfg.contentInsets = .init(top: 10, leading: 0, bottom: 0, trailing: 0)
    $0.configuration = cfg
    $0.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    $0.tintColor = UIColor(named: "mainColor")
  }

  private lazy var saveButton = UIButton(type: .system).then {
    var cfg = UIButton.Configuration.plain()
    cfg.title = "저장"
    cfg.contentInsets = .init(top: 10, leading: 0, bottom: 0, trailing: 0)
    $0.configuration = cfg
    $0.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    $0.tintColor = UIColor(named: "mainColor")
  } 

  // MARK: - Formatters

  private lazy var outputFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "ko_KR") // 오전/오후 h:mm
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

    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)

    setupLayout()
    presetIfEditing()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // 네비게이션 바 appearance
    let bg = UIColor(named: "backgroundColor") ?? .systemBackground
    let appearance = UINavigationBarAppearance().then {
      $0.configureWithOpaqueBackground()
      $0.backgroundColor = bg
      $0.titleTextAttributes = [
        .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
        .foregroundColor: UIColor.white
      ]
      $0.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 10)
    }

    navigationController?.navigationBar.do {
      $0.standardAppearance = appearance
      $0.scrollEdgeAppearance = appearance
      $0.compactAppearance = appearance
      $0.tintColor = UIColor(named: "mainColor")
    }
  }

  // MARK: - Layout

  private func setupLayout() {
    view.addSubview(datePicker)
    view.addSubview(weekdayView)

    datePicker.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(216) // iOS 기본 휠 높이로
    }

    weekdayView.snp.makeConstraints {
      $0.top.equalTo(datePicker.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview()
    }
  }

  private func presetIfEditing() {
    if case let .edit(alarm) = mode,
       let d = parseDisplayTime(alarm.time)
    {
      datePicker.setDate(d, animated: false)
    }
  }

  // MARK: - Actions

  @objc private func cancelTapped() { dismiss(animated: true) }

  @objc private func saveTapped() {
    let display = outputFormatter.string(from: datePicker.date)
    let subtitle = subtitleFromSelectedDays()

    switch mode {
    case .create:
      let subtitle = subtitleFromSelectedDays()
      let new = Alarm(time: display, subtitle: subtitle.isEmpty ? "주중" : subtitle, isOn: true)
      onSave?(new)

    case let .edit(old):
      var updated = old
      updated.time = display
      updated.subtitle = subtitle
      if updated == old {
        showNoChangesAlert()
        return
      }
      onSave?(updated)
    }
    dismiss(animated: true)
  }

  // 선택 요일을 문자열로
  private func subtitleFromSelectedDays() -> String {
    let selected: Set<Weekday> = Set(weekdayView.selectedDays)
    let count = selected.count

    let weekdays: Set<Weekday> = [.mon, .tue, .wed, .thu, .fri]
    let weekend: Set<Weekday> = [.sat, .sun]

    // 0개 → 오늘
    if count == 0 { return "오늘" }

    // 월~금만 선택 → 주중
    if selected == weekdays { return "주중" }

    // 토/일만 선택 → 주말
    if selected == weekend { return "주말" }

    // 1개 → <요일>마다
    if count == 1 {
      let one = selected.first!
      return "\(one.fullKo)마다"
    }

    // 여러 개 → 목, 금
    let ordered = Weekday.allCases.filter { selected.contains($0) }
    return ordered.map { $0.shortKo }.joined(separator: ", ")
  }

  private func showNoChangesAlert() {
    let alert = UIAlertController(title: nil, message: "저장할 변경 사항이 없습니다.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    present(alert, animated: true)
  }

  // MARK: - Helpers

  // 오전 7:00 / AM 7:00 문자열 → 오늘 날짜 시/분만 덮은 Date
  private func parseDisplayTime(_ s: String) -> Date? {
    if let d = parserKO.date(from: s) ?? parserEN.date(from: s) {
      let cal = Calendar.current
      let comps = cal.dateComponents([.hour, .minute], from: d)
      return cal.date(bySettingHour: comps.hour ?? 0,
                      minute: comps.minute ?? 0,
                      second: 0,
                      of: Date())
    }
    return nil
  }
}
