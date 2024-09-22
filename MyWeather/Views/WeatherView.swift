//
//  WeatherView.swift
//  MyWeather
//
//  Created by Rock on 15/9/2024.
//


import SwiftUI
import MapKit

struct WeatherView: View {
    var weather: ResponseBody
    var forecast: ForecastResponse
    
    @State var startingOffsetY: CGFloat = 0
    @State var currentDragOffsetY: CGFloat = 0
    @State var endingOffsetY: CGFloat = 0
    @State var isCardUp: Bool = false
    
    @State private var region: MKCoordinateRegion
    @State private var animatedTemperature: Int = 0

    init(weather: ResponseBody, forecast: ForecastResponse) {
        self.weather = weather
        self.forecast = forecast
        self._region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: weather.coord.lat, longitude: weather.coord.lon),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    }
    
    private let titleFont = Font.title.bold()
    private let headingFont = Font.headline.bold()
    private let bodyFont = Font.body
    private let valueFont = Font.body.bold()
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(weather.name)
                        .font(titleFont)
                        .foregroundColor(.white) // Ensure text is visible
                    Text("Today, \(Date().formatted(.dateTime.month().day().hour().minute()))")
                        .font(bodyFont)
                        .fontWeight(.light)
                        .foregroundColor(.white) // Ensure text is visible
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                VStack {
                    HStack {
                        VStack(spacing: 20) {
                            Image(systemName: "cloud")
                                .font(.system(size: 50))
                                .bold()
                                .foregroundColor(.white) // Ensure icon is visible
                            
                            Text("\(weather.weather[0].main)")
                                .font(bodyFont)
                                .bold()

                        }
                        .frame(width: 100, alignment: .leading)
                        
                        Spacer()
                        
                        Text("\(animatedTemperature)°") // Use animated temperature
                            .font(.system(size: 80))
                            .fontWeight(.bold)
                            .padding()
                            .foregroundColor(.white) // Ensure text is visible
                            .onAppear {
                                let targetTemperature = Int(weather.main.feelsLike)
                                Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                                    if animatedTemperature < targetTemperature {
                                        animatedTemperature += 1
                                    } else {
                                        timer.invalidate()
                                    }
                                }
                            }
                    }
                    
                    Spacer()
                        .frame(height: 1)
                    
                    // Replace forecast data display with LineGraph
                    VStack {
                        LineGraph(dataPoints: forecast.list.map { (time: $0.dt_txt, temp: $0.main.temp) })
                            .frame(height: 200) // Set the height of the graph
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .opacity(0.8)
                            )
                            .cornerRadius(20)
                            .background(Color.clear)
                            .zIndex(-1)
                    } // Ensure the graph is behind other content
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Weather now")
                        .font(titleFont)
                        .foregroundColor(.white) // Ensure text is visible
                        
                    HStack {
                        WeatherRow(logo: "thermometer", name: "Min temp", value: (weather.main.tempMin.roundDouble() + "°"))
                            .font(valueFont)
                            .foregroundColor(.white) // Ensure text is visible
                        Spacer()
                        WeatherRow(logo: "thermometer", name: "Max temp", value: (weather.main.tempMax.roundDouble() + "°"))
                            .font(valueFont)
                            .foregroundColor(.white) // Ensure text is visible
                    }
                    
                    HStack {
                        WeatherRow(logo: "cloud.fill", name: "Cloudiness", value: "\(weather.clouds.all)" + "%")
                            .font(valueFont)
                            .foregroundColor(.white) // Ensure text is visible
                        Spacer()
                        WeatherRow(logo: "humidity", name: "Humidity", value: "\(weather.main.humidity.roundDouble())%")
                            .font(valueFont)
                            .foregroundColor(.white) // Ensure text is visible
                    }
                    HStack {
                        WeatherRow(logo: "location.north.line", name: "Wind Direction", value: "\(Int(weather.wind.deg))°")
                            .font(valueFont)
                            .foregroundColor(.white) // Ensure text is visible
                        Spacer()
                        WeatherRow(logo: "wind", name: "Wind speed", value: (weather.wind.speed.roundDouble() + " m/s"))
                            .font(valueFont)
                            .frame(width: 170)
                            .foregroundColor(.white) // Ensure text is visible
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.bottom, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(40)
                .offset(y: startingOffsetY + currentDragOffsetY + endingOffsetY)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.spring()) {
                                currentDragOffsetY = value.translation.height
                                isCardUp = value.translation.height < -100
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                if currentDragOffsetY < -100 {
                                    endingOffsetY = -UIScreen.main.bounds.height * 0.5
                                } else if endingOffsetY != 0 && currentDragOffsetY > 100 {
                                    endingOffsetY = 0
                                }
                                currentDragOffsetY = 0
                                isCardUp = endingOffsetY == -UIScreen.main.bounds.height * 0.5
                            }
                        }
                )
            }
            
            if isCardUp {
                VStack(spacing: 10) {
                    Spacer()
                    Text("For More Info")
                        .font(titleFont)
                        .foregroundColor(.white) // Ensure text is visible
                    
                    ProgressView(value: (Double(weather.main.pressure) - 950) / 100) {
                        Text("Pressure")
                            .font(headingFont)
                            .bold()
                            .foregroundColor(.white) // Ensure text is visible
                    }
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .frame(width: 350)
                    .frame(maxWidth: .infinity)
                    
                    ProgressView(value: Double(weather.visibility) / 10000) {
                        Text("Visibility")
                            .font(headingFont)
                            .foregroundColor(.white) // Ensure text is visible
                    }
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .frame(width: 350)
                    .frame(maxWidth: .infinity)
                    .padding([.top, .bottom], 10)
                    
                    Map(coordinateRegion: $region)
                        .frame(width:373, height: 230)
                        .cornerRadius(40)
                    Spacer()
                    
                }
                .frame(maxWidth: .infinity,maxHeight: 360)
                .padding()
                .foregroundColor(.white)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.orange, .pink]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(40)
                .shadow(radius: 10)
                .offset(y: UIScreen.main.bounds.height * 0.40)
                .padding(.bottom, 280)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hue: 0.656, saturation: 0.787, brightness: 0.954), // Lightened shade
                    Color(hue: 0.656, saturation: 0.787, brightness: 0.054)  // Darkened shade
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .preferredColorScheme(.dark)
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(weather: previewWeather, forecast: previewForecast)
    }
}
