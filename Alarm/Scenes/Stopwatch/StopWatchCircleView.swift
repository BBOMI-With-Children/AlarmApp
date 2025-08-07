//
//  StopwatchCircleView.swift
//  Alarm
//
//  Created by 김이든 on 8/7/25.
//

import UIKit
import RxCocoa
import RxSwift

class StopwatchCircleView: UIView {
  // MARK: - Properties
  
  // 진행 경로의 전체 배경 원
  private let trackLayer = CAShapeLayer().then {
    $0.fillColor = UIColor.clear.cgColor  // 내부 비우기
    $0.strokeStart = 0
    $0.strokeEnd = 1
  }
  // 진행상황 그려지는 레이어
  private let progressLayer = CAShapeLayer().then {
    $0.fillColor = UIColor.clear.cgColor
    $0.strokeStart = 0  // stroke 시작 부분 12시 방향
    $0.strokeEnd = 0  // stroke 끝 부분 0.6 이면 60% 채우기
  }
  // 내부적으로 현재 진행값을 보관하는 프로퍼티
  private var _progress: Float = 0
  
  // 배경 원 색상 설정
  var trackColor: UIColor = .modal {
    didSet { trackLayer.strokeColor = trackColor.cgColor }
  }

  // 진행상황 원 색상 설정
  var progressColor: UIColor = .main {
    didSet { progressLayer.strokeColor = progressColor.cgColor }
  }

  // 두께 설정
  var lineWidth: CGFloat = 10 {
    didSet {
      progressLayer.lineWidth = lineWidth
      trackLayer.lineWidth = lineWidth
    }
  }
  
  //검색
  var progress: Float {
    get { return _progress }
    set { setProgress(newValue, animated: false) }
  }

  // 진행 방황 true면 시계 방향, false면 반시계 방향으로 진행
  var clockwise: Bool = true {
    didSet { progressLayer.path = arcPath(in: bounds, clockwise: clockwise).cgPath }
  }

  // 라인 스타일 끝모양 밑에 enum으로 설정
  var lineCap: LineCap {
    get { return LineCap(progressLayer.lineCap) }
    set { progressLayer.lineCap = newValue.shapeLayerLineCap }
  }

  //MARK: - init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  //MARK: - 레이아웃이 갱신될 때마다 자동으로 호출되는 메서드

  override func layoutSubviews() {
    super.layoutSubviews()
    trackLayer.path = arcPath(in: bounds, clockwise: clockwise).cgPath
    progressLayer.path = arcPath(in: bounds, clockwise: clockwise).cgPath
  }
  
  //MARK: - 진행상황 설정
  func setProgress(_ progress: Float, animated: Bool) {
    guard _progress != progress else {
      return
    }
    _progress = max(0.0, min(progress, 1.0))
    renderProgress(progress, animated: animated)
  }
}

//MARK: - 내부 핵심 로직
extension StopwatchCircleView {
  private func renderProgress(_ progress: Float, animated: Bool) {
    // CATransaction은 여러 CALayer 관련 변경 사항을 하나의 애니메이션 트랜젝션으로 묶어줌
    CATransaction.begin() //begin으로 트랜잭션 시작
    defer { CATransaction.commit() } //defer를 사용해 함수 종료 시점에 무조건 commit()으로 트랜직션 종료

    // 애니메이션 bool 받아서 설정
    if !animated {
      CATransaction.setDisableActions(true)
    } else {
      CATransaction.setAnimationDuration(1.5)
    }
    progressLayer.strokeEnd = CGFloat(progress)
  }

  private func arcPath(in bounds: CGRect, clockwise: Bool) -> UIBezierPath {  // 원호 경로(벡터 path)를 생성하여 반환하는 메서드

    // n: 회전할 각도(pi 단위) → 1.5바퀴 또는 -1.5바퀴
    //    - 시계 방향이면 +1.5바퀴 (약 270도)
    //    - 반시계 방향이면 -1.5바퀴 (역방향으로 270도)
    let n: CGFloat = clockwise ? 1.5 : -1.5

    // r: 회전 시작 각도를 기준으로 보정하기 위한 상수
    //    - 시계 방향이면 2 → 2π = 360도
    //    - 반시계 방향이면 1 → 1π = 180도
    let r: CGFloat = clockwise ? 2 : 1

    // radius: 원의 반지름
    //  - bounds의 너비/높이 중 작은 값의 절반에서 선 두께(lineWidth)의 절반만큼 뺀 값
    //  - 이로써 stroke가 UIView 경계 밖으로 나가지 않게 중심 정렬
    let radius = min(bounds.width, bounds.height) * 0.5 - lineWidth * 0.5

    // UIBezierPath 생성
    return UIBezierPath(
      arcCenter: CGPoint(x: bounds.midX, y: bounds.midY), // 원의 중심 = 뷰의 중심
      radius: radius,                                     // 원의 반지름
      startAngle: .pi * 1.5,                              // 시작 각도 = 12시 방향 (270도)
      endAngle: .pi * (r + n),                            // 끝 각도 = r + n (방향에 따라 다름)
      clockwise: clockwise                                // 시계 방향 여부에 따라 호의 진행 방향 결정
    )
  }
  
  private func setup() {
    trackLayer.lineWidth = lineWidth
    trackLayer.strokeColor = trackColor.cgColor

    progressLayer.lineWidth = lineWidth
    progressLayer.strokeColor = progressColor.cgColor

    // Z-Index 처럼 순서대로 UIView 기본 Layer에 추가
    layer.addSublayer(trackLayer)
    layer.addSublayer(progressLayer)
  }
}

//MARK: - LineCap 스타일 enum
extension StopwatchCircleView {
  enum LineCap {
    case butt
    case round
    case square

    fileprivate init(_ lineCap: CAShapeLayerLineCap) {
      switch lineCap {
      case .butt: self = .butt
      case .round: self = .round
      case .square: self = .square
      default: fatalError()
      }
    }

    fileprivate var shapeLayerLineCap: CAShapeLayerLineCap {
      switch self {
      case .butt: return .butt
      case .round: return .round
      case .square: return .square
      }
    }
  }
}
