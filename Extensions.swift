import Foundation

extension String {
	func pluralize(_ number: Int) -> String {
		return "\(number) " + self + (number == 1 ? "" : "s")
	}
}
