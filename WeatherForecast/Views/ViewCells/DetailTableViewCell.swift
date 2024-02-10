//
//  WeatherDetailTableViewCell.swift
//  WeatherForecast
//
//  Created by Maxim Kucherov on 05/12/2023.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    let weekDayLabel = UILabel()
    let percentLabel = UILabel()
    let temperatureLabel = UILabel()
    let iconImage = UIImageView()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupTableViewCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

    // MARK: - Setup TableViewCell
extension DetailTableViewCell {
    private func setupTableViewCell() {
        
        // Stack iconImage and percentLabek
        percentLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        percentLabel.textColor = .systemBlue
        let imageHumidityStack = UIStackView(arrangedSubviews: [iconImage, percentLabel])
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconImage.heightAnchor.constraint(equalToConstant: 25).priority = .defaultHigh
        iconImage.widthAnchor.constraint(equalToConstant: 25).priority = .defaultHigh
        
        // Stack weekDayLabel, imageHumidityStack, temperatureLabel
        temperatureLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        temperatureLabel.textColor = .white
        weekDayLabel.textColor = .white
        weekDayLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        weekDayLabel.widthAnchor.constraint(equalToConstant: 90).isActive = true
        let detailStackView = UIStackView(arrangedSubviews: [weekDayLabel, imageHumidityStack, temperatureLabel])
        detailStackView.axis = .horizontal
        detailStackView.distribution = .equalCentering
        contentView.addSubview(detailStackView)
        
        detailStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            detailStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
