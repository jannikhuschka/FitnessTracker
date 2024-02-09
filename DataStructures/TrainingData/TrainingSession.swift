import Foundation

struct TrainingSession : HashEqCod {
	var trainingName: String
	var number: Int
	var date: Date
	var duration: Duration?
	var exercises: [Exercise]
	
	init(training: Training) {
		self.trainingName = training.name
		self.number = training.sessions.count + 1
		self.date = Date()
		self.exercises = []
	}
}

extension TrainingSession {
	func isCompatibleTo(_ definition: ExerciseDefinition) -> Bool {
		guard let exercise = exercises.fromDefinition(definition) else { return false }
		return exercise.sets.count == definition.setDefinitions.count
	}
	
	func isCompatibleToAndDoesntDivertFrom(_ definition: ExerciseDefinition) -> Bool {
//		if(!isCompatibleTo(definition)) { return false }
//		let exercise = exercises.fromDefinition(definition)!
//		let avgWeight = exercise.sets.reduce(0, {tmp, new in
//			tmp + new.weight
//		}) / Double(exercise.sets.count)
//		return abs((definition.params?.setDefinition.weight(possibleWeights: definition.params?.possibleWeights ?? .init(baseWeight: 0, weightStep: 5)) ?? 187) - avgWeight) < (definition.params?.possibleWeights.weightStep ?? 5)
		return false
	}
	
	public static var empty: TrainingSession {
		.init(training: .empty)
	}
	
	func getExerciseFrom(_ definition: ExerciseDefinition) -> Exercise? {
		exercises.first(where: { $0.name == definition.name })
	}
	
	public var totalMovedWeight: Double {
		exercises.reduce(0, {tmp, ex in
			tmp + ex.totalMovedWeight
		})
	}
}

extension TrainingSession {
	public static var sample1: TrainingSession {
		var result = TrainingSession(training: .sample1)
		for i in 0...max(Training.sample1.exercises.count - 1, 0) {
			result.exercises.append(.fromDefinition(definition: Training.sample1.exercises[i]))
			result.exercises[i].sets.append(.sample1)
			result.exercises[i].sets.append(.sample2)
		}
		result.date = Date(timeIntervalSinceNow: -10000)
		result.duration = .seconds(3600)
		return result
	}
	public static var sample2: TrainingSession {
		var result = TrainingSession(training: .sample1)
		for i in 0...max(Training.sample1.exercises.count - 1, 0) {
			result.exercises.append(.fromDefinition(definition: Training.sample1.exercises[i]))
			result.exercises[i].sets.append(.sample3)
			result.exercises[i].sets.append(.sample2)
			result.exercises[i].sets.append(.sample3)
			result.exercises[i].sets.append(.sample4)
			result.exercises[i].sets.append(.sample1)
		}
		result.date = Date(timeIntervalSinceNow: -100000)
		result.duration = .seconds(7200)
		return result
	}
	public static var sample3: TrainingSession {
		var result = TrainingSession(training: .sample1)
		for i in 0...max(Training.sample1.exercises.count - 1, 0) {
			result.exercises.append(.fromDefinition(definition: Training.sample1.exercises[i]))
			result.exercises[i].sets.append(.sample5)
		}
		result.date = Date(timeIntervalSinceNow: 100000)
		result.duration = .seconds(187)
		return result
	}
	
	public static var sampleData: [TrainingSession] {
		[ .sample1, .sample2, .sample3 ]
	}
}
