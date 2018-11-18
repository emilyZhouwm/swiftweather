//
//  WeatherCell.swift
//  swiftweather
//
//  Created by zwm on 2018/11/17.
//  Copyright © 2018 rd.zhou. All rights reserved.
//

import UIKit

class WeatherCell: UICollectionViewCell {
    
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    func setWeather(weather: Weather) {
        weekdayLabel.text = weather.week
        tempLabel.text = weather.temperature
        imgView.image = weather.smallWeatherImage()
    }
}
