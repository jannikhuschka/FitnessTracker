import Foundation
import SwiftData

@Model
class ExerciseParams {
	var possibleWeights: PossibleWeights
	var setCount: Int
	var setDefinition: SetDefinition
	
	init(possibleWeights: PossibleWeights, setCount: Int, setDefinition: SetDefinition) {
		self.possibleWeights = possibleWeights
		self.setCount = setCount
		self.setDefinition = setDefinition
	}
}

extension ExerciseParams {
	public static var sample: ExerciseParams { .init(possibleWeights: .init(baseWeight: 0, weightStep: 5), setCount: 3, setDefinition: .init(repCount: 15, weightStage: 5, pause: .init())) }
}
