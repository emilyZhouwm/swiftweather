//
//  ViewController.swift
//  swiftweather
//
//  Created by zwm on 2018/11/16.
//  Copyright © 2018 rd.zhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var weatherImgView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempSymbolLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    // 风
    @IBOutlet weak var windImgView: UIImageView!
    @IBOutlet weak var windLabel: UILabel!
    
    // 空气质量
    @IBOutlet weak var airLabel: UILabel!
    @IBOutlet weak var airImgView: UIImageView!
    
    // 湿度
    @IBOutlet weak var humLabel: UILabel!
    @IBOutlet weak var humImgView: UIImageView!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingView: UIView!
    
    var today: Weather!
    var future: [Weather]!
    var sk: WeatherSK!
    
    let authKey = "691a8c4d415449ffb69b1a7ac2a4000d"
    
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let tempFont = UIFont.init(name: "AdobeClean-Light", size: 280.0) {
            tempLabel.font = tempFont
        }
        
        if let symbolFont = UIFont.init(name: "AdobeClean-Light", size: 20.0) {
            tempSymbolLabel.font = symbolFont;
        }

        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadingView.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        loadLocalData()
        requestData("北京")
    }
    
    func loadLocalData() {
        if let datafile = Bundle.main.path(forResource: "data", ofType: "json") {
            let data = try! Data.init(contentsOf: URL.init(fileURLWithPath: datafile))
            parseData(data)
        }
    }
    
    func showWeather() {
        weatherImgView.image = today.bigWeatherImage()
        cityLabel.text = today.city
        weatherLabel.text = today.weather
        tempLabel.text = sk.temp
        detailLabel.text = today.dateY + " " + sk.time + "发布"
        
        windLabel.text = sk.windStrength
        humLabel.text = String(sk.humidity.dropLast())
        airLabel.text = today.uvIndex // 紫外线代替空气质量
        airImgView.image = today.airImage()
        
        collectionView.reloadData()
        
        loadingView.isHidden = true
    }
    
    // MARK:-
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.future == nil { return 0 }
        return self.future.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath)
        
        if let cell = cell as? WeatherCell{
            let weather = self.future[indexPath.row]
            cell.setWeather(weather: weather)
            return cell
        }
        
        return cell
    }
    
    // MARK:-
    func requestData(_ city: String) {
        // curl -v -X POST -H'Authorization:APPCODE 691a8c4d415449ffb69b1a7ac2a4000d' -d'cityName=北京' http://weatherapi.market.alicloudapi.com/weather/TodayTemperatureByCity
        let url = URL.init(string: "http://weatherapi.market.alicloudapi.com/weather/TodayTemperatureByCity")
        var request = URLRequest.init(url: url!)
        request.httpMethod = "POST"
        
        if let params = "cityName=\(city)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            request.httpBody = params.data(using: .utf8)
        }
        
        request.addValue("APPCODE \(authKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
            if err != nil {
                self.showInfo(title: "错误", info: "请求数据出错！")
            }
            else {
                self.parseData(data)
            }
        }
        
        task.resume()
    }
    
    func parseData(_ data: Data?) {
        guard let data = data else { return }
        
        guard let object = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary else {
            self.showInfo(title: "错误", info: "解析数据错误")
            return
        }
        
        guard let status = object["status"] as? String else {
            self.showInfo(title: "错误", info: "解析数据错误")
            return
        }
        
        if status != "000000" {
            self.showInfo(title: "错误", info: "解析数据错误")
            return
        }
        
        guard let result = object["result"] as? NSDictionary else {
            self.showInfo(title: "错误", info: "解析数据错误")
            return
        }
        
        guard let today = result["today"] as? NSDictionary else {
            self.showInfo(title: "错误", info: "解析数据错误")
            return
        }
        
        var todayWeather = Weather()
        todayWeather.temperature = today["temperature"] as! String
        todayWeather.weather = today["weather"] as! String
        todayWeather.wind = today["wind"] as! String
        todayWeather.week = today["week"] as! String
        todayWeather.uvIndex = today["uv_index"] as! String
        todayWeather.dateY = today["date_y"] as! String
        todayWeather.city = today["city"] as! String
        todayWeather.weatherId = today["weather_id"] as! [String:String]
        
        self.today = todayWeather
        
        guard let sk = result["sk"] as? NSDictionary else {
            self.showInfo(title: "错误", info: "解析数据错误")
            return
        }
        
        var skWeather = WeatherSK()
        skWeather.temp = sk["temp"] as! String
        skWeather.windDirection = sk["wind_direction"] as! String
        skWeather.windStrength = sk["wind_strength"] as! String
        skWeather.humidity = sk["humidity"] as! String
        skWeather.time = sk["time"] as! String
        
        self.sk = skWeather
        
        guard let future = result["future"] as? NSDictionary else {
            self.showInfo(title: "错误", info: "解析数据错误")
            return
        }
        
        let keys = future.allKeys
        let sortedKeys = keys.sorted { (first, second) -> Bool in
            return (first as! String).localizedStandardCompare(second as! String) == ComparisonResult.orderedAscending
        }
        
        var futureWeathers = [Weather]()
        for key in sortedKeys {
            let weatherData = future[key] as! NSDictionary
            var weather = Weather()
            weather.temperature = weatherData["temperature"] as! String
            weather.weather = weatherData["weather"] as! String
            weather.wind = weatherData["wind"] as! String
            weather.date = weatherData["date"] as! String
            weather.week = weatherData["week"] as! String
            weather.weatherId = weatherData["weather_id"] as! [String:String]
            futureWeathers.append(weather)
        }
        
        self.future = futureWeathers
        
        DispatchQueue.main.async {
            self.showWeather()
        }
    }
    
    func showInfo(title: String, info: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController.init(title: title, message: info, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: "Default action"), style: .default, handler: { _ in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

