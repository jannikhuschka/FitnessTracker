//
//  FitnessLiveActivityLiveActivity.swift
//  FitnessLiveActivity
//
//  Created by Jannik Huschka on 16/10/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FitnessWidgetAttributes: ActivityAttributes {
	public struct ContentState: Codable, Hashable {
		// Dynamic stateful properties about your activity go here!
		var stopwatchPaused: Bool = false
		var pausePhase: Bool
		var date: Date
		var exercise: Exercise
		var exDef: ExerciseDefinition = .empty
		var setDef: SetDefinition
		var nextDefinitions: [ExerciseDefinition] = []
		var overrideChain: ExerciseOverrideChain = .sample
		var upcomingOffset: Int = 0
		var repsToBeat: Int
		var currentWeight: Double
		var completedSets: Int
	}
	
	// Fixed non-changing properties about your activity go here!
	var totalSets: Int
}

struct FitnessWidgetLiveActivity: Widget {
	var body: some WidgetConfiguration {
		ActivityConfiguration(for: FitnessWidgetAttributes.self) { context in
			// Lock screen/banner UI goes here
			VStack(spacing: 7) {
				HStack(alignment: .center) {
					ValueDescriptionAbove(description: "Exercise", value: context.state.exercise.name)
					
					Spacer()
					
					if(!context.state.nextDefinitions.isEmpty) {
						VStack(alignment: .leading) {
							HStack {
								if(context.state.upcomingOffset > 0) {
									Button(intent: DecreaseLiveActivityUpcomingOffset()) {
										Image(systemName: "chevron.backward.2")
									}
								}
								
								ForEach(Array(context.state.nextDefinitions[context.state.upcomingOffset...min(context.state.upcomingOffset + 1, context.state.nextDefinitions.count - 1)]), id: \.self) { next in
									Button("\(next.name)", intent: SwapExercise.fromName(next.name))
										.tint(.accent)
								}
								
								if(context.state.nextDefinitions.count > 2 && context.state.upcomingOffset < context.state.nextDefinitions.count - 2) {
									Button(intent: IncreaseLiveActivityUpcomingOffset()) {
										Image(systemName: "chevron.forward.2")
									}
								}
							}
						}
						.font(.caption)
					}
				}
				
				HStack {
					HStack {
						Button(intent: ShortenPause()) {
							Image(systemName: "minus.circle")
						}
						.tint(.accent)
						.disabled(!context.state.pausePhase || context.state.stopwatchPaused)
						
						VStack(alignment: .center, spacing: 0) {
							Text(context.state.stopwatchPaused ? "Paused" : (context.state.pausePhase ? "Pause" : "Active"))
								.textCase(.uppercase)
								.foregroundStyle(.accent)
								.font(.caption2)
							
//							Text(context.state.date, style: .timer)
//								.multilineTextAlignment(.center)
							StopwatchTimeView(endOfPauseDate: context.state.date, pausePhase: context.state.pausePhase, paused: context.state.stopwatchPaused)
								.multilineTextAlignment(.center)
						}
						.frame(width: 50)
						
						Button(intent: LengthenPause()) {
							Image(systemName: "plus.circle")
						}
						.tint(.accent)
						.disabled(!context.state.pausePhase || context.state.stopwatchPaused)
					}
					
					Spacer()
					
					ValueDescriptionAbove(description: "Set", value: "\(context.state.exercise.sets.count + 1)/\(context.state.exDef.setCount(overrideChain: context.state.overrideChain))", alignment: .center)
					
					Spacer()
					
					Button(intent: DecreaseWeight()) {
						Image(systemName: "minus.circle")
							.frame(width: 20, height: 20)
					}
					.foregroundStyle(.accent)
					
					ValueDescriptionAbove(description: "Weight", value: "\(context.state.currentWeight.formatted(.number)) kg", alignment: .trailing)
//						.foregroundStyle(.accent)
					
					Button(intent: IncreaseWeight()) {
						Image(systemName: "plus.circle")
							.frame(width: 20, height: 20)
					}
					.foregroundStyle(.accent)
				}
				.buttonStyle(.borderless)
				.font(.title2)
				
				ProgressView(value: Double(context.state.completedSets), total: Double(context.attributes.totalSets))
					.tint(.accent)
				
				SelectableRepsView(range: context.state.repRange, height: 40, highlight: context.state.repsToBeat)
				
			}
			.padding()
			.activityBackgroundTint(.black)
			.activitySystemActionForegroundColor(.white)
			
		} dynamicIsland: { context in
			DynamicIsland {
				// Expanded UI goes here.  Compose the expanded UI through
				// various regions, like leading/trailing/center/bottom
				DynamicIslandExpandedRegion(.leading) {
					Text("Leading")
				}
				DynamicIslandExpandedRegion(.trailing) {
					Text("Trailing")
				}
				DynamicIslandExpandedRegion(.bottom) {
					Text("Bottom \(context.state.exercise.name)")
					// more content
				}
			} compactLeading: {
				Text("L")
			} compactTrailing: {
				Text("T \(context.state.exercise.name)")
			} minimal: {
				Text(context.state.exercise.name)
			}
			.widgetURL(URL(string: "http://www.apple.com"))
			.keylineTint(Color.red)
		}
	}
}

extension FitnessWidgetAttributes {
	fileprivate static var preview: FitnessWidgetAttributes {
		FitnessWidgetAttributes(totalSets: 20)
	}
}

extension FitnessWidgetAttributes.ContentState {
	var repRange: ClosedRange<Int> {
		if(repsToBeat > setDef.repCount - 3) {
			return (self.setDef.repCount - 6)...setDef.repCount
		}
		if(repsToBeat < 4) {
			return 1...7
		}
		
		return (repsToBeat - 3)...(repsToBeat + 3)
	}
	
	fileprivate static var one: FitnessWidgetAttributes.ContentState {
		FitnessWidgetAttributes.ContentState(pausePhase: false, date: .now, exercise: .empty, setDef: .init(repCount: 15, weightStage: 5, pause: .init()), repsToBeat: 5, currentWeight: 40, completedSets: 2)
	}
	
	fileprivate static var two: FitnessWidgetAttributes.ContentState {
		FitnessWidgetAttributes.ContentState(pausePhase: true, date: .now, exercise: .sample1, setDef: .init(repCount: 151, weightStage: 187, pause: .init()), repsToBeat: 15, currentWeight: 20, completedSets: 18)
	}
}

#Preview("Notification", as: .content, using: FitnessWidgetAttributes.preview) {
	FitnessWidgetLiveActivity()
} contentStates: {
	FitnessWidgetAttributes.ContentState.one
	FitnessWidgetAttributes.ContentState.two
}
