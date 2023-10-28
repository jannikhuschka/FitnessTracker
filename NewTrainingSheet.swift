import SwiftUI

struct NewTrainingSheet: View {
	@State private var newTraining = Training.empty
	@Binding var trainings: [Training]
	@Binding var isPresentingNewTrainingView: Bool
	@State var showAlert: Bool = false
	
	var body: some View {
		NavigationStack {
			TrainingEditView(training: $newTraining)
				.navigationTitle("Add Training")
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button("Dismiss") {
							isPresentingNewTrainingView = false
						}
					}
					ToolbarItem(placement: .confirmationAction) {
						Button("Add") {
							if(newTraining.validity != "OK") {
								showAlert = true
							} else {
								isPresentingNewTrainingView = false
								trainings.append(newTraining)
							}
						}
						.alert("Invalid Training", isPresented: $showAlert, actions: {}) {
							Text(newTraining.validity)
						}
					}
				}
		}
	}
}

#Preview {
	NewTrainingSheet(trainings: .constant(Training.sampleData), isPresentingNewTrainingView: .constant(true))
}
