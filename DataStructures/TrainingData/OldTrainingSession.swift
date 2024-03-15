import Foundation

struct OldTrainingSession : HashEqCod {
	var trainingName: String
	var number: Int
	var date: Date
	var duration: Duration?
	var exercises: [OldExercise]
	
	init(training: OldTraining) {
		self.trainingName = training.name
		self.number = training.sessions.count + 1
		self.date = Date()
		self.exercises = []
	}
}

extension OldTrainingSession {
	func isCompatibleTo(_ definition: OldExerciseDefinition) -> Bool {
		guard let exercise = exercises.fromDefinition(definition) else { return false }
		return exercise.sets.count == definition.setDefinitions.count
	}
	
	func isCompatibleToAndDoesntDivertFrom(_ definition: OldExerciseDefinition) -> Bool {
//		if(!isCompatibleTo(definition)) { return false }
//		let exercise = exercises.fromDefinition(definition)!
//		let avgWeight = exercise.sets.reduce(0, {tmp, new in
//			tmp + new.weight
//		}) / Double(exercise.sets.count)
//		return abs((definition.params?.setDefinition.weight(possibleWeights: definition.params?.possibleWeights ?? .init(baseWeight: 0, weightStep: 5)) ?? 187) - avgWeight) < (definition.params?.possibleWeights.weightStep ?? 5)
		return false
	}
	
	public static var empty: OldTrainingSession {
		.init(training: .empty)
	}
	
	func getExerciseFrom(_ definition: OldExerciseDefinition) -> OldExercise? {
		exercises.first(where: { $0.name == definition.name })
	}
	
	public var totalMovedWeight: Double {
		exercises.reduce(0, {tmp, ex in
			tmp + ex.totalMovedWeight
		})
	}
	
	public func toTrainingSession() -> TrainingSession {
		.init(trainingName: trainingName, number: number, date: date, duration: duration, exercises: exercises.map({ $0.toExercise() }))
	}
}

extension OldTrainingSession {
	public static var sample1: OldTrainingSession {
		var result = OldTrainingSession(training: .sample1)
		for i in 0...max(OldTraining.sample1.exercises.count - 1, 0) {
			result.exercises.append(.fromDefinition(definition: OldTraining.sample1.exercises[i]))
			result.exercises[i].sets.append(.sample1)
			result.exercises[i].sets.append(.sample2)
		}
		result.date = Date(timeIntervalSinceNow: -10000)
		result.duration = .seconds(3600)
		return result
	}
	public static var sample2: OldTrainingSession {
		var result = OldTrainingSession(training: .sample1)
		for i in 0...max(OldTraining.sample1.exercises.count - 1, 0) {
			result.exercises.append(.fromDefinition(definition: OldTraining.sample1.exercises[i]))
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
	public static var sample3: OldTrainingSession {
		var result = OldTrainingSession(training: .sample1)
		for i in 0...max(OldTraining.sample1.exercises.count - 1, 0) {
			result.exercises.append(.fromDefinition(definition: OldTraining.sample1.exercises[i]))
			result.exercises[i].sets.append(.sample5)
		}
		result.date = Date(timeIntervalSinceNow: 100000)
		result.duration = .seconds(187)
		return result
	}
	
	public static var sampleData: [OldTrainingSession] {
		[ .sample1, .sample2, .sample3 ]
	}
}
