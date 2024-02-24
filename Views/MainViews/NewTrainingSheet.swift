import SwiftUI

struct NewTrainingSheet: View {
	@State private var newTraining = OldTraining.empty
	@Binding var trainings: [OldTraining]
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
	NewTrainingSheet(trainings: .constant(OldTraining.sampleData), isPresentingNewTrainingView: .constant(true))
}
