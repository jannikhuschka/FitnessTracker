//
//  ExerciseListItem.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 02/11/23.
//

import SwiftUI

struct ExerciseListItem: View {
	var exercise: OldExerciseDefinition
	var overrideChain: OldExerciseOverrideChain
	var nameOverride: String? = nil
	
    var body: some View {
		HStack {
			Label(nameOverride ?? exercise.name, systemImage: exercise.typeSymbol)
			Spacer()
			if(exercise.isSuperset) {
				ValueDescriptionBelow(description: "Ex", value: "\(exercise.supersetMembers!.count)", alignment: .center)
				ValueDescriptionBelow(description: "Sets", value: "\(exercise.setCount(overrideChain: overrideChain))", alignment: .center)
			} else {
				if(exercise.isSimple) {
					ValueDescriptionBelow(description: "Sets", value: "\(exercise.setCount(overrideChain: fullOverrideChain))", alignment: .center)
					ValueDescriptionBelow(description: "Reps", value: "\(fullOverrideChain.setDefinition.repCount)", alignment: .center)
					ValueDescriptionBelow(description: "kg", value: "\(fullOverrideChain.setDefinition.weight(possibleWeights: fullOverrideChain.possibleWeights).formatted(.number))", alignment: .center)
				} else {
//					ValueDescriptionBelow(description: "Sets", value: "\(individualSets)", alignment: .center)
					ForEach(0..<min(exercise.setDefinitions.count, 3), id: \.self) { i in
						let setDef = exercise.setDefinition(number: i, overrideChain: fullOverrideChain)
						HStack(spacing: 2) {
							Text("\(setDef.repCount)")
							Image(systemName: "multiply")
								.font(.caption)
								.foregroundStyle(.accent)
							Text(setDef.weight(possibleWeights: fullOverrideChain.possibleWeights).formatted(.number))
						}
						if(i < min(exercise.setDefinitions.count - 1, 2)) {
							Divider()
						}
					}
				}
				//									.frame(width: 45)
				//								ValueDescriptionBelow(description: "Reps", value: "\(training.exercises[i].defaultSetDefinition.target.repCount.formatted(.number))", alignment: .center, descFont: .caption2, valFont: .body)
				//									.frame(width: 45)
				//								ValueDescriptionBelow(description: "kg", value: "\(training.exercises[i].defaultSetDefinition.targetWeight.formatted(.number))", alignment: .center, descFont: .caption2, valFont: .body)
				//									.frame(width: 45)
			}
		}
    }
	
	var individualSets: String {
		var sets = ""
		for i in 0..<exercise.setCount(overrideChain: overrideChain) {
			let def = exercise.setDefinition(number: i, overrideChain: overrideChain)
			sets += "\(def.repCount)" + " * " + "\(def.repCount)" + "kg, "
		}
		sets = String(sets.dropLast(2))
		
		return sets
	}
	
	var fullOverrideChain: OldExerciseOverrideChain {
		overrideChain.with(exercise.overrides)
	}
}

#Preview {
	ExerciseListItem(exercise: .sample1, overrideChain: .sample)
}
