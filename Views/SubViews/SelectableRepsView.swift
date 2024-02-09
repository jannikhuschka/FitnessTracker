import SwiftUI
import AppIntents

struct SelectableRepsView: View {
	var range: ClosedRange<Int>
	@State var height: CGFloat
	@State var heightDivisor: CGFloat = 3
	var highlight: Int
	
	var body: some View {
		HStack {
			if(range.tooLong && !range.oddCount) {
				VStack {
					RepSubmitButton(number: 0)
						.opacity(0.5)
				}
				.frame(height: height / 2)
			}
			
			VStack {
				HStack {
					if(!range.tooLong || range.oddCount) {
						RepSubmitButton(number: 0)
							.opacity(0.5)
					}
					ForEach(range.firstHalf, id: \.self) { index in
						RepSubmitButton(number: index, scaledUp: index == highlight)
					}
				}
				if(range.tooLong) {
					HStack {
						ForEach(range.secondHalf, id: \.self) { index in
							RepSubmitButton(number: index, scaledUp: index == highlight)
						}
					}
				}
			}
			.frame(height: height)
		}
		.buttonStyle(.borderless)
		.font(.headline)
	}
}

extension ClosedRange<Int> {
	public var length: Int {
		return upperBound - lowerBound
	}
	
	var oddCount: Bool {
		return count % 2 == 1
	}
	
	var tooLong: Bool {
		count > 7
	}
	
	var firstHalf: ClosedRange<Int> {
		if(tooLong) {
			return lowerBound...Int(Float(lowerBound) + (Float(count - 2) / 2).rounded(.down))
		}
		return self
	}
	
	var secondHalf: ClosedRange<Int> {
		if(tooLong) {
			return Int(Float(lowerBound) + (Float(count - 2) / 2).rounded(.down) + 1)...upperBound
		}
		return self
	}
}

#Preview {
	SelectableRepsView(range: 8...15, height: 150, highlight: 10)
}
