import Foundation
import SwiftUI
import ActivityKit

@MainActor
final class FitnessStopwatch: ObservableObject {
	
	static let Instance = FitnessStopwatch()
	private var id: UUID = UUID()
	
	@Published var elapsedSeconds: Double = 0.0
	private var elapsedSecondsInt: Int = 0
	@Published var displayTime: Double = 0.0
	@Published var running = false
	@Published var pausePhase = false
	@Published var completed = false
	@Published var liveActivityUpdate: Bool = false
	
	@Published var currentSupersetDef: ExerciseDefinition?
	@Published var currentExDef: ExerciseDefinition = .empty
	@Published var currentSetDef: SetDefinition = .init(repCount: 15, weightStage: 5, pause: .init())
	@Published var currentSupersetExercise: Exercise?
	@Published var currentExercise: Exercise = .empty
	@Published var upcomingExercises: [ExerciseDefinition] = []
	@Published var postponedExercises: [Exercise] = []
	@Published var targetsReachedExercises: [ExerciseParamsUpdate] = []
	@Published var completedSets: Int = 0
	@Published var totalSets: Int = 0
	@Published var totalMovedWeight: Double = 0
	@Published var repsToBeat: Int = -1
	@Published var currentWeight: Double = 0
	
	public var training: Training = .empty
	public var liveActivity: Activity<FitnessWidgetAttributes>?
	private var liveActivityUpcomingOffset: Int = 0
	public var session: TrainingSession = .empty
	private var lastSession: TrainingSession?
	
	private var frequency: TimeInterval { 1.0 / 5.0 }
	@Published var startDate: Date?
	@Published var lastSetCompleteDate: Date = Date()
	@Published var totalPauseTime: TimeInterval = .zero
	@Published var pauseDate: Date?
	@Published var pauseMode: PauseMode = .fixedPauseDuration
	private var pauseModeDuration: Double { Double(currentSetDef.pause.duration) }
	@Published var endOfPauseDate: Date = Date()
	private var wakeScreenTask: Task<Void, Error> = Task { return }
	
	private weak var timer: Timer?
	
	func startPause() {
		if !running && startDate == nil { start() }
		else if !running {
			resume()
		} else {
			pause()
		}
		updateActivity()
	}
	
	func start() {
		if(training.exercises.isEmpty) {
			return
		}
		session = .init(training: training)
		lastSession = training.sessions.last
		totalSets = training.totalSets
		upcomingExercises = training.exercises
		
		lastSetCompleteDate = Date()
		fetchDefinitions()
		
		currentExercise = .fromDefinition(definition: currentExDef)
		currentSetDef = currentExDef.setDefinition(number: currentExercise.sets.count, overrideChain: completeOverrideChain)
		repsToBeat = currentSetDef.repCount
		currentWeight = currentSetDef.weight(possibleWeights: completeOverrideChain.possibleWeights)
//		repsToBeat = lastSession?.exercises.fromDefinition(currentExDef)?.sets[currentExercise.sets.count].reps ?? currentExDef.target.repCount
//		currentWeight = lastSession?.exercises.fromDefinition(currentExDef)?.sets[currentExercise.sets.count].weight ?? currentExDef.targetWeight
		lastSetCompleteDate = Date()
		pauseMode = currentSetDef.pause.mode
		
		startDate = Date()
//		timer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { [weak self] timer in
//			self?.update()
//		}
//		timer?.tolerance = 0.2
		running = true
		
		startActivity()
	}
	
	func pause() {
		running = false
		pauseDate = Date()
	}
	
	func resume() {
		running = true
		guard let pauseDate else { return }
		let pauseDuration = TimeInterval(Date().timeIntervalSince1970 - pauseDate.timeIntervalSince1970)
		totalPauseTime += pauseDuration
		endOfPauseDate += pauseDuration
	}
	
	func clear() {
		elapsedSeconds = 0.0
		elapsedSecondsInt = 0
		displayTime = 0.0
		running = false
		pausePhase = false
		completed = false
		
		currentExDef = .empty
		currentSupersetDef = nil
		currentExercise = .empty
		currentSupersetExercise = nil
		upcomingExercises = []
		postponedExercises = []
		targetsReachedExercises = []
		completedSets = 0
		totalSets = 0
		totalMovedWeight = 0
		repsToBeat = -1
		currentWeight = 0
		
		training = .empty
		session = .empty
		lastSession = nil
		
		startDate = nil
		lastSetCompleteDate = Date()
		totalPauseTime = .zero
		pauseDate = nil
		endOfPauseDate = Date()
		
//		liveActivity = nil
		liveActivityUpcomingOffset = 0
		
		timer?.invalidate()
		timer = nil
	}
	
	func submitRepetitions(repetitions: Int) {
		if(completed) { return }
		
		withAnimation {
			currentExercise.sets.append(.init(reps: repetitions, weight: currentWeight))
			if currentSupersetExercise != nil {
				if let i = currentSupersetExercise!.subExercises.firstIndex(where: { $0.name == currentExercise.name }) {
					currentSupersetExercise!.subExercises[i] = currentExercise
				} else {
					currentSupersetExercise!.subExercises.append(currentExercise)
				}
			}
			totalMovedWeight += Double(repetitions) * currentWeight
			nextSet()
//			update()
			
			resetWakeScreenTask()
		}
	}
	
	func nextSet() {
		completedSets += 1
		lastSetCompleteDate = Date()
		pauseMode = currentSetDef.pause.mode
		switch(pauseMode) {
		case .fixedPauseDuration:
			self.endOfPauseDate = Date() + self.pauseModeDuration
			self.pausePhase = true
		case .fixedSetDuration:
			self.endOfPauseDate = (self.pausePhase ? Date() : self.endOfPauseDate) + self.pauseModeDuration
			self.pausePhase = true
		case .infinitePause:
			self.endOfPauseDate = Date.distantFuture
			self.pausePhase = false
		}
		
		if(currentSupersetDef != nil && currentSupersetExercise != nil) {
			nextSupersetSet()
		}
		
		if(currentSupersetDef?.isCompletedBy(currentSupersetExercise, overrideChain: ExerciseOverrideChain(root: training.defaults, overrides: [currentSupersetDef?.overrides])) ?? currentExDef.isCompletedBy(currentExercise, overrideChain: completeOverrideChain)) {
			nextExercise()
		}
		
		currentSetDef = currentExDef.setDefinition(number: currentExercise.sets.count, overrideChain: completeOverrideChain)
		
		if(completed) { return }
		repsToBeat = currentSetDef.repCount
		getNewWeight()
	}
	
	func getNewWeight() {
		if currentExercise.sets.count == 0 || currentExDef.setDefinition(number: currentExercise.sets.count - 1, overrideChain: completeOverrideChain).weight(possibleWeights: completeOverrideChain.possibleWeights) == currentExercise.sets.last!.weight {
			currentWeight = currentSetDef.weight(possibleWeights: completeOverrideChain.possibleWeights)
		} else {
			currentWeight = currentExercise.sets.last!.weight
		}
	}
	
	func nextSupersetSet() {
		let notCompleted = currentSupersetDef!.supersetMembers!.notCompletedBy(currentSupersetExercise!.subExercises, overrideChain: supersetOverrideChain)
		currentExDef = notCompleted.first ?? currentExDef
		for exDef in currentSupersetDef!.supersetMembers! {
			guard let ex = currentSupersetExercise!.subExercises.first(where: { $0.name == exDef.name }) else { currentExDef = exDef; break }
			if(!exDef.isCompletedBy(ex, overrideChain: .init(root: training.defaults, overrides: [currentSupersetDef?.overrides, exDef.overrides])) && ex.sets.count < currentExercise.sets.count) { currentExDef = exDef; break }
		}
		currentExercise = currentSupersetExercise!.subExercises.first(where: { $0.name == currentExDef.name }) ?? .fromDefinition(definition: currentExDef)
	}
	
	func nextExercise() {
		session.exercises.append(currentSupersetExercise ?? currentExercise)
		let overrideChain = currentSupersetExercise != nil ? supersetOverrideChain : completeOverrideChain
		if let changes = ExerciseParamsUpdate.neededFor(exerciseDefinition: currentSupersetDef ?? currentExDef, exercise: currentSupersetExercise ?? currentExercise, overrideChain: overrideChain) {
			targetsReachedExercises.append(changes)
		}
//		if (currentSupersetExercise ?? currentExercise).completedTarget(currentSupersetDef ?? currentExDef, overrides: overrideChain) {
//			targetsReachedExercises.append(ExerciseParamsUpdate(type: .increaseWeight, exerciseDefinition: currentSupersetDef ?? currentExDef, exercise: currentSupersetExercise ?? currentExercise, overrideChain: overrideChain))
//		}
		currentSupersetDef = nil
		currentSupersetExercise = nil
		upcomingExercises.remove(at: 0)
		if(upcomingExercises.isEmpty) {
			finishSession()
			return
		}
		fetchDefinitions()
	}
	
	func fetchDefinitions() {
		currentExDef = upcomingExercises.first!
		if(currentExDef.isSuperset) {
			currentSupersetDef = currentExDef
//			currentExDef = currentSupersetDef!.supersetMembers.first!
		}
		getCurrentExercise()
	}
	
	func getCurrentExercise() {
		if let i = postponedExercises.firstIndex(where: { $0.name == currentSupersetDef?.name ?? currentExDef.name }) {
			currentExercise = postponedExercises.remove(at: i)
		} else {
			currentExercise = .fromDefinition(definition: currentSupersetDef ?? currentExDef)
		}
		
		if currentExercise.isSuperset || currentSupersetDef != nil {
			currentSupersetExercise = currentExercise
			currentExercise = currentSupersetExercise!.subExercises.max(by: { $0.sets.count < $1.sets.count }) ?? currentExercise
			nextSupersetSet()
		}
	}
	
	func finishSession() {
		pause()
		pausePhase = false
		displayTime = elapsedSeconds
		session.duration = .seconds(Date().timeIntervalSince1970 - startDate!.timeIntervalSince1970)
		completed = true
		stopActivity()
	}
	
	func swapExercise(exerciseName: String) {
		upcomingExercises.swapAt(0, upcomingExercises.firstIndex(where: { $0.name == exerciseName })!)
		saveCurrentExerciseAndLoadNext()
	}
	
	func setUpcomingExercises(_ upcoming: [ExerciseDefinition]) {
		upcomingExercises = upcoming
		if(upcoming.first?.name != currentExDef.name) {
			saveCurrentExerciseAndLoadNext()
		}
	}
	
	func saveCurrentExerciseAndLoadNext() {
		if(!(currentSupersetExercise?.subExercises.isEmpty ?? currentExercise.sets.isEmpty)) {
			postponedExercises.append(currentSupersetExercise ?? currentExercise)
			print(postponedExercises.count)
		}
		currentSupersetDef = nil
		currentSupersetExercise = nil
		fetchDefinitions()
		currentSetDef = currentExDef.setDefinition(number: currentExercise.sets.count, overrideChain: completeOverrideChain)
		repsToBeat = currentSetDef.repCount
		getNewWeight()
	}
	
	func endPausePhase() {
		pausePhase = false
		updateActivityWithAlert()
	}
	
	func resetWakeScreenTask() {
		wakeScreenTask.cancel()
//		DispatchQueue.main.asyncAfter(deadline: .now() + endOfPauseDate.timeIntervalSince1970 - Date().timeIntervalSince1970, execute: {
//			self.endPausePhase()
//		})
		wakeScreenTask = Task {
			print("Waking screen in \(endOfPauseDate.timeIntervalSince1970 - Date().timeIntervalSince1970) seconds")
//			try await Task.sleep(for: .seconds(endOfPauseDate.timeIntervalSince1970 - Date().timeIntervalSince1970))
//			try await Task.sleep(until: .now + .seconds(endOfPauseDate.timeIntervalSince1970 - Date().timeIntervalSince1970))
			let clock = ContinuousClock()
			let start = clock.now
			try await clock.sleep(for: .seconds(endOfPauseDate.timeIntervalSince1970 - Date().timeIntervalSince1970), tolerance: .zero)
			print("Woke screen after \(clock.now - start) seconds")
			endPausePhase()
		}
		Task {
			try await wakeScreenTask.value
		}
	}
	
//	nonisolated private func update() {
//		Task { @MainActor in
//			guard let startDate, running else { return }
//			withAnimation {
//				let date = Date()
//				elapsedSeconds = date.timeIntervalSince1970 - startDate.timeIntervalSince1970 - totalPauseTime
//
//				if(date > endOfPauseDate && pausePhase) {
//					pausePhase = false
//					updateActivityWithAlert()
//				}
//
//				switch(pauseMode) {
//				case .fixedPauseDuration, .fixedSetDuration:
//					displayTime = pausePhase ? (endOfPauseDate.timeIntervalSince1970 - date.timeIntervalSince1970) : (date.timeIntervalSince1970 - endOfPauseDate.timeIntervalSince1970)
//				case .infinitePause:
//					displayTime = date.timeIntervalSince1970 - lastSetCompleteDate.timeIntervalSince1970 - totalPauseTime
//				}
//			}
//			if(Int(elapsedSeconds.rounded(.down)) >= elapsedSecondsInt + 5) {
//				updateActivity()
//				elapsedSecondsInt = Int(elapsedSeconds)
//			}
//		}
//	}
	
	var completeOverrideChain: ExerciseOverrideChain {
		.init(root: training.defaults, overrides: [currentSupersetDef?.overrides, currentExDef.overrides])
	}
	
	var supersetOverrideChain: ExerciseOverrideChain {
		.init(root: training.defaults, overrides: [currentSupersetDef?.overrides])
	}
	
	var currentContentState: FitnessWidgetAttributes.ContentState {
		.init(stopwatchPaused: !running, pausePhase: pausePhase, date: endOfPauseDate, exercise: currentExercise, exDef: currentExDef, setDef: currentSetDef, nextDefinitions: Array(upcomingExercises.suffix(from: min(1, upcomingExercises.count))), overrideChain: completeOverrideChain, upcomingOffset: liveActivityUpcomingOffset, repsToBeat: repsToBeat, currentWeight: currentWeight, completedSets: completedSets)
	}
	
	func increaseWeight() {
		withAnimation {
			currentWeight += completeOverrideChain.possibleWeights.weightStep
		}
	}
	
	func decreaseWeight() {
		withAnimation {
			currentWeight -= completeOverrideChain.possibleWeights.weightStep
		}
	}
	
	func lengthenPause() {
		if(!pausePhase || pauseMode == .infinitePause) { return }
		endOfPauseDate += 30
//		update()
		resetWakeScreenTask()
	}
	
	func shortenPause() {
		if(!pausePhase || pauseMode == .infinitePause) { return }
		endOfPauseDate -= min(30, endOfPauseDate.timeIntervalSince1970 - Date().timeIntervalSince1970)
//		update()
		resetWakeScreenTask()
	}
	
	func increaseLiveActivityUpcomingOffset(_ inc: Int) {
		liveActivityUpcomingOffset += inc
	}
	
	func decreaseLiveActivityUpcomingOffset(_ dec: Int) {
		liveActivityUpcomingOffset -= dec
	}
	
	func startActivity() {
		let attributes = FitnessWidgetAttributes(totalSets: totalSets)
		
		liveActivity = try? Activity<FitnessWidgetAttributes>.request(attributes: attributes, content: .init(state: currentContentState, staleDate: .distantFuture), pushType: .none)
	}
	
	func updateActivity() {
		Task {
			await liveActivity?.update(.init(state: currentContentState, staleDate: .distantFuture))
		}
	}
	
	func updateActivityWithAlert() {
		Task {
			await liveActivity?.update(.init(state: currentContentState, staleDate: .distantFuture), alertConfiguration: .init(title: "AMK", body: "AMK2", sound: .default))
		}
	}
	
	func stopActivity() {
		Task {
			await liveActivity?.end(.init(state: currentContentState, staleDate: .distantFuture), dismissalPolicy: .immediate)
		}
	}
}

public class ElapsedTime {
	public var hours: String {
		String(hoursInt > 0 ? "\(hoursInt):" : "")
	}
	public var minutes: String {
		String(format: "%02d", minutesInt) + ":"
	}
	public var seconds: String {
		String(format: "%02d", secondsInt)
	}
	public var hoursTilSeconds: String {
		hours + minutes + seconds
	}
	public var milliseconds: String {
		String(millisecondsInt).padding(toLength: decimalDigits, withPad: "0", startingAt: 0)
	}
	
	private var hoursInt: Int
	private var minutesInt: Int
	private var secondsInt: Int
	private var millisecondsInt: Int
	private var decimalDigits: Int
	
	init(elapsedSeconds: TimeInterval, decimalDigits: Int) {
		self.decimalDigits = decimalDigits
		let values = Duration.seconds(elapsedSeconds).formatted(.units(allowed: [.hours, .minutes, .seconds, .milliseconds], width: .wide, zeroValueUnits: .show(length: 1))).split(separator: ",")
		self.hoursInt = Int(values[0].split(separator: " ").first!) ?? 187
		self.minutesInt = Int(values[1].split(separator: " ").first!) ?? 187
		self.secondsInt = Int(values[2].split(separator: " ").first!) ?? 187
		self.millisecondsInt = (Int(values[3].split(separator: " ").first!) ?? 187) / Int(pow(10, 3 - Double(decimalDigits)))
	}
}
