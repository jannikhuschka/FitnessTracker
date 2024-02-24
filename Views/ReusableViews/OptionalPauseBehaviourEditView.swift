//
//  PauseBehaviourEditView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 28/10/23.
//

import SwiftUI

struct OptionalPauseBehaviourEditView: View {
	@Binding var pause: OldPauseBehaviour?
	var overrideChain: OldExerciseOverrideChain
	
	var body: some View {
		if let pauseBinding = getBinding($pause) {
			PauseBehaviourEditView(pause: pauseBinding)
				.swipeActions(edge: .trailing, allowsFullSwipe: true) {
					Button("Remove", role: .destructive) {
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
	
	func getBinding(_ binding: Binding<OldPauseBehaviour?>) -> Binding<OldPauseBehaviour>? {
		guard let wrappedValue = binding.wrappedValue else { return nil }
		return Binding(
			get: { wrappedValue },
			set: { binding.wrappedValue = $0 }
		)
	}
}

#Preview {
	OptionalPauseBehaviourEditView(pause: .constant(.init()), overrideChain: .sample)
}
