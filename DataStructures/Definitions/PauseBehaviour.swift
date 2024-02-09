import Foundation

struct PauseBehaviour : HashEqCod {
	var mode: PauseMode = .fixedPauseDuration
	var duration: Int = 60
}
