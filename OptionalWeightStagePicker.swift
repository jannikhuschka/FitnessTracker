//
//  OptionalWeightStagePicker.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 28/10/23.
//

import SwiftUI

struct OptionalWeightStagePicker: View {
	@Binding var weightStage: Int?
	var overrideChain: ExerciseOverrideChain
	
    var body: some View {
		if let weightStageBinding = Binding<Int>($weightStage) {
			WeightStagePicker(weightStage: weightStageBinding, possibleWeights: overrideChain.possibleWeights)
				.swipeActions {
					Button("Remove Weight Stage Override", role: .destructive, action: {
						withAnimation {
							weightStage = nil
						}
					})
				}
		} else {
			HStack {
				Button("Weight Stage", systemImage: "plus.circle", action: {
					withAnimation {
						weightStage = overrideChain.setDefinition.weightStage
					}
				})
				Spacer()
				Text("\(overrideChain.levelFor(.weightStage)): \(overrideChain.setDefinition.weight(possibleWeights: overrideChain.possibleWeights).formatted(.number))kg")
					.foregroundStyle(.gray)
			}
		}
    }
}

#Preview {
	OptionalWeightStagePicker(weightStage: .constant(1), overrideChain: .sample)
}
