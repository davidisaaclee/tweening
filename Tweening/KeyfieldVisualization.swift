import UIKit
import VectorSwift

class KeyfieldVisualization: UIView {

	var canvasColor: UIColor = #colorLiteral(red: 0.9672742486, green: 0.9354698072, blue: 0.7717658872, alpha: 1)

	var keyPositionColor: UIColor = #colorLiteral(red: 1, green: 0.2095748107, blue: 0.2320909677, alpha: 1)
	var inputPositionColor: UIColor = #colorLiteral(red: 0.4137221559, green: 0.4878804722, blue: 1, alpha: 1)
	var connectionColor: UIColor = #colorLiteral(red: 0.9446166754, green: 0.6509571671, blue: 0.1558967829, alpha: 1)
	var radialColor: UIColor = #colorLiteral(red: 0.9672742486, green: 0.8225458264, blue: 0.4772382379, alpha: 1)
	var keyValueColor: UIColor = #colorLiteral(red: 0.4776530862, green: 0.2292086482, blue: 0.9591622353, alpha: 1)
	var keyValueConnectionsColor: UIColor = #colorLiteral(red: 0.4776530862, green: 0.2292086482, blue: 0.9591622353, alpha: 1)
	var outputColor: UIColor = #colorLiteral(red: 0.2818343937, green: 0.5693024397, blue: 0.1281824261, alpha: 1)
	var trajectoryColor: UIColor = #colorLiteral(red: 0.4120420814, green: 0.8022739887, blue: 0.9693969488, alpha: 1)
	var projectionColor: UIColor = #colorLiteral(red: 0.4120420814, green: 0.8022739887, blue: 0.9693969488, alpha: 1)

	var keyfield: KeyField? {
		didSet {
			setNeedsDisplay()
		}
	}

	var inputPosition: CGPoint? {
		didSet {
			setNeedsDisplay()
		}
	}

	var inputDirection: CGPoint? {
		didSet {
			setNeedsDisplay()
		}
	}

  // MARK: -

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
  }

  // MARK: Public methods

	override func draw(_ rect: CGRect) {
		super.draw(rect)

		canvasColor.setFill()
		UIBezierPath(rect: rect).fill()

		drawKeyValueConnections()
		drawPowerConnections()
		drawTrajectory()
		drawRadials()
		drawKeypointProjectionsOntoTrajectory()

		drawKeys()
		drawKeyValues()

		drawInput()
		drawOutput()
	}

  // MARK: Helpers

  private func setup() {}

	private func drawKeys() {
		guard let keyfield = keyfield else {
			return
		}

		keyPositionColor.setFill()
		let radius: CGFloat = 5

		keyfield.keys
			.map { keypoint -> UIBezierPath in
				let rect = CGRect(origin: keypoint.position - CGPoint.unit * radius,
				                  size: CGSize.unit * radius * 2)

				return UIBezierPath(ovalIn: rect)
			}
			.forEach { (path) in
				path.fill()
		}
	}

	private func drawInput() {
		guard let inputPosition = inputPosition else {
			return
		}

		inputPositionColor.setFill()

		let radius: CGFloat = 15
		let path = UIBezierPath(center: inputPosition, radius: radius)

		path.fill()
	}

	private func drawKeyValueConnections() {
		guard let keyfield = keyfield else {
			return
		}

		keyValueConnectionsColor.setStroke()

		keyfield.keys
			.map { key -> UIBezierPath in
				let path = UIBezierPath()
				path.move(to: key.value)
				path.addLine(to: key.position)
				path.setLineDash([4, 8], count: 2, phase: 0)
				return path
			}.forEach { $0.stroke() }
	}

	private func drawPowerConnections() {
		guard
			let keyfield = keyfield,
			let inputPosition = inputPosition,
			let inputDirection = inputDirection
			else {
			return
		}

		keyfield.keys
			.map { key -> (Keypoint, UIBezierPath) in
				let path = UIBezierPath()
				path.move(to: inputPosition)
				path.addLine(to: key.position)
				path.setLineDash([3, 3], count: 2, phase: 0)
				return (key, path)
			}.forEach {
				let power = keyfield.power(for: $0.0, withInputAt: inputPosition, towards: inputDirection)
				self.connectionColor.withAlphaComponent(power * 2).setStroke()
				$0.1.stroke()
			}
	}

	private func drawRadials() {
//		guard
//			let inputPosition = inputPosition,
//			let keyfield = keyfield
//			else {
//				return
//		}
//
//		radialColor.setStroke()
//
//		keyfield.keys.map { key -> (CGPoint, KeyField.Power) in
//			(key.value, keyfield.power(for: key, withInputAt: inputPosition))
//		}.forEach { (position, power) in
//			let radius: CGFloat = 200 * power
//			let path = UIBezierPath(center: position, radius: radius)
//
//			path.stroke()
//		}

		guard
			let inputPosition = inputPosition,
			let inputDirection = inputDirection,
			let keyfield = keyfield
			else {
				return
		}

		radialColor.setStroke()

		keyfield.keys.map { key -> (CGPoint, KeyField.Power) in
			(key.position, keyfield.directionalPower(for: key, withInputAt: inputPosition, towards: inputDirection))
		}.forEach { (position, power) in
			let radius: CGFloat = 500 * power
			let path = UIBezierPath(center: position, radius: radius)

			path.stroke()
		}
	}

	private func drawKeyValues() {
		guard let keyfield = keyfield else {
			return
		}

		keyValueColor.setFill()

		keyfield.keys
			.map { UIBezierPath(center: $0.value, radius: 5) }
			.forEach { $0.fill() }
	}

	private func drawOutput() {
		guard
			let keyfield = keyfield,
			let inputPosition = inputPosition,
			let inputDirection = inputDirection
			else {
				return
		}

		outputColor.setStroke()


		let path = UIBezierPath(center: keyfield.value(for: inputPosition, towards: inputDirection),
		                        radius: 10)
		path.stroke()
	}

	private func drawTrajectory() {
		guard
			let inputPosition = inputPosition,
			let inputDirection = inputDirection
			else {
				return
		}

		trajectoryColor.setStroke()

		let path = UIBezierPath()
		path.move(to: inputPosition)
		path.addLine(to: inputPosition + inputDirection * bounds.width * bounds.height)
		path.stroke()
	}

	private func drawKeypointProjectionsOntoTrajectory() {
		guard
			let inputPosition = inputPosition,
			let inputDirection = inputDirection,
			let keyfield = keyfield
			else {
				return
		}

		projectionColor.set()

		keyfield.keys
			.map { key -> (CGPoint, CGPoint) in
				let span = inputDirection
				let vectorToProject = key.position - inputPosition

				let projectionOffset = span * (vectorToProject.dot(span) / span.dot(span))

				return (key.position, projectionOffset + inputPosition)
			}.filter { (keyPosition, projection) in
				// Filter out everything that's not on the correct side of the trajectory ray.

				// projection = s * inputDirection + inputPosition
				// I want to know if `s` is positive.
				let s = CGPoint(x: (projection.x - inputPosition.x) / inputDirection.x,
				                y: (projection.y - inputPosition.y) / inputDirection.y)

				return s.x.sign == .plus
						&& s.y.sign == .plus
			}.forEach { (elm) in
				let (keyPosition, projectionPoint) = elm

				let path = UIBezierPath(center: projectionPoint, radius: 3)
				path.fill()

				let connection = UIBezierPath()
				connection.move(to: keyPosition)
				connection.addLine(to: projectionPoint)
				connection.stroke()
			}
	}

}

private func angle(between v1: CGPoint, and v2: CGPoint) -> CGFloat {
	return v1.dot(v2) / (v1.magnitude * v2.magnitude)
}


extension UIBezierPath {
	convenience init(center: CGPoint, radius: CGFloat) {
		let rect = CGRect(origin: center - CGPoint.unit * radius,
		                  size: CGSize.unit * radius * 2)
		self.init(ovalIn: rect)
	}
}
