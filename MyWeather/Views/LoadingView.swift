//
//  LoadingView.swift
//  MyWeather
//
//  Created by Rock on 15/9/2024.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .frame(maxWidth:.infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView()
}
