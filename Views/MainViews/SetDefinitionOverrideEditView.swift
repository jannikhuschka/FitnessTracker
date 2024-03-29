import SwiftUI
import Combine

struct SetDefinitionOverrideEditView: View {
	@Binding var override: SetDefinitionOverride
	var overrideChain: ExerciseOverrideChain
	
	var body: some View {
		if let repBinding = override.repCount != nil ? Binding(get: { override.repCount! }, set: { override.repCount = $0 }) : nil {
				IntPickerView(description: "Repetitions", image: "repeat", value: repBinding, range: 1...30)
					.swipeActions(edge: .trailing, allowsFullSwipe: true) {
						Button("Remove", role: .destructive) {
							withAnimation {
								override.repCount = nil
							}
						}
					}
			} else {
				HStack {
					Button("Repetitions", systemImage: "plus.circle", action: {
						withAnimation {
							override.repCount = overrideChain.setDefinition.repCount
						}
					})
					Spacer()
					Text("\(overrideChain.levelFor(.repCount)): \(overrideChain.setDefinition.repCount)")
						.foregroundStyle(.gray)
				}
			}
			
			OptionalWeightStagePicker(weightStage: $override.weightStage, overrideChain: overrideChain)
			
			OptionalPauseBehaviourEditView(pause: $override.pause, overrideChain: overrideChain)
	}
}

#Preview {
	SetDefinitionOverrideEditView(override: .constant(.init(repCount: 0, weightStage: 5, pause: PauseBehaviour())), overrideChain: .init(root: .sample))
}
