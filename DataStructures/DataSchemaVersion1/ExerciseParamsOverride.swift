import Foundation
import SwiftData

extension DataSchemaV1 {
	@Model
	class ExerciseParamsOverride {
		@Relationship var possibleWeights: PossibleWeights?
		var setCount: Int?
		@Relationship var setDefinition: SetDefinitionOverride
		
		init(possibleWeights: PossibleWeights? = nil, setCount: Int? = nil, setDefinition: SetDefinitionOverride = .init()) {
			self.possibleWeights = possibleWeights
			self.setCount = setCount
			self.setDefinition = setDefinition
		}
	}
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
