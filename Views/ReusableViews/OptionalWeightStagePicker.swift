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
		if let weightStageBinding = getBinding($weightStage) {
			WeightStagePicker(weightStage: weightStageBinding, possibleWeights: overrideChain.possibleWeights)
				.swipeActions {
					Button("Remove", role: .destructive, action: {
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
	
	func getBinding(_ binding: Binding<Int?>) -> Binding<Int>? {
		guard let wrappedValue = binding.wrappedValue else { return nil }
		return Binding(
			get: { wrappedValue },
			set: { binding.wrappedValue = $0 }
		)
	}
}

#Preview {
	OptionalWeightStagePicker(weightStage: .constant(1), overrideChain: .sample)
}
