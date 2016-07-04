import VectorSwift

extension Vector where Self.Iterator.Element: Ring {
	static var unit: Self {
		return self.init(collection: [Self.Iterator.Element.multiplicationIdentity,
		                              Self.Iterator.Element.multiplicationIdentity])
	}

	func dot<V: Vector where V.Iterator.Element == Self.Iterator.Element, Self.Iterator.Element: Ring>(_ otherVector: V) -> Self.Iterator.Element {
		return zip(self, otherVector)
			.map((*))
			.reduce(Self.Iterator.Element.additionIdentity, combine: (+))
	}
}


extension Vector where Self.Iterator.Element == CGFloat {
	func project(onto span: Self) -> Self {
		return span * (self.dot(span) / span.dot(span))
	}
}
