import VectorSwift

extension Vector where Self.Iterator.Element: Ring {
	static var unit: Self {
		return self.init(collection: [Self.Iterator.Element.multiplicationIdentity,
		                              Self.Iterator.Element.multiplicationIdentity])
	}
}
