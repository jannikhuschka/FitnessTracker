import SwiftUI
import Combine

struct SetDefinitionEditView: View {
	@Binding var definition: OldSetDefinition
	var possibleWeights: OldPossibleWeights
	
	var body: some View {
		IntPickerView(description: "Repetitions", image: "repeat", value: $definition.repCount, range: 1...30)
		
		WeightStagePicker(weightStage: $definition.weightStage, possibleWeights: possibleWeights)
		
		PauseBehaviourEditView(pause: $definition.pause)
	}
}

#Preview {
	SetDefinitionEditView(definition: .constant(.init(repCount: 0, weightStage: 5, pause: OldPauseBehaviour())), possibleWeights: .sample1)
}
