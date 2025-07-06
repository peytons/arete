//
//  SleepDetailView.swift
//  Arete
//
//  Created by Peyton Sherwood on 6/19/25.
//


import SwiftUI

struct SleepDetailView<Store: HealthDataProviding>: View {
    @ObservedObject var healthStore: Store

    var body: some View {
        VStack {
            Text("Sleep")
                .font(.headline)

            Text("7-Day Avg Score")
                .font(.subheadline)

            Text("\(healthStore.sleepScore)/100")
                .padding(.top)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    SleepDetailView<MockHealthStore>(healthStore: MockHealthStore())
}
