//
//  PauseBehaviourEditView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 28/10/23.
//

import SwiftUI

struct PauseBehaviourEditView: View {
	@Binding var pause: OldPauseBehaviour
	
    var body: some View {
		VStack {
			HStack {
				Label("Pause Mode", systemImage: "pause.circle")
				Spacer()
				Menu {
					Picker(selection: $pause.mode, label: EmptyView()) {
						ForEach(PauseMode.allCases, id: \.self) { mode in
							Label(mode.rawValue, systemImage: PauseMode.symbol(mode: mode))
								.tag(mode)
						}
					}
					.tint(Color.accentColor)
				} label: {
					Text(pause.mode.rawValue)
				}
			}
			
			if(pause.mode != .infinitePause) {
				Divider()
				
				HStack {
					Label(pause.mode.rawValue, systemImage: "stopwatch")
					Spacer()
					TextField(pause.mode.rawValue, value: $pause.duration, formatter: NumberFormatter.int)
						.keyboardType(.numberPad)
						.multilineTextAlignment(.trailing)
						.foregroundStyle(Color.accentColor)
						.frame(width: 100)
					Text("sec")
						.foregroundStyle(Color.accentColor)
				}
			}
		}
    }
}

#Preview {
	PauseBehaviourEditView(pause: .constant(.init()))
}
