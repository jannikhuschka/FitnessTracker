import Foundation

struct ExerciseParamsUpdate: Hashable, Equatable {
	static func == (lhs: ExerciseParamsUpdate, rhs: ExerciseParamsUpdate) -> Bool {
		lhs.exerciseDefinition == rhs.exerciseDefinition
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(exerciseDefinition)
	}
	
	var exerciseDefinition: ExerciseDefinition
	var exercise: Exercise
	var overrideChain: ExerciseOverrideChain
	var proposedChanges: [any ExerciseParamsChangeAction] = []
	
	init(exerciseDefinition: ExerciseDefinition, exercise: Exercise, overrideChain: ExerciseOverrideChain) {
		self.exerciseDefinition = exerciseDefinition
		self.exercise = exercise
		self.overrideChain = overrideChain
		self.proposedChanges = self.getChanges()
	}
	
	static func neededFor(exerciseDefinition: ExerciseDefinition, exercise: Exercise, overrideChain: ExerciseOverrideChain) -> ExerciseParamsUpdate? {
		if !exercise.needsChanges(exerciseDefinition, overrides: overrideChain) { return nil }
		return .init(exerciseDefinition: exerciseDefinition, exercise: exercise, overrideChain: overrideChain)
	}
}

extension ExerciseParamsUpdate {
	func getChanges() -> [any ExerciseParamsChangeAction] {
		var result: [any ExerciseParamsChangeAction] = []
		
		if exerciseDefinition.isSimple {
			result.append(IncreaseWeightAction(valueBefore: overrideChain.setDefinition.weight(possibleWeights: overrideChain.possibleWeights), valueAfter: exercise.sets.map({ $0.weight }).min()! + overrideChain.possibleWeights.weightStep))
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
	
	func getChanges(subExerciseName: String) -> [any ExerciseParamsChangeAction] {
		var result: [any ExerciseParamsChangeAction] = []
		
		let subDef = exerciseDefinition.supersetMembers!.first(where: { $0.name == subExerciseName })!
		let subOverrides = overrideChain.with(subDef.overrides)
		let subEx = exercise.subExercises.first(where: { $0.name == subExerciseName })!
		if subDef.isSimple {
			result.append(IncreaseWeightAction(subExercise: subExerciseName, valueBefore: subOverrides.setDefinition.weight(possibleWeights: subOverrides.possibleWeights), valueAfter: subEx.sets.map({ $0.weight }).min()! + overrideChain.possibleWeights.weightStep))
		} else {
			for i in 0..<subEx.sets.count {
				result.append(getChanges(subExerciseName: subExerciseName, setNumber: i))
			}
		}
		
		return result
	}
	
	func getChanges(setNumber: Int) -> any ExerciseParamsChangeAction {
		let set = exercise.sets[setNumber]
		return IncreaseWeightAction(setNumber: setNumber, valueBefore: overrideChain.setDefinition.weight(possibleWeights: overrideChain.possibleWeights), valueAfter: set.weight + overrideChain.possibleWeights.weightStep)
	}
	
	func getChanges(subExerciseName: String, setNumber: Int) -> any ExerciseParamsChangeAction {
		let subDef = exerciseDefinition.supersetMembers!.first(where: { $0.name == subExerciseName })!
		let subOverrides = overrideChain.with(subDef.overrides)
		let subEx = exercise.subExercises.first(where: { $0.name == subExerciseName })!
		let set = subEx.sets[setNumber]
		return IncreaseWeightAction(subExercise: subExerciseName, setNumber: setNumber, valueBefore: subOverrides.setDefinition.weight(possibleWeights: subOverrides.possibleWeights), valueAfter: set.weight + overrideChain.possibleWeights.weightStep)
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
