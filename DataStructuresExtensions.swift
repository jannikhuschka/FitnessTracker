import Foundation

extension Training {
	public var totalSets: Int {
		exercises.reduce(0, { result, exercise in
			return result + exercise.setCount(overrideChain: .init(root: defaults, overrides: [exercise.overrides]))
		})
	}
	
	public var lastTrainedDate: Date {
		sessions.last?.date ?? .distantPast
	}
	
	public var totalMovedWeight: Double {
		sessions.reduce(0, {tmp, session in
			tmp + session.totalMovedWeight
		})
	}
	
	public var validity: String {
		if(name.isEmpty) { return "Please enter a name for the training." }
		if(exercises.isEmpty) { return "Please add at least one exercise to the training." }
		return "OK"
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

extension ExerciseOverrideChain {
	func with(_ override: ExerciseParamsOverride?) -> ExerciseOverrideChain {
		var result = ExerciseOverrideChain(root: self.root, overrides: self.overrides)
		if let override {
			result.overrides.append(override)
		}
		return result
	}
	
	func withSet(_ set: SetDefinitionOverride) -> ExerciseOverrideChain {
		var result = ExerciseOverrideChain(root: self.root, overrides: self.overrides)
		result.overrides.append(.init(setDefinition: set))
		return result
	}
}

extension ExerciseDefinition {
	static func forTraining(training: Training, name: String, isSuperset: Bool = false) -> ExerciseDefinition {
		let defaults = training.defaults
		return .init(name: name, baseWeight: defaults.possibleWeights.baseWeight, weightStep: defaults.possibleWeights.weightStep, setCount: 3, repCount: defaults.setDefinition.repCount, weightStage: defaults.setDefinition.weightStage)
	}
	
	func setDefinition(number: Int, overrideChain: ExerciseOverrideChain) -> SetDefinition {
		if(isSimple || number >= setCount(overrideChain: overrideChain)) { return overrideChain.setDefinition }
		return overrideChain.withSet(setDefinitions[number]).setDefinition
	}
	
	func isCompletedBy(_ exercise: Exercise?, overrideChain: ExerciseOverrideChain) -> Bool {
		guard let exercise else { return false }
		if(isSimple) {
			return setCount(overrideChain: overrideChain) <= exercise.sets.count
		}
		if(isSuperset) {
			return supersetMembers.allSatisfy( { member in
				member.isCompletedBy(exercise.subExercises.first(where: { $0.name == member.name }), overrideChain: overrideChain.with(member.overrides))
			})
		}
		return setDefinitions.count <= exercise.sets.count
	}
}

extension [ExerciseDefinition] {
	func completedBy(_ exercises: [Exercise], overrideChain: ExerciseOverrideChain) -> [ExerciseDefinition] {
		return self.filter({ def in
			def.isCompletedBy(exercises.first(where: { $0.name == def.name }), overrideChain: overrideChain.with(def.overrides)) })
	}
	
	func notCompletedBy(_ exercises: [Exercise], overrideChain: ExerciseOverrideChain) -> [ExerciseDefinition] {
		return self.filter({ def in
			!def.isCompletedBy(exercises.first(where: { $0.name == def.name }), overrideChain: overrideChain.with(def.overrides)) })
	}
}

extension SetDefinition {
	func weight(possibleWeights: PossibleWeights) -> Double {
		possibleWeights.baseWeight + Double(weightStage) * possibleWeights.weightStep
	}
}

extension SetDefinitionOverride {
	func weight(possibleWeights: PossibleWeights) -> Double {
		possibleWeights.baseWeight + Double(weightStage ?? 187) * possibleWeights.weightStep
	}
}

extension TrainingSession {
	public var totalMovedWeight: Double {
		exercises.reduce(0, {tmp, ex in
			tmp + ex.totalMovedWeight
		})
	}
}

extension Exercise {
	static func fromDefinition(definition: ExerciseDefinition) -> Exercise {
		.init(name: definition.name)
	}
	
	public var totalMovedWeight: Double {
		sets.reduce(0, {tmp, set in
			tmp + Double(set.reps) * set.weight
		})
	}
	
	public func completedTarget(_ definition: ExerciseDefinition) -> Bool {
		if (sets.indices.allSatisfy({ i in
			false
//			sets[i].reps == definition.setDefinitions[i].repCount && sets[i].weight == definition.setDefinitions[i].weight(possibleWeights: definition.overrides?.possibleWeights ?? .init(baseWeight: 0, weightStep: 5))
		})) {
			return true
		}
		return false
	}
}

extension PauseMode {
	var shortened: String {
		switch(self) {
		case .fixedPauseDuration: return "Pause"
		case .fixedSetDuration: return "Set"
		case .infinitePause: return "Infinite"
		}
	}
}
