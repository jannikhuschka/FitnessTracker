import Foundation

struct OldExerciseParamsUpdate: Hashable, Equatable {
	static func == (lhs: OldExerciseParamsUpdate, rhs: OldExerciseParamsUpdate) -> Bool {
		lhs.exerciseDefinition == rhs.exerciseDefinition
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(exerciseDefinition)
	}
	
	var exerciseDefinition: OldExerciseDefinition
	var exercise: OldExercise
	var overrideChain: OldExerciseOverrideChain
	var proposedChanges: [any OldExerciseParamsChangeAction] = []
	
	init(exerciseDefinition: OldExerciseDefinition, exercise: OldExercise, overrideChain: OldExerciseOverrideChain) {
		self.exerciseDefinition = exerciseDefinition
		self.exercise = exercise
		self.overrideChain = overrideChain
		self.proposedChanges = self.getChanges()
	}
	
	static func neededFor(exerciseDefinition: OldExerciseDefinition, exercise: OldExercise, overrideChain: OldExerciseOverrideChain) -> OldExerciseParamsUpdate? {
		if !exercise.needsChanges(exerciseDefinition, overrides: overrideChain) { return nil }
		return .init(exerciseDefinition: exerciseDefinition, exercise: exercise, overrideChain: overrideChain)
	}
}

extension OldExerciseParamsUpdate {
	func getChanges() -> [any OldExerciseParamsChangeAction] {
		var result: [any OldExerciseParamsChangeAction] = []
		
		if exerciseDefinition.isSimple {
			result.append(OldIncreaseWeightAction(valueBefore: Double(overrideChain.setDefinition.weightStage), valueAfter: Double((exercise.sets.map({ $0.weight }).min()! - overrideChain.possibleWeights.baseWeight) / overrideChain.possibleWeights.weightStep + 1), formattedValueBefore: "\((overrideChain.setDefinition.weight(possibleWeights: overrideChain.possibleWeights)).formatted(.number)) kg", formattedValueAfter: "\((exercise.sets.map({ $0.weight }).min()! + overrideChain.possibleWeights.weightStep).formatted(.number)) kg"))
		} else if exerciseDefinition.isSuperset {
			for subEx in exercise.subExercises {
				result.append(contentsOf: getChanges(subExerciseName: subEx.name))
			}
		} else {
			for i in 0..<exercise.sets.count {
				result.append(getChanges(setNumber: i))
			}
		}
		
		return result
	}
	
	func getChanges(subExerciseName: String) -> [any OldExerciseParamsChangeAction] {
		var result: [any OldExerciseParamsChangeAction] = []
		
		let subDef = exerciseDefinition.supersetMembers!.first(where: { $0.name == subExerciseName })!
		let subOverrides = overrideChain.with(subDef.overrides)
		let subEx = exercise.subExercises.first(where: { $0.name == subExerciseName })!
		if subDef.isSimple {
			result.append(OldIncreaseWeightAction(subExercise: subExerciseName, valueBefore: subOverrides.setDefinition.weight(possibleWeights: subOverrides.possibleWeights), valueAfter: subEx.sets.map({ $0.weight }).min()! + overrideChain.possibleWeights.weightStep))
		} else {
			for i in 0..<subEx.sets.count {
				result.append(getChanges(subExerciseName: subExerciseName, setNumber: i))
			}
		}
		
		return result
	}
	
	func getChanges(setNumber: Int) -> any OldExerciseParamsChangeAction {
		let set = exercise.sets[setNumber]
		return OldIncreaseWeightAction(setNumber: setNumber, valueBefore: overrideChain.setDefinition.weight(possibleWeights: overrideChain.possibleWeights), valueAfter: set.weight + overrideChain.possibleWeights.weightStep)
	}
	
	func getChanges(subExerciseName: String, setNumber: Int) -> any OldExerciseParamsChangeAction {
		let subDef = exerciseDefinition.supersetMembers!.first(where: { $0.name == subExerciseName })!
		let subOverrides = overrideChain.with(subDef.overrides)
		let subEx = exercise.subExercises.first(where: { $0.name == subExerciseName })!
		let set = subEx.sets[setNumber]
		return OldIncreaseWeightAction(subExercise: subExerciseName, setNumber: setNumber, valueBefore: subOverrides.setDefinition.weight(possibleWeights: subOverrides.possibleWeights), valueAfter: set.weight + overrideChain.possibleWeights.weightStep)
	}
	
	func changesForSubExercise(atIndex: Int) -> [Int]? {
		let result = proposedChanges.indices.filter({ proposedChanges[$0].subExercise == exercise.subExercises[atIndex].name })
		return result.isEmpty ? nil : result
	}
	
	func hasChangeForSubExercise(index: Int) -> Bool {
		return proposedChanges.contains(where: { $0.subExercise! == exercise.subExercises[index].name })
	}
	
	public var changeAffectedIndices: [Int] {
		exercise.subExercises.indices.filter({ hasChangeForSubExercise(index: $0) })
	}
}
