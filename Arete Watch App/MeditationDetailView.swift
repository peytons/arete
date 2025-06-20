import SwiftUI

struct MeditationDetailView<Store: HealthDataProviding>: View {
    @ObservedObject var healthStore: Store
    @State private var showSession      = false
    @State private var selectedDuration = 1
    @State private var useHRMode        = false
    @State private var showCustomPicker = false
    
    let presetDurations = [1, 2, 5, 10, 30]
    let customRange     = Array(1...60)
    
    var body: some View {
        VStack(spacing: 12) {
            ScrollView(.vertical) {
                VStack(spacing: 12) {
                    
                    Text("Meditation")
                        .font(.headline)
                    
                    Text("Past week: \(healthStore.meditationDays) days")
                    
                    // Preset durations
                    Picker("Duration", selection: $selectedDuration) {
                        ForEach(presetDurations, id: \.self) {
                            Text("\($0) min").tag($0)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    // Custom duration
                    Button("Custom… (\(selectedDuration) min)") {
                        showCustomPicker = true
                    }
                    .sheet(isPresented: $showCustomPicker) {
                        VStack {
                            Picker("Minutes", selection: $selectedDuration) {
                                ForEach(customRange, id: \.self) {
                                    Text("\($0)").tag($0)
                                }
                            }
                            .labelsHidden()
                            Button("Done") { showCustomPicker = false }
                        }
                        .padding()
                    }
                    
                    // Heart-rate mode toggle
                    Toggle("End when HR stabilizes", isOn: $useHRMode)
                    
                    // Start button
                    Button("Start") {
                        showSession = true
                    }
                    .disabled(!useHRMode && selectedDuration == 0)
                    
                    Spacer()
                }
                .padding()
                Spacer(minLength: 10)
            }
            .padding()
        }
        .onAppear { healthStore.requestAuthorization() }
        .navigationDestination(isPresented: $showSession) {
            MeditationSessionView<Store>(
                healthStore: healthStore,
                durationMinutes: selectedDuration,
                useHeartRateMode: useHRMode,
                onComplete: {
                    healthStore.requestAuthorization()
                    showSession = false
                }
            )
        }
    }
}

#Preview {
    MeditationDetailView<MockHealthStore>(healthStore: MockHealthStore())
}

