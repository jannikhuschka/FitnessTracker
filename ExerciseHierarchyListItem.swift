//
//  ExerciseHierarchyListItem.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 21/10/23.
//

import SwiftUI

struct ExerciseHierarchyListItem: View {
	@State var exercise: ExerciseHierarchy
	
    var body: some View {
		HStack(spacing: 8) {
			Label(exercise.name, systemImage: exercise.name == "Exercises" ? "list.number" : "\(exercise.number).square")
				.truncationMode(.tail)
				.scaledToFit()
			Spacer()
			
			if (exercise.name != "Exercises") {
				ValueDescriptionAbove(description: "Sets", value: "\(exercise.setCount)")
				ValueDescriptionAbove(description: "Reps", value: "\(exercise.repCount)")
				ValueDescriptionAbove(description: "kg", value: "\(exercise.weight.formatted(.number))")
			} else {
				Text("\(exercise.children?.count ?? 0)")
					.foregroundStyle(.gray)
			}
		}
		.padding(.vertical, 2)
    }
}

#Preview {
	ExerciseHierarchyListItem(exercise: .init(name: "Exercise"))
}
