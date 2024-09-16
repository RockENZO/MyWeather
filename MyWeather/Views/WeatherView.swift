//
//  WeatherView.swift
//  MyWeather
//
//  Created by Rock on 15/9/2024.
//


import SwiftUI

struct WeatherView: View {
    var weather: ResponseBody
    
    // State variables to manage the drag offset
    @State var startingOffsetY: CGFloat = 0 // Start from the top
    @State var currentDragOffsetY: CGFloat = 0
    @State var endingOffsetY: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                // Main weather information at the top
                VStack(alignment: .leading, spacing: 5) {
                    Text(weather.name)
                        .bold()
                        .font(.title)
                    
                    Text("Today, \(Date().formatted(.dateTime.month().day().hour().minute()))")
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
                        .bold()
                        .padding(.bottom)
                    
                    HStack {
                        WeatherRow(logo: "thermometer", name: "Min temp", value: (weather.main.tempMin.roundDouble() + "°"))
                        Spacer()
                        WeatherRow(logo: "thermometer", name: "Max temp", value: (weather.main.tempMax.roundDouble() + "°"))
                    }
                    
                    HStack {
                        WeatherRow(logo: "wind", name: "Wind speed", value: (weather.wind.speed.roundDouble() + " m/s"))
                        Spacer()
                        WeatherRow(logo: "humidity", name: "Humidity", value: "\(weather.main.humidity.roundDouble())%")
                    }
                    HStack{
                        WeatherRow(logo: "location.north.line", name: "Wind Direction", value: "\(weather.wind.deg)" + "°")
                        Spacer()
                        WeatherRow(logo: "cloud.fill", name: "Cloudiness", value: "\(weather.clouds.all)" + "%")

                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.bottom, 20)
                .foregroundColor(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                .background(Color.white)
                .cornerRadius(20, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                // Apply the drag gesture
                .offset(y: startingOffsetY + currentDragOffsetY + endingOffsetY) // Combine offsets
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.spring()) {
                                currentDragOffsetY = value.translation.height
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
                            }
                        }
                )
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
