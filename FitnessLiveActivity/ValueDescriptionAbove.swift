//
//  DescriptionAndValueView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 16/10/23.
//

import SwiftUI

struct ValueDescriptionAbove<ControlContent1: View, ControlContent2: View>: View {
	var description: String
	var value: String
	@State var alignment: HorizontalAlignment
	@State var descFont: Font
	@State var valFont: Font
	
	@ViewBuilder let control1: () -> ControlContent1
	@ViewBuilder let control2: () -> ControlContent2
	
	init(description: String, value: String, alignment: HorizontalAlignment = .leading, descFont: Font = .caption2, valFont: Font = .body, control1: @escaping () -> ControlContent1, control2: @escaping () -> ControlContent2) {
		self.control1 = control1
		self.control2 = control2
		self.description = description
		self.value = value
		self.alignment = alignment
		self.descFont = descFont
		self.valFont = valFont
	}
	
	init(description: String, value: String, alignment: HorizontalAlignment = .leading, descFont: Font = .caption2, valFont: Font = .body) where ControlContent1 == EmptyView, ControlContent2 == EmptyView {
		self.control1 = { EmptyView() }
		self.control2 = { EmptyView() }
		self.description = description
		self.value = value
		self.alignment = alignment
		self.descFont = descFont
		self.valFont = valFont
	}
	
	var body: some View {
		VStack(alignment: alignment) {
			Text(description)
				.textCase(.uppercase)
				.font(descFont)
				.foregroundStyle(.gray)
				.contentTransition(value.contains(/[0-9]/) ? .numericText() : .interpolate)
			HStack {
				control1()
				Text(value)
					.font(valFont)
					.contentTransition(value.contains(/[0-9]/) ? .numericText() : .interpolate)
				control2()
			}
		}
    }
}

#Preview {
	ValueDescriptionAbove(description: "Description", value: "Value")
}
