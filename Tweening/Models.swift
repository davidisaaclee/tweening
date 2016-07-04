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
	struct Edge {
		let left: Keypoint
		let right: Keypoint

		init(_ left: Keypoint, _ right: Keypoint) {
			self.left = left
			self.right = right
		}
	}

	typealias Power = CGFloat

	var keys: Set<Keypoint>

	var edges: Set<KeyField.Edge> {
		return Set(keys.flatMap { key -> [(Keypoint, Keypoint)] in
			return self.keys.flatMap { otherKey -> (Keypoint, Keypoint)? in
				guard key != otherKey else {
					return nil
				}
				return (key, otherKey)
			}
		}.map { (l, r) in KeyField.Edge(l, r) })
	}
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

extension KeyField.Edge: Hashable {
	var hashValue: Int {
		let sorted = [left, right].sorted { (l, r) in l.hashValue < r.hashValue }
		return "\(sorted[0].hashValue),\(sorted[1].hashValue)".hashValue

//		func compare(_ p1: CGPoint, _ p2: CGPoint) -> ComparisonResult {
//			// Creates a unique scalar out of a 2D point.
//			func pair(_ p: CGPoint) -> CGFloat {
//				return (p.x * 2 + (p.y * 2 - 1))
//			}
//
//			let p1ʹ = pair(p1)
//			let p2ʹ = pair(p2)
//
//			if p1ʹ == p2ʹ {
//				return .orderedSame
//			} else if p1ʹ > p2ʹ {
//				return .orderedDescending
//			} else {
//				return .orderedAscending
//			}
//		}
//
//		let sorted = [left, right].sorted { (lhs, rhs) -> Bool in
//			switch compare(lhs.position, rhs.position) {
//			case .orderedAscending:
//				return true
//
//			case .orderedDescending:
//				return false
//
//			case .orderedSame:
//				switch compare(lhs.value)
//			}
//		}
	}
}

func == (lhs: KeyField.Edge, rhs: KeyField.Edge) -> Bool {
	// eh
	return lhs.hashValue == rhs.hashValue
}
