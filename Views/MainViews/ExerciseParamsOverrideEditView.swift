import SwiftUI

struct ExerciseParamsOverrideEditView: View {
	@Binding var override: OldExerciseParamsOverride
	@Binding var exercise: OldExerciseDefinition
	var overrideChain: OldExerciseOverrideChain
	
	var body: some View {
		Form {
			Section(header: Text("Possible Weights")) {
				OptionalPossibleWeightsEditView(possibleWeights: $override.possibleWeights, overrideChain: overrideChain)
			}
			
			Section(header: Text("Set Count")) {
				if(exercise.isSimple || exercise.isSuperset) {
					if let setCountBinding = override.setCount != nil ? Binding(get: { override.setCount! }, set: { override.setCount = $0 }) : nil {
						IntPickerView(description: "Sets", image: "list.bullet.indent", value: setCountBinding, range: 1...10)
							.swipeActions(edge: .trailing, allowsFullSwipe: true) {
								Button("Remove", role: .destructive) {
									override.setCount = nil
								}
							}
					} else {
						HStack {
							Button("Sets", systemImage: "plus.circle") {
								override.setCount = overrideChain.setCount
							}
							Spacer()
							Text("\(overrideChain.levelFor(.setCount)): \(overrideChain.setCount)")
								.foregroundStyle(.gray)
						}
					}
				} else {
					Button("Remove Individual Sets", systemImage: "arrow.counterclockwise") {
						exercise.setDefinitions = []
						override.setCount = overrideChain.setCount
					}
				}
			}
			Section(header: Text("Set Targets")) {
				SetDefinitionOverrideEditView(override: $override.setDefinition, overrideChain: overrideChain)
			}
		}
	}
}

#Preview {
	ExerciseParamsOverrideEditView(override: .constant(.empty), exercise: .constant(.empty), overrideChain: .sample)
}
