import Foundation

struct OldPauseBehaviour : HashEqCod {
	var mode: PauseMode = .fixedPauseDuration
	var duration: Int = 60
}

extension OldPauseBehaviour {
	public func toPauseBehaviour() -> PauseBehaviour {
		.init(mode: mode, duration: duration)
	}
}
