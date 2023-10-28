import SwiftUI

struct TrainingEditView: View {
	@Binding var training: Training
	@State private var newExerciseName = ""
	@State var isPresentingNewExerciseView: Bool = false
	
	var body: some View {
		Form {
			Section(header: Text("Training Info")) {
				HStack {
					Label("Name", systemImage: "character.cursor.ibeam")
					TextField("Name", text: $training.name)
						.multilineTextAlignment(.trailing)
						.foregroundStyle(.blue)
				}
				NavigationLink(destination: ExerciseParamsEditView(params: $training.defaults).navigationTitle("Defaults")) {
					Label("Defaults", systemImage: "scope")
				}
			}
			
			Section(header: Text("Exercises")) {
				List {
					ForEach($training.exercises.indices, id: \.self) { i in
						NavigationLink(destination: ExerciseEditView(exercise: $training.exercises[i], overrideChain: .init(root: training.defaults))) {
							HStack {
								Text(training.exercises[i].name)
								Spacer()
								ValueDescriptionBelow(description: "Sets", value: "\(ExerciseOverrideChain(root: training.defaults, overrides: [training.exercises[i].overrides]).setCount.formatted(.number))", alignment: .center, descFont: .caption2, valFont: .body)
//									.frame(width: 45)
//								ValueDescriptionBelow(description: "Reps", value: "\(training.exercises[i].defaultSetDefinition.target.repCount.formatted(.number))", alignment: .center, descFont: .caption2, valFont: .body)
//									.frame(width: 45)
//								ValueDescriptionBelow(description: "kg", value: "\(training.exercises[i].defaultSetDefinition.targetWeight.formatted(.number))", alignment: .center, descFont: .caption2, valFont: .body)
//									.frame(width: 45)
							}
							.padding(2)
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
						.tint(.blue)
					}
					
//					HStack {
//						TextField("New Exercise", text: $newExerciseName)
//						Button(action: {
//							withAnimation {
//								let exercise = ExerciseDefinition.forTraining(training: training, name: newExerciseName)
//								training.exercises.append(exercise)
//								newExerciseName = ""
//							}
//						}) {
//							Image(systemName: "plus.circle")
//						}
//						.disabled(newExerciseName.isEmpty)
//						Button(action: {
//							withAnimation {
//								let exercise = ExerciseDefinition.forTraining(training: training, name: newExerciseName)
//								training.exercises.append(exercise)
//								newExerciseName = ""
//							}
//						}) {
//							Image(systemName: "plus.circle.fill")
//						}
//						.disabled(newExerciseName.isEmpty)
//					}
//					.padding(.horizontal, 2)
//					.padding(.vertical, 8)
					
					HStack {
						Button(action: {
							isPresentingNewExerciseView = true
						}) {
							Label("Add Exercise", systemImage: "plus.circle")
						}
					}
				}
			}
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
