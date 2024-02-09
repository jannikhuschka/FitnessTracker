import Foundation

struct Exercise: HashEqCod, Sendable {
	var name: String
	var sets: [Set] = []
	var subExercises: [Exercise] = []
	var isSuperset: Bool { !subExercises.isEmpty }
}

extension Exercise {
	static func fromDefinition(definition: ExerciseDefinition) -> Exercise {
		.init(name: definition.name)
	}
	
	public var totalMovedWeight: Double {
		if(isSuperset) {
			return subExercises.reduce(0, {tmp, ex in
				tmp + ex.totalMovedWeight
			})
		}
		return sets.reduce(0, {tmp, set in
			tmp + Double(set.reps) * set.weight
		})
	}
	
	var avgWeightPerSet: Double {
		if(isSuperset) { return 0 }
		return sets.reduce(0, { $0 + (Double($1.reps) * $1.weight) }) / Double(sets.count)
	}
	
	public func needsChanges(_ definition: ExerciseDefinition, overrides: ExerciseOverrideChain) -> Bool {
		if definition.isSimple {
			if (sets.indices.allSatisfy({ i in
				let setDef = definition.setDefinition(number: i, overrideChain: overrides)
				return sets[i].weight >= setDef.weight(possibleWeights: overrides.possibleWeights) && sets[i].reps >= setDef.repCount
			})) {
				return true
			}
		} else if definition.isSuperset {
			return subExercises.contains(where: {subEx in subEx.needsChanges(definition.supersetMembers!.first(where: { $0.name == subEx.name })!, overrides: overrides.with(definition.supersetMembers!.first(where: { $0.name == subEx.name })!.overrides)) })
		} else {
			return sets.indices.contains(where: { i in
				let setDef = definition.setDefinition(number: i, overrideChain: overrides)
				let setOverrides = overrides.withSet(definition.setDefinitions[i])
				return sets[i].weight >= setDef.weight(possibleWeights: setOverrides.possibleWeights) && sets[i].reps >= setDef.repCount
			})
		}
		return false
	}
}

extension [Exercise] {
	func fromDefinition(_ definition: ExerciseDefinition) -> Exercise? {
		first(where: {$0.name == definition.name})
	}
}

extension Exercise {
	public static var empty: Exercise {
		Exercise(name: "Emptyexercise")
	}
	
	public static var sample1: Exercise {
		var result = Exercise(name: "Brustpresse")
		result.sets = [.sample1, .sample2, .sample3]
		return result
	}
	public static var sample2: Exercise {
		var result = Exercise(name: "Butterfly")
		result.sets = [.sample2, .sample4, .sample5, .sample1, .sample3]
		return result
	}
	public static var sample3: Exercise {
		var result = Exercise(name: "Beinpresse")
		result.sets = [.sample3, .sample5]
		return result
	}
	public static var sample4: Exercise {
		var result = Exercise(name: "Klimmzüge")
		result.sets = [.sample5]
		return result
	}
	public static var sample5: Exercise {
		var result = Exercise(name: "Dips")
		result.sets = [.sample4, .sample3, .sample2, .sample4]
		return result
	}
}
