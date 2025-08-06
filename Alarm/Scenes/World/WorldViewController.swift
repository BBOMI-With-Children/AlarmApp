//
//  WorldViewController.swift
//  Alarm
//
//  Created by 노가현 on 8/5/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class WorldViewController: UIViewController {
  
  private var isEditingMode = false
  
  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureNavigationBar()
  }

  // MARK: - Private Methods

  private func configureUI() {
    view.backgroundColor = .systemBackground
    title = "세계 시계"
  }
  
  private func configureNavigationBar() {
    title = "세계 시계"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "편집",
      style: .plain,
      target: self,
      action: #selector(didTapEditButton)
    )
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(didTapAddButton)
      )
  }
  
  // MARK: - Actions
  
  @objc private func didTapEditButton() {
    isEditingMode.toggle()
    
    navigationItem.leftBarButtonItem?.title = isEditingMode ? "완료" : "편집"
  }
  
  @objc private func didTapAddButton() {
    print("Tap")
  }
}
