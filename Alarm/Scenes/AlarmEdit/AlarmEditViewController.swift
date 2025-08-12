//
//  AlarmEditViewController.swift
//  Alarm
//
//  Created by 노가현 on 8/12/25.
//

import SnapKit
import Then
import UIKit
import UserNotifications

final class AlarmEditViewController: UIViewController {
  enum Mode { case create, edit(Alarm) }

  var onSave: ((Alarm) -> Void)?
  var onDelete: ((UUID) -> Void)?
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

  // MARK: - UI: 섹션

  private let sectionView = UIView()
  private let labelRow = UIView()
  private let soundRow = UIView()
  private let snoozeRow = UIView()

  private let labelTitle = UILabel()
  private let labelValue = UILabel()

  private let soundTitle = UILabel()
  private let soundValue = UILabel()

  private let snoozeTitle = UILabel()
  private let snoozeSwitch = UISwitch()

  private let deleteButton = UIButton(type: .system)

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

    view.backgroundColor = UIColor(named: "backgroundColor")
    title = "알람 편집"

    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)

    setupLayout()
    presetIfEditing()
    requestNotificationPermission() // 권한 요청 기능
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

    view.addSubview(sectionView)
    sectionView.do {
      $0.backgroundColor = UIColor(named: "sectionColor")
      $0.layer.cornerRadius = 18
      $0.layer.masksToBounds = true
    }
    sectionView.snp.makeConstraints {
      $0.top.equalTo(weekdayView.snp.bottom).offset(16)
      $0.leading.trailing.equalToSuperview().inset(16)
    }

    for row in [labelRow, soundRow, snoozeRow] {
      sectionView.addSubview(row)
      row.backgroundColor = UIColor(named: "modalColor")
      row.snp.makeConstraints { $0.height.equalTo(56) }
    }
    labelRow.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview() }
    soundRow.snp.makeConstraints {
      $0.top.equalTo(labelRow.snp.bottom)
      $0.leading.trailing.equalToSuperview()
    }
    snoozeRow.snp.makeConstraints {
      $0.top.equalTo(soundRow.snp.bottom)
      $0.leading.trailing.bottom.equalToSuperview()
    }

    func addDivider(below view: UIView) {
      let line = UIView()
      line.backgroundColor = UIColor.white.withAlphaComponent(0.1)
      sectionView.addSubview(line)
      line.snp.makeConstraints {
        $0.top.equalTo(view.snp.bottom)
        $0.leading.trailing.equalToSuperview().inset(16)
        $0.height.equalTo(0.5)
      }
    }
    addDivider(below: labelRow)
    addDivider(below: soundRow)

    // 레이블 Row
    labelTitle.do {
      $0.text = "레이블"
      $0.font = .systemFont(ofSize: 17)
      $0.textColor = .white
    }
    labelValue.do {
      $0.text = "Alarm"
      $0.font = .systemFont(ofSize: 17)
      $0.textColor = .white
      $0.textAlignment = .right
      $0.alpha = 1.0
    }

    [labelTitle, labelValue].forEach { labelRow.addSubview($0) }
    labelTitle.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(18)
      $0.centerY.equalToSuperview()
    }
    labelValue.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(18)
      $0.centerY.equalToSuperview()
      $0.leading.greaterThanOrEqualTo(labelTitle.snp.trailing).offset(12)
    }

    // 사운드 Row
    soundTitle.do {
      $0.text = "사운드"
      $0.font = .systemFont(ofSize: 17)
      $0.textColor = .white
    }
    soundValue.do {
      $0.text = "래디얼"
      $0.font = .systemFont(ofSize: 17)
      $0.textColor = .white
    }

    [soundTitle, soundValue].forEach { soundRow.addSubview($0) }
    soundTitle.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(18)
      $0.centerY.equalToSuperview()
    }

    soundValue.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().inset(18)
      $0.leading.greaterThanOrEqualTo(soundTitle.snp.trailing).offset(12)
    }

    // 다시 알림 Row
    snoozeTitle.do {
      $0.text = "다시 알림"
      $0.font = .systemFont(ofSize: 17)
      $0.textColor = .white
    }
    snoozeSwitch.onTintColor = UIColor(named: "mainColor") ?? .systemBlue
    [snoozeTitle, snoozeSwitch].forEach { snoozeRow.addSubview($0) }
    snoozeTitle.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(18)
      $0.centerY.equalToSuperview()
    }
    snoozeSwitch.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(16)
      $0.centerY.equalToSuperview()
    }

    // 삭제하기 버튼
    if case .edit = mode {
      view.addSubview(deleteButton)
      deleteButton.do {
        $0.setTitle("삭제하기", for: .normal)
        $0.setTitleColor(.systemRed, for: .normal)
        $0.backgroundColor = UIColor(named: "modalColor")
        $0.layer.cornerRadius = 14
        $0.layer.masksToBounds = true
        $0.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
      }

      deleteButton.snp.makeConstraints {
        $0.top.equalTo(sectionView.snp.bottom).offset(20)
        $0.leading.trailing.equalToSuperview().inset(16)
        $0.height.equalTo(46)
        $0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(12)
      }
    }
  }

  private func presetIfEditing() {
    guard case let .edit(alarm) = mode else { return }

    // 시간 프리셋
    if let d = parseDisplayTime(alarm.time) {
      datePicker.setDate(d, animated: false)
    }

    // 요일 프리셋
    weekdayView.selectedDays = preselectDays(from: alarm.subtitle)
  }

  // MARK: - Actions

  @objc private func cancelTapped() { dismiss(animated: true) }

  @objc private func saveTapped() {
    let display = outputFormatter.string(from: datePicker.date)
    let selectedDays = Set(weekdayView.selectedDays)

    switch mode {
    case .create:
      let subtitle = subtitleFromSelectedDays(selectedDays)
      let new = Alarm(time: display, subtitle: subtitle.isEmpty ? "주중" : subtitle, isOn: true)
      onSave?(new) // AlarmManager

    case let .edit(old):
      var updated = old
      updated.time = display
      let sub = subtitleFromSelectedDays(selectedDays)
      if !sub.isEmpty { updated.subtitle = sub }
      if updated == old {
        showNoChangesAlert(); return
      }
      onSave?(updated) // AlarmManager
    }
    dismiss(animated: true)
  }

  @objc private func deleteTapped() {
    guard case let .edit(alarm) = mode else { return }
    let alert = UIAlertController(title: "알람 삭제",
                                  message: "이 알람을 삭제할까요?",
                                  preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
      self?.onDelete?(alarm.id)
      self?.dismiss(animated: true)
    }))
    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
    present(alert, animated: true)
  }

  private func showNoChangesAlert() {
    let alert = UIAlertController(title: nil, message: "저장할 변경 사항이 없습니다.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    present(alert, animated: true)
  }

  // MARK: - Helpers

  // 권한 요청
  private func requestNotificationPermission() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      guard settings.authorizationStatus != .authorized else { return }
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, err in
        if let err = err { print("requestAuthorization error: \(err)") }
      }
    }
  }

  // 선택 요일을 문자열로
  private func subtitleFromSelectedDays(_ selected: Set<Weekday>) -> String {
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
    if count == 1, let one = selected.first {
      return "\(one.shortKo)요일마다"
    }

    // 여러 개 → 목, 금
    let ordered = Weekday.allCases.filter { selected.contains($0) }
    return ordered.map { $0.shortKo }.joined(separator: ", ")
  }

  // subtitle 문자열 → 선택 요일 집합
  private func preselectDays(from subtitle: String) -> Set<Weekday> {
    let s = subtitle.trimmingCharacters(in: .whitespacesAndNewlines)

    if s.contains("주중") { return [.mon, .tue, .wed, .thu, .fri] }
    if s.contains("주말") { return [.sat, .sun] }
    if s.contains("오늘") {
      let w = Calendar.current.component(.weekday, from: Date())
      switch w {
      case 1: return [.sun]
      case 2: return [.mon]
      case 3: return [.tue]
      case 4: return [.wed]
      case 5: return [.thu]
      case 6: return [.fri]
      default: return [.sat]
      }
    }

    // 요일 문자만 스캔
    let cleaned = s
      .replacingOccurrences(of: "요일", with: "")
      .replacingOccurrences(of: "마다", with: "")

    let map: [Character: Weekday] = [
      "월": .mon, "화": .tue, "수": .wed, "목": .thu, "금": .fri, "토": .sat, "일": .sun
    ]

    var set = Set<Weekday>()
    for ch in cleaned {
      if let day = map[ch] { set.insert(day) }
    }
    return set
  }

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
