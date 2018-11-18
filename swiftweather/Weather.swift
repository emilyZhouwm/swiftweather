//
//  Weather.swift
//  swiftweather
//
//  Created by zwm on 2018/11/16.
//  Copyright © 2018 rd.zhou. All rights reserved.
//

import UIKit

struct Weather {
    var temperature: String = ""
    var weather: String = ""
    var wind: String = ""
    var date: String = ""
    var week: String = ""
    var uvIndex: String = ""
    var dateY: String = ""
    var city: String = ""
    var weatherId: [String:String] = ["":""]
}

struct WeatherSK {
    var temp: String = ""
    var windDirection: String = ""
    var windStrength: String = ""
    var humidity: String = ""
    var time: String = ""
}

extension Weather {
    func weatherImage(_ big: Bool) -> UIImage? {
        guard let fa = self.weatherId["fa"] else { return nil }
        
        for wid in WID {
            var imgname = ""
            if wid["wid"] == fa {
                if big {
                    imgname = wid["img1"]!
                }
                else {
                    imgname = wid["img2"]!
                }
                
                if imgname.lengthOfBytes(using: .utf8) > 0 {
                    return UIImage.init(named: imgname)
                }
            }
        }
        
        return nil
    }
    
    func bigWeatherImage() -> UIImage? {
        return weatherImage(true)
    }
    
    func smallWeatherImage() -> UIImage? {
        return weatherImage(false)
    }
    
    func airImage() -> UIImage? {
        // 用紫外线强度模拟空气质量
        var imgname = "ok"
        
        if self.uvIndex == "弱" {
            imgname = "bad"
        }
        else if self.uvIndex == "强" {
            imgname = "nice"
        }
        
        return UIImage.init(named: imgname)
    }
}
