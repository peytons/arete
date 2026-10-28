//
//  WorkoutDetailView.swift
//  Arete
//
//  Created by Peyton Sherwood on 6/19/25.
//


import SwiftUI

struct WorkoutDetailView<Store: HealthDataProviding>: View {
    @ObservedObject var healthStore: Store

    var body: some View {
        VStack {
            Text("Workouts")
                .font(.headline)

            Text("Past 7 Days")
                .font(.subheadline)

            Text("\(healthStore.workoutDays) days with workouts") // \(healthStore.workoutDays)
                .padding(.top)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    WorkoutDetailView(healthStore: MockHealthStore())
}
