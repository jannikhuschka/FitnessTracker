import Foundation

struct ExerciseParams: HashEqCod {
	var possibleWeights: PossibleWeights
	var setCount: Int
	var setDefinition: SetDefinition
}

extension ExerciseParams {
	public static var sample: ExerciseParams { .init(possibleWeights: .init(baseWeight: 0, weightStep: 5), setCount: 3, setDefinition: .init(repCount: 15, weightStage: 5, pause: .init())) }
}
