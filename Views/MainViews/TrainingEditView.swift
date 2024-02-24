import SwiftUI

struct TrainingEditView: View {
	@Binding var training: OldTraining
	@State private var newExerciseName = ""
	@State var isPresentingNewExerciseView: Bool = false
	
	var body: some View {
		Form {
			Section(header: Text("Training Info")) {
				HStack {
					Label("Name", systemImage: "character.cursor.ibeam")
					TextField("Name", text: $training.name)
						.multilineTextAlignment(.trailing)
						.foregroundStyle(Color.accentColor)
				}
				NavigationLink(destination: ExerciseParamsEditView(params: $training.defaults).navigationTitle("Defaults")) {
					Label("Defaults", systemImage: "scope")
				}
			}
			
			Section(header: Text("Exercises")) {
				List {
					ForEach($training.exercises.indices, id: \.self) { i in
						NavigationLink(destination: ExerciseEditView(exercise: $training.exercises[i], overrideChain: .init(root: training.defaults))) {
							ExerciseListItem(exercise: training.exercises[i], overrideChain: OldExerciseOverrideChain(root: training.defaults))
						}
					}
					.onDelete { indices in
						training.exercises.remove(atOffsets: indices)
					}
					.onMove { indices, newOffset in
						training.exercises.move(fromOffsets: indices, toOffset: newOffset)
					}
					.swipeActions(edge: .leading) {
						Button("Shit") {
							
						}
						.tint(Color.accentColor)
					}
					
					HStack {
						Button(action: {
							isPresentingNewExerciseView = true
						}) {
							Label("Add Exercise", systemImage: "plus.circle")
						}
					}
				}
			}
			.headerProminence(.increased)
			//			.environment(\.editMode, Binding.constant(EditMode.active))
		}
		.sheet(isPresented: $isPresentingNewExerciseView) {
			NewExerciseView(exerciseArray: $training.exercises, isPresentingNewExerciseView: $isPresentingNewExerciseView, overrideChain: .init(root: training.defaults))
		}
	}
}

#Preview {
	TrainingEditView(training: .constant(.sample1))
}
