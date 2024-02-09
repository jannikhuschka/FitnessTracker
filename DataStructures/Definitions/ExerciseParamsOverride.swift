import Foundation

struct ExerciseParamsOverride: HashEqCod {
	var possibleWeights: PossibleWeights?
	var setCount: Int?
	var setDefinition: SetDefinitionOverride = .init()
}

extension ExerciseParamsOverride {
	var overrideCount: Int {
//		(possibleWeights != nil ? 1 : 0) +
//		(setCount != nil 1 : 0) +
//		(setDefinition.repCount != nil ? 1 : 0) +
//		(setDefinition.weightStage != nil ? 1 : 0) +
//		(setDefinition.pause != nil ? 1 : 0)
		let arr: [Any?] = [possibleWeights, setCount, setDefinition.repCount, setDefinition.weightStage, setDefinition.pause]
		return arr.reduce(0, { $0 + ($1 != nil ? 1 : 0) })
	}
}

extension ExerciseParamsOverride {
	public static var empty: ExerciseParamsOverride { .init(setDefinition: .init()) }
}
