import UIKit

class ViewController: UIViewController {

	let visualization = KeyfieldVisualization()

	override func viewDidLoad() {
		super.viewDidLoad()

		visualization.frame = view.bounds
		visualization.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		view.addSubview(visualization)

		func randomPoint(inRect rect: CGRect) -> CGPoint {
			return CGPoint(x: CGFloat(arc4random()).truncatingRemainder(dividingBy: rect.width) + rect.origin.x,
			               y: CGFloat(arc4random()).truncatingRemainder(dividingBy: rect.height) + rect.origin.y)
		}

		let keys = (0 ..< 3).map { index in
			return Keypoint(position: randomPoint(inRect: self.visualization.bounds),
			                value: randomPoint(inRect: self.visualization.bounds))
		}

		let keyfield = KeyField(keys: Set<Keypoint>(keys))
		visualization.keyfield = keyfield
	}


	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)

		guard let location = touches.first.map({ $0.location(in: self.visualization) }) else { return }
		visualization.inputPosition = location
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)

		guard let location = touches.first.map({ $0.location(in: self.visualization) }) else { return }
		visualization.inputPosition = location
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)

		visualization.inputPosition = nil
	}
}

