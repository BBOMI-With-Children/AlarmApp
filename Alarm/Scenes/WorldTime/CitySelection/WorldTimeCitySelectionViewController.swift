//
//  WorldTimeCitySelectionViewController.swift
//  Alarm
//
//  Created by 서광용 on 8/10/25.
// DataSource로 구현. (데이터 변화도 검색말고 없고, 구현 위주라 기본 제공하는 메서드가 있는 전통 DataSource가 적합할거라 생각해서. ex: sectionForSectionIndexTitle)

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class WorldTimeCitySelectionViewController: UIViewController {
  // MARK: - Properties
  
  let didSelectCity = PublishRelay<CityRow>() // 방출 역할
  
  private let disposeBag = DisposeBag()
  
  private let backgroundColor = UIColor(named: "backgroundColor")
  private let mainColor = UIColor(named: "mainColor")
  
  private let viewModel = WorldTimeCitySelectionViewModel()
  
  private let titleLabel = UILabel().then {
    $0.text = "도시 선택"
    $0.textColor = .white
    $0.font = .systemFont(ofSize: 14, weight: .regular)
    $0.textAlignment = .center
  }
  
  private lazy var searchBar = UISearchBar().then {
    $0.searchBarStyle = .default
    $0.barTintColor = backgroundColor
    $0.searchTextField.backgroundColor = UIColor.darkGray
    $0.searchTextField.textColor = UIColor.white
    $0.searchTextField.tintColor = mainColor // 커서 색 변경
    $0.searchTextField.leftView?.tintColor = .lightGray // 돋보기 아이콘 색 변경
    $0.showsCancelButton = true // searchBar에 기본으로 있는 cancel 버튼 사용
    
    // placeholder 색 변경
    $0.searchTextField.attributedPlaceholder = NSAttributedString(
      string: "검색",
      attributes: [.foregroundColor: UIColor.lightGray]
    )
  }
  
  private lazy var tableView = UITableView().then {
    $0.backgroundColor = backgroundColor
    $0.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    $0.dataSource = self
    $0.delegate = self
    $0.separatorStyle = .singleLine
    $0.separatorColor = .systemGray4
    $0.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
  }
  
  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupLayout()
    bind()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    searchBar.text = nil
    searchBar.resignFirstResponder() // 키보드 닫기
    viewModel.filter("")
  }

  // MARK: - setupUI

  private func setupUI() {
    view.backgroundColor = backgroundColor
    [titleLabel, searchBar, tableView].forEach { view.addSubview($0) }
    
    // searchBar에 있는 기본 cancel 버튼을 KVC 방식으로 찾아와서 커스텀
    if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
      cancelButton.setTitle("취소", for: .normal)
      cancelButton.setTitleColor(mainColor, for: .normal)
    }
  }

  // MARK: - setupLayout

  private func setupLayout() {
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(4)
      $0.centerX.equalToSuperview()
    }
    
    searchBar.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(4)
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(8)
    }
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(searchBar.snp.bottom)
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(8)
      $0.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  private func bind() {
    searchBar.rx.cancelButtonClicked
      .subscribe(with: self) { vc, _ in
        vc.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
    
    // MARK: - 검색어를 viewModel의 filter에 전달

    searchBar.rx.text.orEmpty
      .debounce(.milliseconds(200), scheduler: MainScheduler.instance) // 0.2초동안 멈추면 실행
      .distinctUntilChanged() // 이전 값과 동일하면 무시
      .subscribe(with: self) { vc, text in
        vc.viewModel.filter(text)
      }
      .disposed(by: disposeBag)
    
    // MARK: - 데이터 변경 시 테이블 갱신

    viewModel.rows
      .asDriver(onErrorJustReturn: [])
      .drive(with: self) { vc, _ in
        vc.tableView.reloadData()
      }
      .disposed(by: disposeBag)
  }
}

extension WorldTimeCitySelectionViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let section = viewModel.sections.value[indexPath.section]
    let row = section.rows[indexPath.row]
    didSelectCity.accept(row)
    dismiss(animated: true)
  }
}

// MARK: DataSource

extension WorldTimeCitySelectionViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.sections.value[section].rows.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let section = viewModel.sections.value[indexPath.section]
    let row = section.rows[indexPath.row]
    cell.textLabel?.text = row.displayText
    cell.textLabel?.textColor = .white
    cell.backgroundColor = backgroundColor
    cell.preservesSuperviewLayoutMargins = false // 기본 마진 레이아웃 사용 x
    cell.layoutMargins = .zero
    
    // 셀 클릭 시 하이라이트 변경
    let cellTappedColor = UIView()
    cellTappedColor.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
    cell.selectedBackgroundView = cellTappedColor
    return cell
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.sections.value.count // 섹션 개수만큼
  }
  
  // titleForHeaderInSection: 섹션 헤더 제목
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return viewModel.sections.value[section].title
  }
  
  // sectionIndexTitles(for:): 오른쪽에 세로로 표시되는 인덱스 목록
  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    tableView.sectionIndexColor = mainColor
    return viewModel.sections.value.map { $0.title } // 제목만 반환
  }
  
  // willDisplayHeaderView: 헤더 뷰 표시 직전
  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    guard let header = view as? UITableViewHeaderFooterView else { return }
    header.contentView.backgroundColor = backgroundColor // 헤더뷰 색상 변경
  }
  
  // 오른쪽 세로 인덱스 목록 Tap 하면, 몇 번째 섹션으로 스크롤할지 결정해주는 고맙고 고마운 메서드
  // 동일하면 구현 안해도 된다지만, 일단 써봄
  func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
    // sections와 인덱스 타이틀 순서가 동일해서 index 그대로 반환
    return index
  }
}
