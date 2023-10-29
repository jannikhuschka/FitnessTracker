//
//  ActiveTrainingView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 16/10/23.
//

import SwiftUI
import ActivityKit

struct ActiveTrainingView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@ObservedObject private var stopwatch = FitnessStopwatch.Instance
	@State var showingAlert: Bool = false
	@Binding var training: Training
	@State var liveActivity: Activity<FitnessWidgetAttributes>?
	@State var tempUpcomingExercises: [ExerciseDefinition] = []
	@State var isPresentingReorderView: Bool = false
	@State var isPresentingLastSession: Bool = false
	
	var body: some View {
		NavigationStack {
			VStack {
				Circle()
					.stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
					.foregroundStyle(.gray.opacity(0.2))
					.frame(width: 333)
					.overlay {
						PartialRing(progress: Double(stopwatch.completedSets) / Double(stopwatch.totalSets), diameter: 333)
							.rotation(.degrees(-90))
							.stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
							.foregroundStyle(.blue)
							.overlay {
								VStack {
									ValueDescriptionAbove(description: "Legs", value: "\(stopwatch.completedSets.formatted(.number)) / \(stopwatch.totalSets)", alignment: .center, valFont: .title)
									
									HStack(alignment: .firstTextBaseline) {
										Button(intent: ShortenPause()) {
											Image(systemName: "minus.circle")
										}
										.disabled(!stopwatch.pausePhase)
										
										Text(stopwatch.completed ? "COMPLETE" : (stopwatch.pausePhase ? "PAUSE" : "ACTIVE"))
											.foregroundStyle(.gray)
											.textCase(.uppercase)
											.padding(.top, 8)
										
										Button(intent: LengthenPause()) {
											Image(systemName: "plus.circle")
										}
										.disabled(!stopwatch.pausePhase)
									}
									.font(.caption)
									
									Text(ElapsedTime(elapsedSeconds: stopwatch.displayTime, decimalDigits: 0).hoursTilSeconds)
										.font(.system(size: 50))
										.bold()
										.contentTransition(.numericText(countsDown: stopwatch.pausePhase))
										.foregroundStyle(stopwatch.pausePhase ? .green : .white)
										.padding(.vertical, 1)
									
									Text(stopwatch.completed ? "Training Complete" : ElapsedTime(elapsedSeconds: stopwatch.elapsedSeconds, decimalDigits: 0).hoursTilSeconds)
										.animation(nil)
										.padding(.bottom, 8)
									
									ValueDescriptionBelow(description: "Weight", value: "\(stopwatch.totalMovedWeight.formatted(.number)) kg", alignment: .center, valFont: .title)
								}
							}
							.padding(.horizontal, 25)
					}
				
				if(!stopwatch.completed) {
					HStack {
						ValueDescriptionAbove(description: stopwatch.currentSupersetExercise?.name ?? "Current Exercise", value: "\(stopwatch.currentExDef.name)", alignment: .leading, valFont: .title)
						Spacer()
						ValueDescriptionAbove(description: superSetLegs ?? "Leg", value: "\(stopwatch.currentExercise.sets.count + 1)/\(stopwatch.currentExDef.setCount(overrideChain: stopwatch.completeOverrideChain))", alignment: .center, valFont: .title)
						Spacer()
						ValueDescriptionAbove(description: "Weight", value: "\(stopwatch.currentWeight.formatted(.number)) kg", alignment: .trailing, valFont: .title, control1: {
							Button(intent: DecreaseWeight()){
								Image(systemName: "minus.circle")
							}
						}, control2: {
							Button(intent: IncreaseWeight()) {
								Image(systemName: "plus.circle")
							}
						})
					}
					.padding(.vertical)
					
					VStack(alignment: .leading) {
//						Text("Log repetitions")
//							.font(.title2 .bold())
						SelectableRepsView(range: 1...Int(stopwatch.currentSetDef.repCount), height: 90, highlight: stopwatch.repsToBeat)
					}
				}
			}
			.padding()
			.navigationTitle(training.name)
			.navigationBarBackButtonHidden()
			.toolbar {
				if(stopwatch.completed) {
					ToolbarItem(placement: .confirmationAction) {
						Button(action: {
							stopwatch.clear()
							self.presentationMode.wrappedValue.dismiss()
						}) {
							Image(systemName: "flag.checkered")
						}
						.bold()
					}
				} else {
					ToolbarItem(placement: .cancellationAction) {
						Button(role: .destructive, action: {
							showingAlert = true
						}) {
							Image(systemName: "trash")
						}
						.foregroundStyle(.red)
						.alert("Abort training session?", isPresented: $showingAlert, actions: {
							Button("Yes", role: .destructive) {
								stopwatch.clear()
								stopwatch.stopActivity()
								self.presentationMode.wrappedValue.dismiss()
							}
							Button("No", role: .cancel) {
								showingAlert = false
							}
						})
					}
					if(!training.sessions.isEmpty) {
						ToolbarItem(placement: .confirmationAction) {
							Button(action: {
								isPresentingLastSession = true
							}) {
								Image(systemName: "checkmark.gobackward")
							}
						}
					}
					ToolbarItem(placement: .confirmationAction) {
						Button(action: {
							tempUpcomingExercises = stopwatch.upcomingExercises
							isPresentingReorderView = true
						}) {
							Image(systemName: "list.number")
						}
					}
					ToolbarItem(placement: .confirmationAction) {
						Button(action: {
							withAnimation {
								stopwatch.training = training
								stopwatch.startPause()
							}
						}) {
							Image(systemName: stopwatch.running ? "pause" : "play")
						}
					}
				}
			}
			.onAppear() {
				if(stopwatch.running || stopwatch.elapsedSeconds != 0) { return }
				stopwatch.clear()
				stopwatch.training = training
				stopwatch.startPause()
			}
			.onChange(of: stopwatch.completed) { oldVal, newVal in
				if(newVal == true) {
					training.sessions.append(stopwatch.session)
//					updateTargets()
				}
			}
		}
		.sheet(isPresented: $isPresentingReorderView, onDismiss: {
			stopwatch.setUpcomingExercises(tempUpcomingExercises)
		}) {
			VStack {
				List {
					Section(header: Text("Current Exercise")) {
						Text(tempUpcomingExercises.first?.name ?? "None")
					}
					Section(header: Text("Upcoming Exercises")) {
						ForEach(tempUpcomingExercises.indices, id: \.self) { i in
							if(i != 0) {
								HStack {
									Text(tempUpcomingExercises[i].name)
									Spacer()
									Button(action: {
										withAnimation {
											tempUpcomingExercises.swapAt(0, i)
										}
									}) {
										Image(systemName: "arrow.up.to.line")
											.font(.caption .bold())
									}
									.buttonStyle(.borderedProminent)
									.tint(.green)
									.clipShape(.circle)
								}
							}
						}
						.onMove(perform: { indices, newOffset in
							tempUpcomingExercises.move(fromOffsets: indices, toOffset: newOffset)
						})
					}
				}
			}
			.environment(\.editMode, Binding.constant(EditMode.active))
			.presentationDetents([.medium, .large])
		}
		.sheet(isPresented: $isPresentingLastSession) {
			SessionView(session: training.sessions.last!)
				.presentationDetents([.fraction(0.9)])
				.presentationDragIndicator(Visibility.visible)
		}
	}
	
	func updateTargets() {
		let exercises = stopwatch.session.exercises
		for i in training.exercises.indices {
			guard let exercise = exercises.fromDefinition(training.exercises[i]) else { continue }
			if exercise.completedTarget(training.exercises[i]) {
				training.exercises[i].overrides?.setDefinition.weightStage? += 1
			}
		}
	}
	
	var superSetLegs: String? {
		guard let currentSupersetDef = stopwatch.currentSupersetDef, let currentSupersetExercise = stopwatch.currentSupersetExercise else { return nil }
		return "\(currentSupersetExercise.subExercises.reduce(0, { $0 + $1.sets.count }) + 1)/\(currentSupersetDef.setCount(overrideChain: stopwatch.supersetOverrideChain))"
	}
}

#Preview {
	ActiveTrainingView(training: .constant(.sample1))
}
