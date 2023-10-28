import SwiftUI
import Combine

struct SetDefinitionOverrideEditView: View {
	@Binding var override: SetDefinitionOverride
	var overrideChain: ExerciseOverrideChain
	
	var body: some View {
			if let repBinding = Binding<Int>($override.repCount) {
				IntPickerView(description: "Repetitions", image: "repeat", value: repBinding, range: 1...30)
					.swipeActions(edge: .trailing, allowsFullSwipe: true) {
						Button("Remove Rep Override", role: .destructive) {
							withAnimation {
								override.repCount = nil
							}
						}
					}
			} else {
				Button("Add Rep Override", systemImage: "plus.circle", action: {
					withAnimation {
						override.repCount = overrideChain.setDefinition.repCount
					}
				})
			}
			
			OptionalWeightStagePicker(weightStage: $override.weightStage, overrideChain: overrideChain)
			
			OptionalPauseBehaviourEditView(pause: $override.pause, overrideChain: overrideChain)
	}
}

#Preview {
	SetDefinitionOverrideEditView(override: .constant(.init(repCount: 0, weightStage: 5, pause: PauseBehaviour())), overrideChain: .init(root: .sample))
}
