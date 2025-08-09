//
//  WorldTimeCell.swift
//  Alarm
//
//  Created by 서광용 on 8/7/25.
//

import UIKit
import SnapKit
import Then

final class WorldTimeCell: UITableViewCell {
 static let id = "WorldTimeCell"
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}