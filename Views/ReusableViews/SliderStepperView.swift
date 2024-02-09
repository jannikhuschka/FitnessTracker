//
//  SliderStepperView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 19/10/23.
//

import SwiftUI

struct SliderStepperView: View {
	@Binding var value: Double
	@State var description: String
	@State var range: ClosedRange<Double>
	@State var steps: [Double]
	
    var body: some View {
		HStack {
			Slider(value: $value, in: range, step: steps.first!)
			Text("\(value.formatted(.number)) \(description)")
//			Stepper("", value: $value, in: range, step: steps.last!)
		}
    }
}

#Preview {
	SliderStepperView(value: .constant(187), description: "Test", range: 1...200, steps: [4])
}
