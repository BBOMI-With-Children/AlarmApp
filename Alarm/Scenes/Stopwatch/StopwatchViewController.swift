//
//  StopwatchViewController.swift
//  Alarm
//
//  Created by 노가현 on 8/5/25.
//

import UIKit

final class StopwatchViewController: UIViewController {
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    // MARK: - Private Methods

    private func configureUI() {
        view.backgroundColor = .systemBackground
        title = "스톱워치"
    }
}
