import UIKit
import VectorSwift

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
	func power(for key: Keypoint, withInputAt point: CGPoint, towards direction: CGPoint) -> Power {
		func calculateRawPower(for key: Keypoint) -> CGFloat {
			let distance = key.position.distanceTo(point)
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

	func value(for inputPosition: CGPoint, towards direction: CGPoint) -> CGPoint {
		return keys
			.map { $0.value * self.power(for: $0, withInputAt: inputPosition, towards: direction) }
			.reduce(CGPoint.zero, combine: (+))
	}

	func directionalPower(for key: Keypoint, withInputAt position: CGPoint, towards direction: CGPoint) -> Power {
		let span = direction
		let vectorToProject = key.position - position

		let projectionOffset = span * (vectorToProject.dot(span) / span.dot(span))

		let projection = position + projectionOffset

		let s = CGPoint(x: (projection.x - position.x) / direction.x,
										y: (projection.y - position.y) / direction.y)

		if s.x.sign == .plus && s.y.sign == .plus {
			// Projection is on ray.
			let m = (key.position - projection).magnitude
			if m == 0 {
				return CGFloat.infinity
			} else {
				return 1.0 / m
			}
		} else {
			// Projection is on reflection of ray.
			return 0
		}
	}
}
