import SwiftUI
import Combine

struct SetDefinitionEditView: View {
	@Binding var definition: SetDefinition
	var possibleWeights: PossibleWeights
	
	var body: some View {
		IntPickerView(description: "Repetitions", image: "repeat", value: $definition.repCount, range: 1...30)
		
		WeightStagePicker(weightStage: $definition.weightStage, possibleWeights: possibleWeights)
		
		PauseBehaviourEditView(pause: $definition.pause)
	}
}

#Preview {
	SetDefinitionEditView(definition: .constant(.init(repCount: 0, weightStage: 5, pause: PauseBehaviour())), possibleWeights: .sample1)
}
