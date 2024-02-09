import SwiftUI

struct TrainingsView: View {
	@Binding var trainings: [Training]
	@Environment(\.scenePhase) private var scenePhase
	@State private var isPresentingNewTrainingView = false
//	@State var comparator: any TrainingComparator = TrainingDateComparator()
	let saveAction: ()->Void
	
	var body: some View {
		NavigationStack {
			List {
				ForEach($trainings) { $training in
					NavigationLink(destination: TrainingDetailView(training: $training)) {
						TrainingListItem(training: $training)
					}
				}
				.onDelete { indices in
					trainings.remove(atOffsets: indices)
				}
			}
//			Button("Add Standard") {
//				trainings.append(Training.standard)
//			}
			.navigationTitle("Trainings")
			.toolbar {
				ToolbarItem {
					Button(action: {
						isPresentingNewTrainingView = true
					}) {
						Image(systemName: "plus")
					}
				}
//				.accessibilityLabel("New Training")
				
//				ToolbarItem {
//					Picker("", selection: .constant(0)) {
//						Label("AMK", systemImage: "clock")
//						ForEach(TrainingComparator.all) { comp in
//							Label(comp.description, systemImage: comp.representingSymbol)
//						}
//					}
//				}
			}
		}
		.sheet(isPresented: $isPresentingNewTrainingView) {
			NewTrainingSheet(trainings: $trainings, isPresentingNewTrainingView: $isPresentingNewTrainingView)
		}
		.onChange(of: scenePhase) { oldPhase, newPhase in
			if newPhase == .inactive { saveAction() }
		}
	}
}


#Preview {
	TrainingsView(trainings: .constant(Training.sampleData), saveAction: {})
}
