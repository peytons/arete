import SwiftUI

struct MeditationDetailView: View {
    @ObservedObject var healthStore: HealthStore
    @State private var showSession = false
    @State private var selectedDuration: Int = 1

    let presetDurations = [1, 2, 5, 10, 30]

    var body: some View {
        VStack(spacing: 12) {
            Text("Meditation")
                .font(.headline)

            Text("Past week: \(healthStore.meditationDays) days")

            Picker("Duration", selection: $selectedDuration) {
                ForEach(presetDurations, id: \.self) { minutes in
                    Text("\(minutes) min").tag(minutes)
                }
            }
            .pickerStyle(.navigationLink)

            Button("Start") {
                showSession = true
            }

            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $showSession) {
            MeditationSessionView(durationMinutes: selectedDuration, onComplete: {
                healthStore.requestAuthorization()  // refresh after writing showSession = false
            })
        }
    }
}

#Preview {
    MeditationDetailPreview()
}

final class HealthStore: ObservableObject {
    @Published var meditationDays = 0
    @Published var workoutDays = 0
    @Published var sleepScore = 0

    private let store: HKHealthStore?
    private let isPreview: Bool

    init(preview: Bool = false) {
        self.isPreview = preview
        self.store = preview ? nil : HKHealthStore()

        if preview {
            meditationDays = 3
            workoutDays = 5
            sleepScore = 87
        }
    }

    func requestAuthorization() {
        guard !isPreview, let store else { return }
        // HealthKit auth logic here
    }

    // Other functions can also early-return if isPreview == true
}

private struct MeditationDetailPreview: View {
    var body: some View {
        MeditationDetailView(healthStore: MockHealthStore())
    }
}


