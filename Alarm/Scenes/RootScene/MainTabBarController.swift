//
//  ViewController.swift
//  Alarm
//
//  Created by 노가현 on 8/5/25.
//

import UIKit

final class MainTabBarController: UITabBarController {
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // 다크 모드
        overrideUserInterfaceStyle = .dark

        configureTabBar()
    }

    // MARK: - Private Methods

    private func configureTabBar() {
        // 뷰 컨트롤러, 탭 아이템
        let worldVC = WorldViewController()
        worldVC.tabBarItem = UITabBarItem(title: "세계 시계", image: UIImage(systemName: "globe"), tag: 0)

        let alarmVC = AlarmViewController()
        alarmVC.tabBarItem = UITabBarItem(title: "알람", image: UIImage(systemName: "alarm.fill"), tag: 1)

        let stopwatchVC = StopwatchViewController()
        stopwatchVC.tabBarItem = UITabBarItem(title: "스톱워치", image: UIImage(systemName: "stopwatch.fill"), tag: 2)

        let timerVC = TimerViewController()
        timerVC.tabBarItem = UITabBarItem(title: "타이머", image: UIImage(systemName: "timer"), tag: 3)

        // 네비게이션 컨트롤러
        viewControllers = [
            UINavigationController(rootViewController: worldVC),
            UINavigationController(rootViewController: alarmVC),
            UINavigationController(rootViewController: stopwatchVC),
            UINavigationController(rootViewController: timerVC)
        ]

        // 투명도 없음
        tabBar.isTranslucent = false

        // 탭바 외관
        let appearance = UITabBarAppearance()
        // 배경 색 다크
        appearance.backgroundColor = .black

        // 선택된 아이콘 색
        let selected = appearance.stackedLayoutAppearance.selected
        selected.iconColor = .systemOrange
        selected.titleTextAttributes = [.foregroundColor: UIColor.systemOrange]

        // 비선택 아이템 색
        let normal = appearance.stackedLayoutAppearance.normal
        normal.iconColor = .lightGray
        normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]

        // 외관 적용
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .systemOrange
        tabBar.unselectedItemTintColor = .lightGray
    }
}
