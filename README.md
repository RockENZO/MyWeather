# MyWeather

MyWeather is a SwiftUI-based weather application that provides current weather information based on the user's location. The app features a launching animation and a loading view with advanced animations.

## Features

- Launching animation with a smooth transition to the main content
- Fetches current weather data based on the user's location
- Displays temperature, wind speed, and humidity
- Advanced loading animations

## Requirements

- iOS 16.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository
2. Open the project in Xcode
3. Build and run the project on your simulator or device.

## Usage

1. On launch, the app displays a launching animation.
2. After the animation, the app requests location permissions.
3. Once the location is obtained, the app fetches the current weather data.
4. The main screen displays the temperature, wind speed, and humidity.

## Code Overview

### LaunchView

`LaunchView` displays the launching animation and transitions to `ContentView` after the animation.

### ContentView
`ContentView` manages the display of the `LaunchView` and the main weather content.

### WeatherRow
`WeatherRow` displays individual weather information such as temperature, wind speed, and humidity.

### LocationManager
`LocationManager` handles location services and provides the user's current location.

### WeatherManager
`WeatherManager` fetches weather data from the OpenWeatherMap API based on the user's location.

### LineGraph
`LineGraph` displays the hourly forecast using a line graph.

### License
This project is licensed under the MIT License. See the LICENSE file for details.

### Acknowledgements
[OpenWeatherMap API](https://openweathermap.org/api) for providing weather data.  
[SwiftUI](https://developer.apple.com/xcode/swiftui/) for the UI framework.


