//
//  SettingTableViewCell.swift
//  Egg Timer
//
//  Created by 홍승현 on 2022/05/17.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
  
  static let cellIdentifier = "settingsCell"
  
  let label = UILabel().then {
    $0.font = .systemFont(ofSize: 20, weight: .medium)
  }
  
  let settingSwitch = UISwitch()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayout()
    setupConstraints()
    setupStyle()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  func setupLayout() {
    contentView.addSubview(label)
    contentView.addSubview(settingSwitch)
  }
  
  func setupConstraints() {
    
    label.snp.makeConstraints { make in
      make.leading.top.bottom.equalToSuperview().inset(10)
    }
    
    settingSwitch.snp.makeConstraints { make in
      make.trailing.top.bottom.equalToSuperview().inset(10)
    }
  }
  
  func setupStyle() {
    backgroundColor = .clear
    selectionStyle = .none
  }
}
