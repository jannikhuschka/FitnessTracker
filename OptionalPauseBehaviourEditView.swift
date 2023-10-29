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
			HStack {
				Button("Pause", systemImage: "plus.circle", action: {
					withAnimation {
						pause = overrideChain.setDefinition.pause
					}
				})
				Spacer()
				Text("\(overrideChain.levelFor(.pauseBehaviour)): \(overrideChain.setDefinition.pause.mode.shortened)\(overrideChain.setDefinition.pause.mode == .infinitePause ? "" : " \(overrideChain.setDefinition.pause.duration.formatted(.number))s")")
					.foregroundStyle(.gray)
			}
		}
	}
}

#Preview {
	OptionalPauseBehaviourEditView(pause: .constant(.init()), overrideChain: .sample)
}
