import UIKit

struct Keypoint {
	var position: CGPoint
	var value: CGPoint
}

extension Keypoint: Hashable {
	var hashValue: Int {
		return "\(position.x),\(position.y),\(value.x),\(value.y)".hashValue
	}
}

func == (lhs: Keypoint, rhs: Keypoint) -> Bool {
	return (lhs.position == rhs.position) && (lhs.value == rhs.value)
}

struct KeyField {
	typealias Power = CGFloat

	var keys: Set<Keypoint>
}

extension KeyField {
	func power(for key: Keypoint, withInputAt inputPoint: CGPoint) -> Power {
		func calculateRawPower(for key: Keypoint) -> CGFloat {
			let distance = key.position.distanceTo(inputPoint)
			guard distance != 0 else {
				return CGFloat.infinity
			}
			return 1.0 / distance
		}

		let allRawPowers = keys.map(calculateRawPower)
		let combinedRawPowers = allRawPowers.reduce(0, combine: (+))

		let rawPowerForInputKey = calculateRawPower(for: key)

		return rawPowerForInputKey / combinedRawPowers
	}
}
