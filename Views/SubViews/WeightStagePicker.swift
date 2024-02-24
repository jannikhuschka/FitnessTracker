//
//  WeightStagePicker.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 28/10/23.
//

import SwiftUI

struct WeightStagePicker: View {
	@Binding var weightStage: Int
	var possibleWeights: OldPossibleWeights
	
    var body: some View {
		Picker(selection: $weightStage, label: Label("Weight Stage", systemImage: "scalemass.fill")) {
			ForEach(0...50, id: \.self) { i in
				Text("\((possibleWeights.baseWeight + Double(i) * possibleWeights.weightStep).formatted(.number)) kg")
					.tag(i)
			}
		}
		.tint(Color.accentColor)
    }
}

#Preview {
	WeightStagePicker(weightStage: .constant(187), possibleWeights: .sample1)
}
