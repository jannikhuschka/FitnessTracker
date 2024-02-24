import Foundation

struct OldPauseBehaviour : HashEqCod {
	var mode: OldPauseMode = .fixedPauseDuration
	var duration: Int = 60
}
