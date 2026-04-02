import Foundation

struct PhysicsCategory {
    static let none:    UInt32 = 0
    static let player:  UInt32 = 0x1 << 0  // 1
    static let guard_:  UInt32 = 0x1 << 1  // 2
    static let food:    UInt32 = 0x1 << 2  // 4
    static let wall:    UInt32 = 0x1 << 3  // 8
    static let counter: UInt32 = 0x1 << 4  // 16
    static let door:    UInt32 = 0x1 << 5  // 32
}
