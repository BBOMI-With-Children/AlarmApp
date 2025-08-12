# AlarmApp

<br>

<p align="left">
  <img src="https://github.com/user-attachments/assets/0474bc57-a744-4a60-9eae-c66cddede535" width="200" alt="앱 아이콘" />
</p>

<br>

## 📋 프로젝트

- **프로젝트 기간**: 2025.08.05(화) ~ 2025.08.12(화)

<br>

## 👥 팀 구성

> 팀명: 뽀미와 아이들

| 이름      | 역할       | GitHub                           |
| -------- | -------- | --------------------------------- |
| 서광용   | 세계시계 | [@MoriOS](https://github.com/Gwangyong) |
| 노가현   | 알람 | [@rkgus](https://github.com/rkgus24) |
| 김이든   | 스톱워치 | [@Eden](https://github.com/kim-eden) |
| 박범근   | 타이머 | [@Luca Park](https://github.com/qlife1146) |

<br>

## 📂 프로젝트 구조
```
Alarm
├── App
│   ├── AppDelegate.swift
│   ├── LaunchScreen.storyboard
│   └── SceneDelegate.swift
│
├── Resources
│   ├── Alarm
│   ├── Assets.xcassets
│   ├── Info.plist
│   └── radial
│
├── Scenes
│   ├── Alarm
│   │   ├── Alarm.swift
│   │   ├── AlarmCell.swift
│   │   └── AlarmViewController.swift
│   │
│   ├── AlarmEdit
│   │   ├── AlarmEditViewController.swift
│   │   ├── Weekday.swift
│   │   └── WeekdaySelectorView.swift
│   │
│   ├── RootScene
│   │   └── MainTabBarController.swift
│   │
│   ├── Service
│   │   ├── AlarmManager.swift
│   │   └── StopWatchUserDefaults.swift
│   │
│   ├── Stopwatch
│   │   ├── LapCollectionViewCell.swift
│   │   ├── StopWatchCircleView.swift
│   │   ├── StopWatchModel.swift
│   │   ├── StopWatchViewController.swift
│   │   └── StopWatchViewModel.swift
│   │
│   ├── Timer
│   │   ├── AddTimerViewController.swift
│   │   ├── TimerDataManager.swift
│   │   ├── TimerPickerView.swift
│   │   ├── TimerTableViewCell.swift
│   │   └── TimerViewController.swift
│   │
│   └── WorldTime
│       ├── CitySelection
│       │   ├── WorldTimeCitySelectionViewController.swift
│       │   └── WorldTimeCitySelectionViewModel.swift
│       │
│       └── WorldTime
│           ├── WorldTimeCell.swift
│           ├── WorldTimeViewController.swift
│           └── WorldTimeViewModel.swift
```

<br>

## 📱 화면 흐름도
아래는 앱의 화면 전환 및 주요 UI 요소 구성을 나타낸 화면 흐름도입니다.

![화면 흐름도](https://github.com/user-attachments/assets/a67dd1a0-f98c-4e1d-bdbb-b0edbab58401)

<br>

## 🛠️ 기술 스택

### 언어 및 UI Framework
- `Swift`
- `UIKit`
- `SnapKit` 5.7.1

### 아키텍처
- `MVVM`

### 주요 라이브러리
- `RxSwift` 6.9.0
- `Then` 3.0.0

### 알림
- `UNUserNotificationCenter`

### 데이터 저장
- `UserDefaults`


<br>

## 📱 주요 기능

### 세계 시계
- **세계 시계**
  - 현재 시각/오전·오후와 GMT 편차(오늘/어제/내일, ±n시간), 도시명 표시
  - 1분 단위 자동 갱신으로 시각 실시간 업데이트
  - 편집 모드: 시간 라벨 숨김, 삭제/드래그 이동 지원
  - 선택한 도시는 UserDefaults에 저장되어 앱 재실행 시에도 유지
- **도시 추가**
  - 도시 목록을 A~Z 섹션 헤더로 그룹화, 상단에 현재 섹션 표시
  - 우측 섹션 인덱스 스크롤로 빠른 탐색 지원
  - 상단 검색 기능: 섹션 구조 유지한 필터링(대소문자 무시)


### 알람
- 추가예정

### 스톱워치
- 추가예정

### 타이머
- **타이머 추가**
  - 시간 설정 후 추가하면 설정한 시간으로 타이머 시작
  - 레이블 미설정 시 설정한 시간으로 지정
- **타이머**
  - 타이머 일시정지일 때는 텍스트가 회색으로, 진행 중일 때는 흰색으로
  - 여러 타이머가 있는 상태에서 일시정지를 하면 시간에 맞춰서 재정렬
- **타이머 삭제**
  - 스와이프로 삭제 가능
  - 스와이프 중에도 타이머 멈춤 없이 진행

<br>

## ✍️ 커밋 컨벤션

```
[작업] #이슈번호-커밋제목

chore: #1 - 뷰 요소 수정, 리네임, 파일 위치 변경
feat: #1 - 새로운 주요 기능 추가
add: #2 - 파일 추가
fix: #2 - 버그 수정
refactor: #2 - 코드 리팩토링
```

> 예시
```
feat: #79 - 사운드, 배너 추가
chore: #85 아이콘 추가 및 화면 방향 세로 고정
fix: #74 - 배경색이 회색으로 조금 보이는 문제 해결
```

<br>

### 🌿 브랜치 네이밍 규칙
- `feat/이슈넘버`, `fix/이슈넘버`, `style/이슈넘버` 등 prefix 사용  
- 예시: `chore/85-icon-portrait`, `feat/74-city-selection-section-header`
- 병합 조건
   - ✅ PR 병합 전 **최소 2명 승인 필요**
   - ❌ `git push --force` 금지
   - 👥 모든 팀원에게 동일 규칙 적용 (Bypass 없음)

<br>

## ⛓️‍💥 와이어 프레임 
- [Figma 링크](https://www.figma.com/design/Mn3uCjHXfjF14r7zz0saTk/BBomiWithChildren?node-id=0-1&p=f&t=vFO4wSujmlkL4Ndt-0)
