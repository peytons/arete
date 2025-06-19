//
//  WorkoutDetailView.swift
//  Arete
//
//  Created by Peyton Sherwood on 6/19/25.
//


import SwiftUI

struct WorkoutDetailView: View {
    @ObservedObject var healthStore: HealthStore

    var body: some View {
        VStack {
            Text("Workouts")
                .font(.headline)

            Text("Past 7 Days")
                .font(.subheadline)

            Text("\(healthStore.workoutDays) days with workouts")
                .padding(.top)

            Spacer()
        }
        .padding()
    }
}
