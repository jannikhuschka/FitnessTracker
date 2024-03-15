import Foundation
import SwiftData

enum DataSchemaV1: VersionedSchema {
	static var versionIdentifier = Schema.Version(1, 0, 0)
	
	static var models: [any PersistentModel.Type] {
		[Training.self]
	}
}
