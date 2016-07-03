import UIKit
import VectorSwift

class ViewController: UIViewController {

	let visualization = KeyfieldVisualization()

	private var inputBuffer: [CGPoint] = []
	private var bufferLength = 20

	override func viewDidLoad() {
		super.viewDidLoad()

		visualization.frame = view.bounds
		visualization.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		view.addSubview(visualization)

		func randomPoint(inRect rect: CGRect) -> CGPoint {
			return CGPoint(x: CGFloat(arc4random()).truncatingRemainder(dividingBy: rect.width) + rect.origin.x,
			               y: CGFloat(arc4random()).truncatingRemainder(dividingBy: rect.height) + rect.origin.y)
		}

		let margin: CGFloat = 30
		let bounds = visualization.bounds
			.insetBy(dx: margin, dy: margin)

		let keys = (0 ..< 3).map { index in
			return Keypoint(position: randomPoint(inRect: bounds),
			                value: randomPoint(inRect: bounds))
		}

		let keyfield = KeyField(keys: Set<Keypoint>(keys))
		visualization.keyfield = keyfield
	}


	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)

		guard let location = touches.first.map({ $0.location(in: self.visualization) }) else { return }
		pushInput(location)
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)

		guard let location = touches.first.map({ $0.location(in: self.visualization) }) else { return }
		pushInput(location)
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		pushInput(nil)
	}

	override func prefersStatusBarHidden() -> Bool {
		return true
	}

	func pushInput(_ point: CGPoint?) {
		guard let point = point else {
			inputBuffer.removeAll()
			visualization.inputPosition = nil
			visualization.inputDirection = nil
			return
		}

		inputBuffer.append(point)
		inputBuffer = Array(inputBuffer.suffix(bufferLength))

		visualization.inputPosition = point

		guard
			let first = inputBuffer.first,
			let last = inputBuffer.last
			else {
				return
		}

		visualization.inputDirection = (last - first).unit
	}
}

