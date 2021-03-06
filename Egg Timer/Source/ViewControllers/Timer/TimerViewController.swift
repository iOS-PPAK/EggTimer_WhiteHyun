//
//  ViewController.swift
//  Egg Timer
//
//  Created by 홍승현 on 2022/05/16.
//

import UIKit
import UserNotifications

import SnapKit
import Then

final class TimerViewController: BaseViewController {
  
  private enum Metrics {
    
    static let cornerRadius = 35.0
    
    static let thresholdHeight = 760.0
    
  }
  
  private var eggTimeManager = EggTimeManager()
  
  var isAnalogClock: Bool?
  
  //MARK: - UI Property Part
  
  /// 시계 UI를 형성하는 layer
  lazy var clockLayer = ClockLayer(diameter: view.frame.height / 2.789 / 2)
  
  // MARK: UIView
  
  let subBackgroundView = UIView().then {
    $0.backgroundColor = Color.appSubBackgroundColor
    $0.layer.cornerRadius = Metrics.cornerRadius
    $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
  }
  
  let softViewContainer = UIView(frame: .zero)
  
  let mediumViewContainer = UIView(frame: .zero)
  
  let hardViewContainer = UIView(frame: .zero)
  
  // MARK: UIStackView
  
  let eggButtonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .fill
    $0.distribution = .fillEqually
    $0.spacing = 25
    $0.layer.cornerRadius = Metrics.cornerRadius
    $0.backgroundColor = Color.appPointColor.withAlphaComponent(0.5)
  }
  
  // MARK: UILabel
  
  let timeLabel = UILabel().then {
    $0.textAlignment = .center
    $0.text = "00:00"
    $0.font = .systemFont(ofSize: 60, weight: .regular)
    $0.sizeToFit()
  }
  
  let titleLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 51, weight: .bold)
    $0.text = "Egg Timer"
    $0.sizeToFit()
  }
  
  // MARK: UIImageView
  
  let softEggImageView = UIImageView().then {
    $0.image = UIImage(named: "soft")
    $0.contentMode = .scaleAspectFit
  }
  
  let mediumEggImageView = UIImageView().then {
    $0.image = UIImage(named: "medium")
    $0.contentMode = .scaleAspectFit
  }
  
  let hardEggImageView = UIImageView().then {
    $0.image = UIImage(named: "hard")
    $0.contentMode = .scaleAspectFit
  }
  
  // MARK: UIButton
  
  lazy var settingsButton = UIButton(type: .system).then {
    $0.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
    $0.tintColor = Color.appPointColor
    $0.addTarget(self, action: #selector(settingsButtonDidTaps(_:)), for: .touchUpInside)
  }
  
  lazy var softButton = UIButton(type: .system).then {
    $0.setTitle("Soft", for: .normal)
    $0.titleLabel?.font = UIFont.systemFont(ofSize: self.view.frame.height > Metrics.thresholdHeight ? 20 : 16, weight: .regular)
    $0.contentVerticalAlignment = .bottom
    $0.tintColor = UIColor.black
    $0.addTarget(self, action: #selector(eggButtonDidTaps(_:)), for: .touchUpInside)
  }
  
  lazy var mediumButton = UIButton(type: .system).then {
    $0.setTitle("Medium", for: .normal)
    $0.titleLabel?.font = UIFont.systemFont(ofSize: self.view.frame.height > Metrics.thresholdHeight ? 20 : 16, weight: .regular)
    $0.contentVerticalAlignment = .bottom
    $0.tintColor = UIColor.black
    $0.addTarget(self, action: #selector(eggButtonDidTaps(_:)), for: .touchUpInside)
  }
  
  lazy var hardButton = UIButton(type: .system).then {
    $0.setTitle("Hard", for: .normal)
    $0.titleLabel?.font = UIFont.systemFont(ofSize: self.view.frame.height > Metrics.thresholdHeight ? 20 : 16, weight: .regular)
    $0.contentVerticalAlignment = .bottom
    $0.tintColor = UIColor.black
    $0.addTarget(self, action: #selector(eggButtonDidTaps(_:)), for: .touchUpInside)
  }
  
  //MARK: - Life Cycle Part
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    // delegate 설정
    eggTimeManager.delegate = self
    
    // 작업한 레이아웃을 바로 적용
    view.layoutIfNeeded()
    
    clockLayer.frame = CGRect(
      x: timeLabel.center.x,
      y: timeLabel.center.y,
      width: 0,
      height: 0
    )
    
    // MARK: Notification Observer
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(willEnterForeground(_:)),
      name: .willEnterForeground,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didEnterBackground(_:)),
      name: .didEnterBackground,
      object: nil
    )
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupClock()
  }
  
  override func setupLayout() {
    super.setupLayout()
    
    softViewContainer.addSubview(softEggImageView)
    softViewContainer.addSubview(softButton)
    
    mediumViewContainer.addSubview(mediumEggImageView)
    mediumViewContainer.addSubview(mediumButton)
    
    hardViewContainer.addSubview(hardEggImageView)
    hardViewContainer.addSubview(hardButton)
    
    [softViewContainer, mediumViewContainer, hardViewContainer].forEach {
      eggButtonStackView.addArrangedSubview($0)
    }
    
    view.addSubview(titleLabel)
    view.addSubview(settingsButton)
    view.addSubview(subBackgroundView)
    view.addSubview(eggButtonStackView)
    
    subBackgroundView.layer.addSublayer(clockLayer)
    subBackgroundView.addSubview(timeLabel)
    
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    
    // MARK: Title Constraints
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(80)
      make.centerX.equalTo(view.center.x)
    }
    
    // MARK: Settings Button Constraints
    
    settingsButton.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
      make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
      make.width.height.equalTo(38)
    }
    
    // MARK: SubBackground View Constraints
    
    subBackgroundView.snp.makeConstraints { make in
      make.edges.equalTo(UIEdgeInsets(top: 176, left: 0, bottom: 0, right: 0))
    }
    
    // MARK: Egg Stack View Constraints
    
    eggButtonStackView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(30)
      make.height.equalTo(view.frame.height / 5.8)
    }
    
    // MARK: Egg ImageView Constraints
    
    softEggImageView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview().inset(20)
    }
    
    mediumEggImageView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview().inset(20)
    }
    
    hardEggImageView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview().inset(20)
    }
    
    // MARK: Button Constraints
    
    softButton.snp.makeConstraints { make in
      make.leading.trailing.top.equalToSuperview()
      make.bottom.equalToSuperview().inset(5)
    }
    
    mediumButton.snp.makeConstraints { make in
      make.leading.trailing.top.equalToSuperview()
      make.bottom.equalToSuperview().inset(5)
    }
    
    hardButton.snp.makeConstraints { make in
      make.leading.trailing.top.equalToSuperview()
      make.bottom.equalToSuperview().inset(5)
    }
    
    timeLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(subBackgroundView.snp.top).offset(view.frame.height / 5.5)
    }
  }
  
  override func setupStyle() {
    super.setupStyle()
    
    navigationController?.isNavigationBarHidden = true
    view.backgroundColor = Color.appBackgroundColor
  }
  
  //MARK: - Function Part
  
  func setupClock() {
    
    let clockVersion = UserDefaults.standard.bool(forKey: UserDefaults.Keys.switchClock)
    
    
    // 처음 앱을 실행 한 게 아니면서 설정으로 변경한 시계UI와 지금의 UI가 같으면
    // 불필요한 연산 없이 즉시 리턴
    if isAnalogClock != nil, isAnalogClock! == clockVersion { return }
    
    // 시계 UI 업데이트
    if clockVersion {
      clockLayer.displayAnalogClock()
      timeLabel.isHidden = true
    } else {
      clockLayer.displayDigitalClock()
      timeLabel.isHidden = false
    }
    
    isAnalogClock = clockVersion
    
  }
  
  // MARK: - Action Part
  
  @objc func eggButtonDidTaps(_ sender: UIButton) {
    
    guard let hardness = sender.currentTitle
    else {
      
      let alert = UIAlertController(
        title: "오류!",
        message: "버튼에 문제가 있네요.",
        preferredStyle: .alert
      )
      
      alert.addAction(UIAlertAction(title: "확인", style: .default))
      present(alert, animated: true)
      return
    }
    
    // 타이머 설정
    eggTimeManager.setTimer(to: hardness)
    
    // 타이머 시작
    eggTimeManager.startTimer()
    
    // 타이머 시간만큼 애니메이션 실행
    clockLayer.animate(duration: eggTimeManager.timeLeft)
  }
  
  
  @objc func settingsButtonDidTaps(_ sender: UIButton) {
    navigationController?.pushViewController(SettingsViewController(), animated: true)
  }
  
  // MARK: - Observer Part
  
  @objc func willEnterForeground(_ notification: Notification) {
    guard let timeGoesBy = notification.userInfo?["interval"] as? Double,
          eggTimeManager.timeLeft > 0
    else {
      return
    }
    
    eggTimeManager.setTimer(to: eggTimeManager.timeLeft - timeGoesBy)
    eggTimeManager.startTimer()
    
    UNUserNotificationCenter
      .current()
      .removePendingNotificationRequests(withIdentifiers: [UserNotificationID.timerDone])
  }
  
  
  @objc func didEnterBackground(_ notification: Notification) {
    
    guard eggTimeManager.timeLeft > 0 else { return }
    
    
    // 푸시알림 설정 유무를 가져옴
    UNUserNotificationCenter.current().getNotificationSettings { [unowned self] settings in
      
      // 푸시 알림을 동의했다면
      if settings.authorizationStatus == .authorized {
        
        // 1. 컨텐츠 정의
        let content = UNMutableNotificationContent()
        content.title = "알림"
        content.subtitle = "끝났어요!"
        content.body = "얼른 삶은 달걀을 꺼내보세요!!"
        content.sound = .default
        
        // 2. 트리거 조건 정의
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: eggTimeManager.timeLeft, repeats: false)
        
        // 3. 요청 생성
        let request = UNNotificationRequest(identifier: UserNotificationID.timerDone, content: content, trigger: trigger)
        
        // 4. NotificationCenter에 추가
        UNUserNotificationCenter.current().add(request)
        
      }
    }
  }
}

// MARK: - EggTimeDelegate

extension TimerViewController: EggTimeDelegate {
  
  func timerDidChangesPerTick(_ manager: EggTimeManager, timeString: String) {
    timeLabel.text = timeString
  }
  
  
  func timerDone(_ manager: EggTimeManager) {
    timeLabel.text = "Done!"
  }
}
