//in networking there are 4 steps
// 1 create a URL
//create a URLSession
// assign task to URLSession
//start task
//when we deal with API and deal with other sytems in this case open weather this is called networking to make it simple we create these 4 steps to deal with networking

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?APPID=895dad1f048d0342f1c9ffb65e19d381&units=metric"
    
    var delegate: WeatherManagerDelegate? //which ever class has weather manager delegate will have did update method so we call the delegate method

    
    func fetchWeather(cityName: String) { //
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    // CLLocation degree is the data type of lat and lon of the location
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    //   //this is the url string we get from open weather and which is of string type
    func performRequest(with urlString: String) {
        // 1- create url this is first step
        if let url = URL(string: urlString) {
            // 2-create url session(this url reterive the content of specified url
            let session = URLSession(configuration: .default)//This sets up a default session that can be used for data retrieval tasks.
            // 3- assign task to url session
            let task = session.dataTask(with: url) { (data, response, error) in //it is ananoymous function or closures

                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) { //we used enternal parameter and simply passed the value to it.we unwrap the weather object which w get from parse json

                        self.delegate?.didUpdateWeather(self, weather: weather) //delegate will be our weatherviewcontroller class

                    }
                }
            }
            //4- start the task
            task.resume()
        }
    }
    //parseJSON receives 1 parameter weatherData which is format of Data which is received from data task when we assign url session a task
    func parseJSON(_ weatherData: Data) -> WeatherModel? {  //
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)//
            let id = decodedData.weather[0].id//
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}


