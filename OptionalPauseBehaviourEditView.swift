//
//  PauseBehaviourEditView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 28/10/23.
//

import SwiftUI

struct OptionalPauseBehaviourEditView: View {
	@Binding var pause: PauseBehaviour?
	var overrideChain: ExerciseOverrideChain
	
	var body: some View {
		if let pauseBinding = Binding<PauseBehaviour>($pause) {
			PauseBehaviourEditView(pause: pauseBinding)
				.swipeActions(edge: .trailing, allowsFullSwipe: true) {
					Button("Delete Pause Override", role: .destructive) {
						withAnimation {
							pause = nil
						}
					}
				}
		} else {
			Button("Add Pause Override", systemImage: "plus.circle", action: {
				withAnimation {
					pause = overrideChain.setDefinition.pause
				}
			})
		}
	}
}

#Preview {
	OptionalPauseBehaviourEditView(pause: .constant(.init()), overrideChain: .sample)
}
