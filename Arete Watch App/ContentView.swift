import SwiftUI

struct ContentView: View {
    @StateObject private var healthStore = HealthStore()

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    MeditationDetailView(healthStore: healthStore)
                } label: {
                    MetricRow(label: "Meditated", value: "\(healthStore.meditationDays)/7")
                }

                NavigationLink {
                    WorkoutDetailView(healthStore: healthStore)
                } label: {
                    MetricRow(label: "Worked Out", value: "\(healthStore.workoutDays)/7")
                }

                NavigationLink {
                    SleepDetailView(healthStore: healthStore)
                } label: {
                    MetricRow(label: "Sleep Score", value: "\(healthStore.sleepScore)/100")
                }
            }
            .navigationTitle("Arete")
            .onAppear {
                healthStore.requestAuthorization()
            }
        }
    }
}

struct MetricRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
        }
    }
}

#Preview {
    ContentView()
}
