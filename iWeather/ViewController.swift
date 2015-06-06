//
//  ViewController.swift
//  iWeather
//
//  Created by liujin on 15/5/20.
//  Copyright (c) 2015年 赵磊. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import Alamofire

class ViewController: UIViewController ,CLLocationManagerDelegate{
    let locationManager:CLLocationManager = CLLocationManager()
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temprature: UILabel!
    @IBOutlet weak var loading: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.loadingIndicator.startAnimating()
        let background = UIImage(named:"background.png")
        self.view.backgroundColor = UIColor(patternImage: background!)
        if(ios8()){
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
    }
    func ios8() -> Bool{
        return UIDevice.currentDevice().systemVersion == "8.3"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        var location:CLLocation = locations[locations.count-1]
            as! CLLocation
        if(location.horizontalAccuracy > 0){
            println(location.coordinate.latitude)
            println(location.coordinate.longitude)
            updateWeatherInfo(location.coordinate.latitude,longitude:location.coordinate.longitude)
            locationManager.stopUpdatingLocation()
        }
    }

    func updateWeatherInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let url = "http://api.openweathermap.org/data/2.5/forecast"
        let params = ["lat":latitude, "lon":longitude]
        println(params)
        
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { (request, response, json, error) in
                if(error != nil) {
                    println("Error: \(error)")
                    println(request)
                    println(response)

                }
                else {
                    println("Success: \(url)")
                    println(request)
                    var json = JSON(json!)
                    self.updateUISuccess(json)
                }
       }
  }
    func updateUISuccess(json:JSON){
        self.loadingIndicator.hidden=true
        self.loadingIndicator.stopAnimating()
        self.loading.text = nil
        if let tempResult = json["list"][0]["main"]["temp"].double{
            
            var temperature: Double
            //美国：华氏温度
            if (json["city"]["country"].stringValue == "US") {
                temperature = round(((tempResult - 273.15) * 1.8) + 32)
            }
            //其他地区：摄氏温度
            else {
                temperature = round(tempResult - 273.15)
            }
              println(temperature)
            self.temprature.text = "\(temperature)°C"
            
            self.location.text = json["city"]["name"].stringValue
            
            let weather = json["list"][0]["weather"][0]
            let condition = weather["id"].intValue
            var icon = weather["icon"].stringValue
            var nightTime = icon.rangeOfString("n") != nil
            self.updateWeatherIcon(condition,nightTime:nightTime)
        }
        else{
            self.loading.text="天气信息不可用"
        }
    }
    
    func updateWeatherIcon(condition: Int, nightTime: Bool){
        println("图标更新")
        if(condition<300){
            if (nightTime){
                self.icon.image = UIImage(named:"tstorm1_night")
            }else{
                self.icon.image = UIImage(named:"tstorm1")
            }
        }
        else if(condition<500){
            self.icon.image = UIImage(named:"light_rain")
        }
        else if(condition<600){
            self.icon.image = UIImage(named:"shower3")
        }
        else if(condition<700){
            self.icon.image = UIImage(named:"snow4")
        }
        else if(condition == 800){
            if (nightTime){
                self.icon.image = UIImage(named:"sunny_night")
            }else{
                self.icon.image = UIImage(named:"sunny")
            }
        }
        else if(condition<804){
            if (nightTime){
                self.icon.image = UIImage(named:"cloudy2_night")
            }else{
                self.icon.image = UIImage(named:"cloudy2")
            }
        }
        else if(condition==804){
            self.icon.image = UIImage(named:"overcast")
        }
        else if ((condition >= 900 && condition < 903) || (condition > 904 && condition < 1000)) {
            self.icon.image = UIImage(named:"tstorm3")
        }
        else if(condition==903){
            self.icon.image = UIImage(named:"snow5")
        }
        else if(condition==904){
            self.icon.image = UIImage(named:"sunny")
        }
        else{
            self.icon.image = UIImage(named:"dunno")
        }
    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        println(error)
        self.loading.text = "地理信息不可用"
    }

}

