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
    
    @State var startingOffsetY: CGFloat = 0 // Start from the top
    @State var currentDragOffsetY: CGFloat = 0
    @State var endingOffsetY: CGFloat = 0
    @State var isCardUp: Bool = false // Track card position
    
    @State private var region: MKCoordinateRegion // State for the map's region
    
    init(weather: ResponseBody) {
        self.weather = weather
        // Set the region based on the weather coordinates
        self._region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: weather.coord.lat, longitude: weather.coord.lon),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // Adjust zoom level
        ))
    }
    
    // Define common font styles
    private let titleFont = Font.title.bold()
    private let headingFont = Font.headline.bold()
    private let bodyFont = Font.body
    private let valueFont = Font.body.bold()
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                // Main weather information at the top
                VStack(alignment: .leading, spacing: 5) {
                    Text(weather.name)
                        .font(titleFont)
                    
                    Text("Today, \(Date().formatted(.dateTime.month().day().hour().minute()))")
                        .font(bodyFont)
                        .fontWeight(.light)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                VStack {
                    HStack {
                        VStack(spacing: 20) {
                            Image(systemName: "cloud")
                                .font(.system(size: 50))
                                .bold()
                            
                            Text("\(weather.weather[0].main)")
                                .font(bodyFont)
                                .bold()
                        }
                        .frame(width: 100, alignment: .leading)
                        
                        Spacer()
                        
                        Text(weather.main.feelsLike.roundDouble() + "°")
                            .font(.system(size: 80))
                            .fontWeight(.bold)
                            .padding()
                    }
                    
                    Spacer()
                        .frame(height: 50)
                    
                    AsyncImage(url: URL(string: "https://cdn.pixabay.com/photo/2020/01/24/21/33/city-4791269_960_720.png")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 350)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Bottom draggable card
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Weather now")
                        .font(titleFont)
                        
                    
                    HStack {
                        WeatherRow(logo: "thermometer", name: "Min temp", value: (weather.main.tempMin.roundDouble() + "°"))
                            .font(valueFont)
                        Spacer()
                        WeatherRow(logo: "thermometer", name: "Max temp", value: (weather.main.tempMax.roundDouble() + "°"))
                            .font(valueFont)
                    }
                    
                    HStack {
                        WeatherRow(logo: "cloud.fill", name: "Cloudiness", value: "\(weather.clouds.all)" + "%")
                            .font(valueFont)
                        Spacer()
                        WeatherRow(logo: "humidity", name: "Humidity", value: "\(weather.main.humidity.roundDouble())%")
                            .font(valueFont)
                    }
                    HStack {
                        WeatherRow(logo: "location.north.line", name: "Wind Direction", value: "\(weather.wind.deg)" + "°")
                            .font(valueFont)
                            .frame(width: 170, alignment: .leading) // Set a fixed width to prevent wrapping
                        Spacer()
                        WeatherRow(logo: "wind", name: "Wind speed", value: (weather.wind.speed.roundDouble() + " m/s"))
                            .font(valueFont)

                        
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.bottom, 20)
                .foregroundColor(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                .background(Color.white)
                .cornerRadius(40, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                .offset(y: startingOffsetY + currentDragOffsetY + endingOffsetY)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.spring()) {
                                currentDragOffsetY = value.translation.height
                                // Check if the card is dragged up
                                isCardUp = value.translation.height < -100
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                if currentDragOffsetY < -100 {
                                    endingOffsetY = -UIScreen.main.bounds.height * 0.5 // Slide up to the top
                                } else if endingOffsetY != 0 && currentDragOffsetY > 100 {
                                    endingOffsetY = 0 // Slide down to the starting position
                                }
                                currentDragOffsetY = 0 // Reset drag offset
                                isCardUp = endingOffsetY == -UIScreen.main.bounds.height * 0.5
                            }
                        }
                )
            }
            
            // Additional information shown when the card is dragged up
            if isCardUp {
                VStack(spacing: 10) {
                    Spacer()
                    Text("For More Info")
                        .font(titleFont)
                
                    // Pressure Progress Bar
                    ProgressView(value: (Double(weather.main.pressure) - 950) / 100) {
                        Text("Pressure")
                            .font(headingFont)
                            .bold()
                    }
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        
                
                    
                    ProgressView(value: Double(weather.visibility) / 10000) {
                            Text("Visibility")
                            .font(headingFont)
                        }
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .padding([.top,.bottom], 10)
                    // Add Map View based on the weather's coordinates
                    Map(coordinateRegion: $region)
                        .frame(width:373, height: 230)
                        .cornerRadius(40)
                    Spacer()
                    
                }
                .frame(maxWidth: .infinity,maxHeight: 360)
                .padding()
                .foregroundColor(.blue)
                .background(Color.white)
                .cornerRadius(40)
                .shadow(radius: 10)
                .offset(y: UIScreen.main.bounds.height * 0.40) // Position it up a notch to reveal fully
                .padding(.bottom, 280) // Ensure full visibility
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
        .preferredColorScheme(.dark)
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(weather: previewWeather)
    }
}
