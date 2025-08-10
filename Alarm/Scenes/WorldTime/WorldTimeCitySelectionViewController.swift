//
//  WorldTimeCitySelectionViewController.swift
//  Alarm
//
//  Created by 서광용 on 8/10/25.
// DataSource로 구현.  (데이터 변화도 검색말고 없고, 구현 위주라 전통 DataSource가 적합할거라 생각)

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class WorldTimeCitySelectionViewController: UIViewController {
  // MARK: - Properties
  
  private let disposeBag = DisposeBag()
  
  private let backgroundColor = UIColor(named: "backgroundColor")
  private let mainColor = UIColor(named: "mainColor")
  
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
  }
  
  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupLayout()
    bind()
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
  }
}
