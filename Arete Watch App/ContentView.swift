import SwiftUI

struct ContentView: View {
    #if targetEnvironment(simulator)
    typealias ActiveHealthStore = MockHealthStore
    @StateObject private var healthStore = MockHealthStore()
    #else
    typealias ActiveHealthStore = HealthStore
    @StateObject private var healthStore = HealthStore()
    #endif
    

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    MeditationDetailView<ActiveHealthStore>(healthStore: healthStore)
                } label: {
                    MetricRow(label: "Meditated", value: "\(healthStore.meditationDays)/7")
                }

                NavigationLink {
                    WorkoutDetailView<ActiveHealthStore>(healthStore: healthStore)
                } label: {
                    MetricRow(label: "Worked Out", value: "\(healthStore.workoutDays)/7")
                }

                NavigationLink {
                    SleepDetailView<ActiveHealthStore>(healthStore: healthStore)
                } label: {
                    MetricRow(label: "Sleep Score", value: "\(healthStore.sleepScore)/100")
                }
            }
            .navigationTitle("Areté")
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
