//
//  ViewController.swift
//  Lab8
//
//  Created by user238626 on 3/15/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    //Location manager
    let manager = CLLocationManager()
    
    // Label for location
    @IBOutlet weak var labelLocation: UILabel!
    
    // Label for weather type
    @IBOutlet weak var labelWeather: UILabel!
    
    // Image for weather icon
    @IBOutlet weak var imageIcon: UIImageView!
    
    // Label for temperature
    @IBOutlet weak var labelTemp: UILabel!
    
    // Label for humidity
    @IBOutlet weak var labelHumidity: UILabel!
    
    // Label for wind speed
    @IBOutlet weak var labelWind: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set location manager settings and start updating location
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    // Set location and pass to API call
    func locationManager(_ manager: CLLocationManager, didUpdateLocations location: [CLLocation]) {
        manager.startUpdatingLocation()
        
        // Attempt to get current location
        guard let currentLocation = manager.location
        else {
            return
        }
        
        // Stop updating location so data is fetched only once
        //manager.stopUpdatingLocation()
        
        // Pass location to API call
        makeAPICall(location: currentLocation)
    }
    
    // Get JSON data
    func makeAPICall(location: CLLocation) {
        let coordinate = location.coordinate
        
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(String(describing: coordinate.latitude))&lon=\(String(describing: coordinate.longitude))&appid=d3f0956caa7ad29a06e029f9a9cb7c0e") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let jsonData = try JSONDecoder().decode(Weather.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.updateLabels(weather: jsonData)
                    }
                } catch {
                    print("Error decoding data.")
                }
            } else {
                print("Error getting data from server.")
            }
        }
        task.resume()
    }

    
    // Get weather icon image
    func getImage(icon: String) {
        guard let url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    self.imageIcon.image = UIImage(data: data)
                }
            } else {
                print("Error getting icon from server.")
            }
        }
        task.resume()
    }

    
    // Update view with weather data
    func updateLabels(weather: Weather) {
        let name = weather.name
        let weatherText = weather.weather[0].main
        let icon = weather.weather[0].icon
        let temp = Int(weather.main.temp - 273.15)
        let humidity = weather.main.humidity
        let wind = weather.wind.speed
        
        labelLocation.text = name
        labelWeather.text = weatherText
        labelTemp.text = "\(temp)°"
        labelHumidity.text = "Humidity: \(humidity)%"
        labelWind.text = "Wind: \(wind) km/h"
        
        getImage(icon: icon)
    }

}

