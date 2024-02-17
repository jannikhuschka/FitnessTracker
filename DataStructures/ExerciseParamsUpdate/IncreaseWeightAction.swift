import Foundation

struct IncreaseWeightAction: ExerciseParamsChangeAction, Hashable, Equatable {
	public var changeType: ExerciseParamsUpdateType = .increaseWeight
	public var subExercise: String? = nil
	public var setNumber: Int? = nil
	public var valueBefore: Double
	public var valueAfter: Double
	public var formattedValueBefore: String = ""
	public var formattedValueAfter: String = ""
	public var executed: Bool = false
	public func apply(_ exerciseDefinition: ExerciseDefinition) -> ExerciseDefinition {
		var changedDefinition = exerciseDefinition
		
		if let subExercise {
			let index = changedDefinition.supersetMembers!.firstIndex(where: { $0.name == subExercise })!
			var subDef = changedDefinition.supersetMembers![index]
			
			if let setNumber {
				subDef.setDefinitions[setNumber].weightStage = Int(valueAfter)
			} else {
				if subDef.overrides == nil { subDef.overrides = .empty }
				subDef.overrides!.setDefinition.weightStage = Int(valueAfter)
			}
			
			changedDefinition.supersetMembers![index] = subDef
			return changedDefinition
		}
		
		if let setNumber {
			changedDefinition.setDefinitions[setNumber].weightStage = Int(valueAfter)
			return changedDefinition
		}
		
		if changedDefinition.overrides == nil { changedDefinition.overrides = .empty }
		changedDefinition.overrides?.setDefinition.weightStage = Int(valueAfter)
		return changedDefinition
	}
	
	public func revert(_ exerciseDefinition: ExerciseDefinition) -> ExerciseDefinition {
		var changedDefinition = exerciseDefinition
		
		if let subExercise {
			let index = changedDefinition.supersetMembers!.firstIndex(where: { $0.name == subExercise })!
			var subDef = changedDefinition.supersetMembers![index]
			
			if let setNumber {
				subDef.setDefinitions[setNumber].weightStage = Int(valueBefore)
			} else {
				if subDef.overrides == nil { subDef.overrides = .empty }
				subDef.overrides!.setDefinition.weightStage = Int(valueBefore)
			}
			
			changedDefinition.supersetMembers![index] = subDef
			return changedDefinition
		}
		
		if let setNumber {
			changedDefinition.setDefinitions[setNumber].weightStage = Int(valueBefore)
			return changedDefinition
		}
		
		if changedDefinition.overrides == nil { changedDefinition.overrides = .empty }
		changedDefinition.overrides?.setDefinition.weightStage = Int(valueBefore)
		return changedDefinition
	}
}
