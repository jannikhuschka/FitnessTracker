import Foundation

struct OldExerciseParamsOverride: HashEqCod {
	var possibleWeights: OldPossibleWeights?
	var setCount: Int?
	var setDefinition: OldSetDefinitionOverride = .init()
}

extension OldExerciseParamsOverride {
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

extension OldExerciseParamsOverride {
	public static var empty: OldExerciseParamsOverride { .init(setDefinition: .init()) }
}
