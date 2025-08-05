//
//  ViewController.swift
//  Alarm
//
//  Created by 노가현 on 8/5/25.
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let worldNav = UINavigationController(rootViewController: WorldViewController())
        worldNav.tabBarItem = UITabBarItem(title: "세계 시계", image: UIImage(systemName: "globe"), tag: 0)

        let alarmNav = UINavigationController(rootViewController: AlarmViewController())
        alarmNav.tabBarItem = UITabBarItem(title: "알람", image: UIImage(systemName: "alarm.fill"), tag: 1)

        let stopwatchNav = UINavigationController(rootViewController: StopwatchViewController())
        stopwatchNav.tabBarItem = UITabBarItem(title: "스톱워치", image: UIImage(systemName: "stopwatch.fill"), tag: 2)

        let timerNav = UINavigationController(rootViewController: TimerViewController())
        timerNav.tabBarItem = UITabBarItem(title: "타이머", image: UIImage(systemName: "timer"), tag: 3)

        viewControllers = [worldNav, alarmNav, stopwatchNav, timerNav]
    }
}
