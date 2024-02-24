//
//  UpdateTargetsView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 23/01/24.
//

import SwiftUI

struct UpdateTargetsView: View {
	@Binding var training: OldTraining
	@State var exercisesToUpdate: [OldExerciseParamsUpdate]
	@State var appliedChanges: [OldExerciseParamsUpdate : [any OldExerciseParamsChangeAction]] = [:]
	
	var body: some View {
		List {
			if exercisesToUpdate.count > 1 {
				let allApplied = exercisesToUpdate.allSatisfy({ (appliedChanges[$0]?.count ?? 0) == $0.proposedChanges.count })
				Button {
					allApplied ? revertAllChanges() : acceptAllChanges()
				} label: {
					HStack {
						Text(allApplied ? "Revert all" : "Accept all")
						Spacer()
						Image(systemName: allApplied ? "xmark" : "checkmark")
							.contentTransition(.symbolEffect(.replace.downUp))
					}
				}
			}
			
			ForEach(exercisesToUpdate, id: \.hashValue) { exUpdate in
				Section("\(exUpdate.exercise.name)") {
					if !exUpdate.exercise.isSuperset {
						HStack {
							ForEach(exUpdate.exercise.sets.indices, id: \.self) { i in
								let chain = overrideChainForExercise(exUpdate.exercise)
								let setDef = exUpdate.exerciseDefinition.setDefinition(number: i, overrideChain: chain)
								let set = exUpdate.exercise.sets[i]
								
								if i != 0 {
									Divider()
								}
								
								Spacer()
								
								VStack {
									HStack {
										if set.reps > setDef.repCount {
											Text("\(setDef.repCount)")
												.strikethrough(true, color: .primary)
												.foregroundStyle(.gray)
										}
										Text("\(set.reps)")
											.foregroundStyle(.accent)
									}
									.font(.title2.bold())
									HStack {
										if set.weight > setDef.weight(possibleWeights: chain.possibleWeights) {
											Text(setDef.weight(possibleWeights: chain.possibleWeights).formatted(.number))
												.strikethrough(true, color: .primary)
												.foregroundStyle(.gray)
										}
										Text(set.weight.formatted(.number) + " kg")
									}
								}
								
								Spacer()
							}
						}
					}
					
					if exUpdate.proposedChanges.count > 1 {
						let allApplied = (appliedChanges[exUpdate]?.count ?? 0) == exUpdate.proposedChanges.count
						Button {
							allApplied ? revertAllChanges(exUpdate) : acceptAllChanges(exUpdate)
						} label: {
							HStack {
								Text(allApplied ? "Revert all" : "Accept all")
								Spacer()
								Image(systemName: allApplied ? "xmark" : "checkmark")
									.contentTransition(.symbolEffect(.replace.downUp))
							}
						}
					}
					
					if !exUpdate.exercise.isSuperset {
						ForEach(exUpdate.proposedChanges.indices, id: \.self) { i in
							let change = exUpdate.proposedChanges[i]
							let changeApplied = appliedChanges[exUpdate]?.contains(where: { $0.hashValue == change.hashValue }) ?? false
							HStack {
								Text(change.description)
								Spacer()
								Text(change.formattedValueBefore)
								Image(systemName: "arrow.right")
								Text(change.formattedValueAfter)
									.foregroundStyle(.accent)
								Button {
									toggleChange(exUpdate, index: i)
								} label: {
									Image(systemName: changeApplied ? "checkmark.circle.fill" : "checkmark.circle")
										.frame(width: 20)
								}
								.contentTransition(.symbolEffect(.replace.downUp))
								//							.buttonStyle(.borderedProminent)
							}
						}
					} else {
						ForEach(exUpdate.exercise.subExercises.indices, id: \.self) { i in
							if let changeIndices = exUpdate.changesForSubExercise(atIndex: i) {
								let change = exUpdate.proposedChanges[i]
								let exercise = exUpdate.exercise.subExercises[i]
								Text(exercise.name)
								ForEach(changeIndices, id: \.self) { i in
									Text("Value after: \(change.formattedValueAfter)")
								}
							}
						}
					}
				}
			}
		}
	}
	
	func overrideChainForExercise(_ exercise: OldExercise) -> OldExerciseOverrideChain {
		.init(root: training.defaults, overrides: [training.exercises.first(where: { $0.name == exercise.name })!.overrides])
	}
	
	func toggleChange(_ paramsUpdate: OldExerciseParamsUpdate, index: Int) {
		let changeAction = paramsUpdate.proposedChanges[index]
		if appliedChanges[paramsUpdate]?.contains(where: { $0.hashValue == changeAction.hashValue }) ?? false {
			revertChange(paramsUpdate, index: index)
		} else {
			acceptChange(paramsUpdate, index: index)
		}
	}
	
	func acceptChange(_ paramsUpdate: OldExerciseParamsUpdate, index: Int) {
		let exerciseIndex = training.exercises.firstIndex(where: { $0.name == paramsUpdate.exerciseDefinition.name })!
		let changeAction = paramsUpdate.proposedChanges[index]
		if appliedChanges[paramsUpdate]?.contains(where: { $0.hashValue == changeAction.hashValue }) ?? false { return }
		training.exercises[exerciseIndex] = changeAction.apply(paramsUpdate.exerciseDefinition)
		withAnimation {
			if appliedChanges[paramsUpdate] == nil { appliedChanges[paramsUpdate] = [] }
			appliedChanges[paramsUpdate]!.append(changeAction)
		}
	}
	
	func revertChange(_ paramsUpdate: OldExerciseParamsUpdate, index: Int) {
		let exerciseIndex = training.exercises.firstIndex(where: { $0.name == paramsUpdate.exerciseDefinition.name })!
		let changeAction = paramsUpdate.proposedChanges[index]
		if !(appliedChanges[paramsUpdate]?.contains(where: { $0.hashValue == changeAction.hashValue }) ?? false) { return }
		training.exercises[exerciseIndex] = changeAction.revert(paramsUpdate.exerciseDefinition)
		withAnimation {
			appliedChanges[paramsUpdate]!.removeAll(where: { $0.hashValue == changeAction.hashValue })
		}
	}
	
	func acceptAllChanges(_ paramsUpdate: OldExerciseParamsUpdate) {
		paramsUpdate.proposedChanges.indices.forEach { i in
			acceptChange(paramsUpdate, index: i)
		}
	}
	
	func revertAllChanges(_ paramsUpdate: OldExerciseParamsUpdate) {
		paramsUpdate.proposedChanges.indices.forEach { i in
			revertChange(paramsUpdate, index: i)
		}
	}
	
	func acceptAllChanges() {
		exercisesToUpdate.forEach { paramsUpdate in
			acceptAllChanges(paramsUpdate)
		}
	}
	
	func revertAllChanges() {
		exercisesToUpdate.forEach { paramsUpdate in
			revertAllChanges(paramsUpdate)
		}
	}
}

#Preview {
	UpdateTargetsView(training: .constant(.sample1), exercisesToUpdate: [])
}
