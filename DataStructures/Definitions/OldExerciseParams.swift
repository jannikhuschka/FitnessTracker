import Foundation

struct OldExerciseParams: HashEqCod {
	var possibleWeights: OldPossibleWeights
	var setCount: Int
	var setDefinition: OldSetDefinition
}

extension OldExerciseParams {
	public func toExerciseParams() -> ExerciseParams {
		.init(possibleWeights: possibleWeights.toPossibleWeights(), setCount: setCount, setDefinition: setDefinition.toSetDefinition())
	}
}

extension OldExerciseParams {
	public static var sample: OldExerciseParams { .init(possibleWeights: .init(baseWeight: 0, weightStep: 5), setCount: 3, setDefinition: .init(repCount: 15, weightStage: 5, pause: .init())) }
}
