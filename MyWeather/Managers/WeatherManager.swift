//
//  WeatherManager.swift
//  MyWeather
//
//  Created by Rock on 15/9/2024.
//

import Foundation
import CoreLocation

// WeatherManager.swift

import Foundation
import CoreLocation

class WeatherManager {
    // HTTP request to get the current weather depending on the coordinates we got from LocationManager
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ResponseBody {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\("YOUR_API_KEY")&units=metric") else { fatalError("Missing URL") }

        let urlRequest = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
        
        let decodedData = try JSONDecoder().decode(ResponseBody.self, from: data)
        
        return decodedData
    }

    // HTTP request to get the weather forecast depending on the coordinates we got from LocationManager
    func getWeatherForecast(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ForecastResponse {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\("YOUR_API_KEY")&units=metric") else { fatalError("Missing URL") }

        let urlRequest = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
        
        let decodedData = try JSONDecoder().decode(ForecastResponse.self, from: data)
        
        return decodedData
    }
}

// Model of the forecast response body we get from calling the OpenWeather API
struct ForecastResponse: Decodable {
    var cod: String
    var message: Int
    var cnt: Int
    var list: [Forecast]
    var city: City
    
    struct Forecast: Decodable {
        var dt: Int
        var main: MainResponse
        var weather: [WeatherResponse]
        var clouds: CloudsResponse
        var wind: WindResponse
        var visibility: Int
        var pop: Double
        var rain: RainResponse?
        var sys: SysResponse
        var dt_txt: String
    }
    
    struct City: Decodable {
        var id: Int
        var name: String
        var coord: Coord
        var country: String
        var population: Int
        var timezone: Int
        var sunrise: Int
        var sunset: Int
    }
    
    struct Coord: Decodable {
        var lat: Double
        var lon: Double
    }
}

struct MainResponse: Decodable {
    var temp: Double
    var feels_like: Double
    var temp_min: Double
    var temp_max: Double
    var pressure: Int
    var humidity: Int
    var sea_level: Int?
    var grnd_level: Int?
    var temp_kf: Double?
}

struct WeatherResponse: Decodable {
    var id: Int
    var main: String
    var description: String
    var icon: String
}

struct WindResponse: Decodable {
    var speed: Double
    var deg: Int
    var gust: Double?
}

struct CloudsResponse: Decodable {
    var all: Int
}

struct RainResponse: Decodable {
    var three_h: Double?
    
    enum CodingKeys: String, CodingKey {
        case three_h = "3h"
    }
}

struct SysResponse: Decodable {
    var pod: String
}

// Model of the response body we get from calling the OpenWeather API
struct ResponseBody: Decodable {
    var coord: CoordinatesResponse
    var weather: [WeatherResponse]
    var main: MainResponse
    var name: String
    var wind: WindResponse
    var visibility: Int
    var clouds: CloudsResponse
    var sys: SysResponse // Add this property
    
    struct CoordinatesResponse: Decodable {
        var lon: Double
        var lat: Double
    }
    
    struct WeatherResponse: Decodable {
        var id: Double
        var main: String
        var description: String
        var icon: String
    }
    
    struct MainResponse: Decodable {
        var temp: Double
        var feels_like: Double
        var temp_min: Double
        var temp_max: Double
        var pressure: Double
        var humidity: Double
    }
    
    struct WindResponse: Decodable {
        var speed: Double
        var deg: Double
    }

    struct CloudsResponse: Decodable {
        var all: Int
    }

    struct SysResponse: Decodable { // Add this struct
        var sunrise: Double
        var sunset: Double
    }
}

extension ResponseBody.MainResponse {
    var feelsLike: Double { return feels_like }
    var tempMin: Double { return temp_min }
    var tempMax: Double { return temp_max }
}


//0801c5fa224352fc66378e804f807252
