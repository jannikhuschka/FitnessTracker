import Foundation
import SwiftUI
import ActivityKit

enum CodingKeys: CodingKey {
	case running, training, session, currentExercise, repsToBeat, currentWeight
}

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
	
	@Published var currentExDef: ExerciseDefinition = .empty
	@Published var currentSetDef: SetDefinition = .init(repCount: 15, weightStage: 5, pause: .init())
	@Published var currentExercise: Exercise = .empty
	@Published var upcomingExercises: [ExerciseDefinition] = []
	@Published var postponedExercises: [Exercise] = []
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
	private var startDate: Date?
	private var lastSetCompleteDate: Date = Date()
	private var totalPauseTime: TimeInterval = .zero
	private var pauseDate: Date?
	private var pauseMode: PauseMode = .fixedPauseDuration
	private var pauseModeDuration: Double { Double(currentSetDef.pause.duration) }
	private var endOfPauseDate: Date = Date()
	
	private weak var timer: Timer?
	
	func startPause() {
		if !running && elapsedSeconds == 0.0 { start() }
		else if !running {
			resume()
		} else {
			pause()
		}
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
		currentExDef = upcomingExercises.first!
		currentExercise = .fromDefinition(definition: currentExDef)
//		repsToBeat = lastSession?.exercises.fromDefinition(currentExDef)?.sets[currentExercise.sets.count].reps ?? currentExDef.target.repCount
//		currentWeight = lastSession?.exercises.fromDefinition(currentExDef)?.sets[currentExercise.sets.count].weight ?? currentExDef.targetWeight
		lastSetCompleteDate = Date()
		pauseMode = currentSetDef.pause.mode
		
		startDate = Date()
		timer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { [weak self] timer in
			self?.update()
		}
		timer?.tolerance = 0.2
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
		currentExercise = .empty
		upcomingExercises = []
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
	
	func increaseWeight() {
		withAnimation {
			currentWeight += currentExDef.overrides?.possibleWeights?.weightStep ?? training.defaults.possibleWeights.weightStep
		}
	}
	
	func decreaseWeight() {
		withAnimation {
			currentWeight -= currentExDef.overrides?.possibleWeights?.weightStep ?? training.defaults.possibleWeights.weightStep
		}
	}
	
	func submitRepetitions(repetitions: Int) {
		if(completed) { return }
		
		withAnimation {
			currentExercise.sets.append(.init(reps: repetitions, weight: currentWeight))
			totalMovedWeight += Double(repetitions) * currentWeight
			nextSet()
			update()
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
		if(currentExercise.sets.count == Int(currentExDef.setCount)) {
			nextExercise()
		}
		
		if(completed) { return }
//		repsToBeat = (lastSession?.isCompatibleTo(currentExDef) ?? false) ? lastSession!.exercises.fromDefinition(currentExDef)!.sets[currentExercise.sets.count].reps : currentExDef.target.repCount
//		currentWeight = (lastSession?.isCompatibleToAndDoesntDivertFrom(currentExDef) ?? false) ? lastSession!.exercises.fromDefinition(currentExDef)!.sets[currentExercise.sets.count].weight : currentExDef.targetWeight
	}
	
	func nextExercise() {
		session.exercises.append(currentExercise)
		upcomingExercises.remove(at: 0)
		if(upcomingExercises.isEmpty) {
			finishSession()
			return()
		}
		currentExDef = upcomingExercises.first!
		getCurrentExercise()
	}
	
	func finishSession() {
		pause()
		pausePhase = false
		displayTime = elapsedSeconds
		completed = true
		stopActivity()
	}
	
	func lengthenPause() {
		if(!pausePhase || pauseMode == .infinitePause) { return }
		endOfPauseDate += 30
		update()
	}
	
	func shortenPause() {
		if(!pausePhase || pauseMode == .infinitePause) { return }
		endOfPauseDate -= min(30, endOfPauseDate.timeIntervalSince1970 - Date().timeIntervalSince1970)
		update()
	}
	
	nonisolated private func update() {
		Task { @MainActor in
			guard let startDate, running else { return }
			withAnimation {
				let date = Date()
				elapsedSeconds = 1 * ( date.timeIntervalSince1970 - startDate.timeIntervalSince1970 - totalPauseTime )
				
				if(date > endOfPauseDate && pausePhase) {
					pausePhase = false
					updateActivityWithAlert()
				}
				
				switch(pauseMode) {
				case .fixedPauseDuration, .fixedSetDuration:
					displayTime = (pausePhase ? endOfPauseDate.timeIntervalSince1970 - date.timeIntervalSince1970 : date.timeIntervalSince1970 - endOfPauseDate.timeIntervalSince1970)
				case .infinitePause:
					displayTime = date.timeIntervalSince1970 - lastSetCompleteDate.timeIntervalSince1970 - totalPauseTime
				}
			}
			if(Int(elapsedSeconds.rounded(.down)) >= elapsedSecondsInt + 5) {
				updateActivity()
				elapsedSecondsInt = Int(elapsedSeconds)
			}
		}
	}
	
	var currentContentState: FitnessWidgetAttributes.ContentState {
		.init(stopwatchPaused: !running, pausePhase: pausePhase, time: ElapsedTime(elapsedSeconds: displayTime, decimalDigits: 0).hoursTilSeconds, exercise: currentExercise, exDef: currentExDef, setDef: currentSetDef, nextDefinitions: Array(upcomingExercises.suffix(from: min(1, upcomingExercises.count))), upcomingOffset: liveActivityUpcomingOffset, repsToBeat: repsToBeat, currentWeight: currentWeight, completedSets: completedSets)
	}
	
	func getCurrentExercise() {
		if(postponedExercises.contains(where: { $0.name == currentExDef.name })) {
			currentExercise = postponedExercises.remove(at: postponedExercises.firstIndex(where: { $0.name == currentExDef.name})!)
		} else {
			currentExercise = .fromDefinition(definition: currentExDef)
		}
	}
	
	func swapExercise(exerciseName: String) {
		if(!currentExercise.sets.isEmpty) {
			postponedExercises.append(currentExercise)
		}
		upcomingExercises.swapAt(0, upcomingExercises.firstIndex(where: { $0.name == exerciseName })!)
		currentExDef = upcomingExercises.first!
		getCurrentExercise()
		print(currentExercise.name)
	}
	
	func setUpcomingExercises(_ upcoming: [ExerciseDefinition]) {
		upcomingExercises = upcoming
		if(upcoming.first?.name != currentExDef.name) {
			currentExDef = upcoming.first ?? .empty
			getCurrentExercise()
		}
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
	
	func increaseLiveActivityUpcomingOffset(_ inc: Int) {
		liveActivityUpcomingOffset += inc
	}
	
	func decreaseLiveActivityUpcomingOffset(_ dec: Int) {
		liveActivityUpcomingOffset -= dec
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
