//
//  RepSubmitButton.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 20/10/23.
//

import SwiftUI

struct RepSubmitButton: View {
	@State var number: Int
	var scaledUp: Bool = false
	
	var body: some View {
		Button(intent: SubmitRepetitions.fromInt(number)) {
			Circle()
				.scaleEffect(CGSize(width: scaledUp ? 1.2 : 1.0, height: scaledUp ? 1.2 : 1.0))
				.overlay {
					Text(String(number))
						.tint(.primary)
						.fontWeight(scaledUp ? .black : .regular)
						.font(scaledUp ? .title2 : .body)
				}
		}
	}
}

#Preview {
	RepSubmitButton(number: 1, scaledUp: true)
}
