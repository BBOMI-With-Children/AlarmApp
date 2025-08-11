//
//  StopwatchCircleView.swift
//  Alarm
//
//  Created by 김이든 on 8/7/25.
//

import RxCocoa
import RxSwift
import UIKit

class StopwatchCircleView: UIView {
  // MARK: - Properties

  // 진행 경로의 전체 배경 원
  private let trackLayer = CAShapeLayer().then {
    $0.fillColor = UIColor.clear.cgColor
    $0.strokeColor = UIColor.modal.cgColor
    $0.strokeStart = 0
    $0.strokeEnd = 1
  }

  // 진행상황 그려지는 레이어
  private let progressLayer = CAShapeLayer().then {
    $0.fillColor = UIColor.clear.cgColor
    $0.strokeColor = UIColor.main.cgColor
    $0.lineCap = .round
    $0.strokeStart = 0
    $0.strokeEnd = 0
  }

  // 내부적으로 현재 진행값을 보관하는 프로퍼티
  private var _progress: CGFloat = 0
  // 공통으로 사용하는 선 두께
  private var lineWidth: CGFloat = 10

  // 외부에서 사용하는 progress
  var progress: CGFloat {
    get { return _progress }
    set { setProgress(newValue) }
  }

  // MARK: - Init

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  // MARK: - Layout

  // 레이아웃이 갱신될 때마다 자동으로 호출되는 메서드
  override func layoutSubviews() {
    super.layoutSubviews()
    let path = arcPath(in: bounds).cgPath
    trackLayer.path = path
    progressLayer.path = path
  }

  // MARK: - Progress Setter

  // 진행상황 설정
  func setProgress(_ progress: CGFloat) {
    guard _progress != progress else { return }
    _progress = max(0.0, min(progress, 1.0))
    renderProgress(progress)
  }
}

// MARK: - Core Logic

extension StopwatchCircleView {
  private func renderProgress(_ progress: CGFloat) {
    // CATransaction은 여러 CALayer 관련 변경 사항을 하나의 애니메이션 트랜젝션으로 묶어줌
    CATransaction.begin() // begin으로 트랜잭션 시작
    defer { CATransaction.commit() } // defer를 사용해 함수 종료 시점에 무조건 commit()으로 트랜직션 종료

    CATransaction.setDisableActions(true)

    progressLayer.strokeEnd = progress
  }

  // 원호 경로(벡터 path)를 생성하여 반환하는 메서드
  private func arcPath(in bounds: CGRect) -> UIBezierPath {
    let radius = min(bounds.width, bounds.height) * 0.5 - lineWidth * 0.5
    return UIBezierPath(
      arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
      radius: radius,
      startAngle: -.pi / 2, // 12시 방향 시작
      endAngle: 1.5 * .pi, // 1바퀴
      clockwise: true
    )
  }

  private func setup() {
    trackLayer.lineWidth = lineWidth
    progressLayer.lineWidth = lineWidth

    layer.addSublayer(trackLayer)
    layer.addSublayer(progressLayer)
  }
}
