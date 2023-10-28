//
//  SessionView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 17/10/23.
//

import SwiftUI

struct SessionView: View {
	@State var session: TrainingSession
	
    var body: some View {
		NavigationStack {
			List {
				ForEach(session.exercises, id: \.self) { exercise in
					Section(header: Text(exercise.name)) {
						HStack {
							ForEach(exercise.sets.indices, id: \.self) { i in
								ValueDescriptionBelow(description: "\(exercise.sets[i].weight.formatted(.number)) kg", value: "\(exercise.sets[i].reps)", alignment: .center, valFont: .title2 .bold())
									.frame(maxWidth: .infinity)
								if (i != exercise.sets.count - 1) {
									Spacer()
									Divider()
									Spacer()
								}
							}
						}
					}
				}
			}
			.navigationTitle("\(session.trainingName): Session \(session.number)")
		}
    }
}

#Preview {
	SessionView(session: .sample2)
}
