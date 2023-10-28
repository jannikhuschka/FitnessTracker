import WidgetKit
import AppIntents

struct TrainingPlayPause: LiveActivityIntent {
	static var title: LocalizedStringResource = "Training Play / Pause"
	static var description = IntentDescription("Pauses or resumes the training.")
	
	func perform() async throws -> some IntentResult {
		await FitnessStopwatch.Instance.startPause()
		await FitnessStopwatch.Instance.updateActivity()
		return .result()
	}
}

struct SubmitRepetitions: LiveActivityIntent {
	@Parameter(title: "Repetitions")
	var repetitions: Int
	
	static var title: LocalizedStringResource = "Training Play / Pause"
	static var description = IntentDescription("Pauses or resumes the training.")
	
	func perform() async throws -> some IntentResult {
		await FitnessStopwatch.Instance.submitRepetitions(repetitions: repetitions)
		await FitnessStopwatch.Instance.updateActivity()
		return .result()
	}
}

struct SwapExercise: LiveActivityIntent {
	@Parameter(title: "Exercise")
	var exerciseName: String
	
	static var title: LocalizedStringResource = "Training Play / Pause"
	static var description = IntentDescription("Pauses or resumes the training.")
	
	func perform() async throws -> some IntentResult {
		await FitnessStopwatch.Instance.swapExercise(exerciseName: exerciseName)
		await FitnessStopwatch.Instance.updateActivity()
		return .result()
	}
}

struct IncreaseWeight: LiveActivityIntent {
	static var title: LocalizedStringResource = "Increase weight"
	static var description = IntentDescription("Increase this leg's weight.")
	
	func perform() async throws -> some IntentResult {
		await FitnessStopwatch.Instance.increaseWeight()
		await FitnessStopwatch.Instance.updateActivity()
		return .result()
	}
}

struct DecreaseWeight: LiveActivityIntent {
	static var title: LocalizedStringResource = "Decrease weight"
	static var description = IntentDescription("Decrease this leg's weight.")
	
	func perform() async throws -> some IntentResult {
		await FitnessStopwatch.Instance.decreaseWeight()
		await FitnessStopwatch.Instance.updateActivity()
		return .result()
	}
}

struct LengthenPause: LiveActivityIntent {
	static var title: LocalizedStringResource = "Training Play / Pause"
	static var description = IntentDescription("Pauses or resumes the training.")
	
	func perform() async throws -> some IntentResult {
		await FitnessStopwatch.Instance.lengthenPause()
		await FitnessStopwatch.Instance.updateActivity()
		return .result()
	}
}

struct ShortenPause: LiveActivityIntent {
	static var title: LocalizedStringResource = "Training Play / Pause"
	static var description = IntentDescription("Pauses or resumes the training.")
	
	func perform() async throws -> some IntentResult {
		await FitnessStopwatch.Instance.shortenPause()
		await FitnessStopwatch.Instance.updateActivity()
		return .result()
	}
}

struct IncreaseLiveActivityUpcomingOffset: LiveActivityIntent {
	static var title: LocalizedStringResource = "Training Play / Pause"
	static var description = IntentDescription("Pauses or resumes the training.")
	
	func perform() async throws -> some IntentResult {
		await FitnessStopwatch.Instance.increaseLiveActivityUpcomingOffset(2)
		await FitnessStopwatch.Instance.updateActivity()
		return .result()
	}
}

struct DecreaseLiveActivityUpcomingOffset: LiveActivityIntent {
	static var title: LocalizedStringResource = "Training Play / Pause"
	static var description = IntentDescription("Pauses or resumes the training.")
	
	func perform() async throws -> some IntentResult {
		await FitnessStopwatch.Instance.decreaseLiveActivityUpcomingOffset(2)
		await FitnessStopwatch.Instance.updateActivity()
		return .result()
	}
}



extension SubmitRepetitions {
	public static func fromInt(_ int: Int) -> SubmitRepetitions {
		let result = SubmitRepetitions()
		result.repetitions = int
		return result
	}
}

extension SwapExercise {
	public static func fromName(_ name: String) -> SwapExercise {
		let result = SwapExercise()
		result.exerciseName = name
		return result
	}
}
