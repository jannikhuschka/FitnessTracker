import Foundation

protocol A: Equatable, Hashable, Codable, Identifiable {
	var number: Int {get set}
}

struct A1: A {
	var id: UUID
	func encode(to encoder: Encoder) throws {
	}
	init(from decoder: Decoder) throws {
		self.id = UUID()
	}
	init(number: Int = 0, id: UUID = UUID()) {
		self.number = number
		self.id = id
	}
	
	var number: Int = 0
}

struct A2: A {
	var id: UUID
	func encode(to encoder: Encoder) throws {
	}
	init(from decoder: Decoder) throws {
		self.id = UUID()
	}
	
	var number: Int = 0
}

struct SuperShit: Equatable, Hashable, Codable, Identifiable {
	static func == (lhs: SuperShit, rhs: SuperShit) -> Bool {
		lhs.id == rhs.id
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		for a in amk {
			hasher.combine(a)
		}
	}
	func encode(to encoder: Encoder) throws {
	}
	init(from decoder: Decoder) throws {
		self.id = UUID()
		self.amk = [A1()]
	}
	
	var id: UUID
//	var arr: [any A]
	var amk: [any A]
}
