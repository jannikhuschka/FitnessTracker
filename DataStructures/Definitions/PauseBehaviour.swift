import Foundation
import SwiftData

@Model
class PauseBehaviour {
	@Relationship var mode: PauseMode
	var duration: Int
	
	init(mode: PauseMode = .fixedPauseDuration, duration: Int = 60) {
		self.mode = mode
		self.duration = duration
	}
}
