import SpriteKit

struct SpawnPoint {
    let position: CGPoint
    let isHighValue: Bool
}

struct KitchenLayout {
    let floorColor: UIColor
    let wallColor: UIColor
    let counterColor: UIColor
    let servingCounterColor: UIColor
    let wallRects: [CGRect]       // impassable walls
    let counterRects: [CGRect]    // impassable counters (prep)
    let servingRects: [CGRect]    // serving counters (high value food)
    let spawnPoints: [SpawnPoint]
    let playerStart: CGPoint
    let guardStarts: [CGPoint]
    let patrolPaths: [[CGPoint]]
}

class KitchenBuilder {

    // Scene is 834x390, anchor center (0,0)
    // Kitchen play area: x -400..400, y -165..170
    // HUD takes top 40px (y ~155..195)

    static func build(for restaurant: RestaurantType) -> KitchenLayout {
        switch restaurant {
        case .burgerBarn:    return burgerBarnLayout(restaurant)
        case .queenBurger:   return queenBurgerLayout(restaurant)
        case .freckles:      return frecklesLayout(restaurant)
        case .papaRoosters:  return papaRoostersLayout(restaurant)
        }
    }

    // MARK: - Layout 0: Burger Barn (standard grid)

    private static func burgerBarnLayout(_ r: RestaurantType) -> KitchenLayout {
        let wallThick: CGFloat = 14

        let walls: [CGRect] = [
            CGRect(x: -400, y: 140, width: 800, height: wallThick),
            // Bottom wall — wide center gap for entry
            CGRect(x: -400, y: -155, width: 310, height: wallThick),
            CGRect(x: 90, y: -155, width: 310, height: wallThick),
            CGRect(x: -400, y: -155, width: wallThick, height: 310),
            CGRect(x: 386, y: -155, width: wallThick, height: 310),
        ]

        // Counters — smaller and well-spaced, NO back prep table blocking entry
        let counters: [CGRect] = [
            // Left prep station (single, compact)
            CGRect(x: -340, y: -10, width: 90, height: 45),
            // Center grill island (smaller)
            CGRect(x: -60, y: 20, width: 120, height: 45),
            // Right fryer station (single, compact)
            CGRect(x: 250, y: -10, width: 90, height: 45),
            // Two small side prep tables at bottom (leave wide corridor)
            CGRect(x: -340, y: -100, width: 80, height: 35),
            CGRect(x: 260, y: -100, width: 80, height: 35),
        ]

        let serving: [CGRect] = [
            CGRect(x: -300, y: 80, width: 600, height: 45),
        ]

        let spawnPoints: [SpawnPoint] = [
            SpawnPoint(position: CGPoint(x: -180, y: 108), isHighValue: true),
            SpawnPoint(position: CGPoint(x: -60, y: 108), isHighValue: true),
            SpawnPoint(position: CGPoint(x: 60, y: 108), isHighValue: true),
            SpawnPoint(position: CGPoint(x: 180, y: 108), isHighValue: true),
            SpawnPoint(position: CGPoint(x: -295, y: 18), isHighValue: false),
            SpawnPoint(position: CGPoint(x: 0, y: 48), isHighValue: false),
            SpawnPoint(position: CGPoint(x: 295, y: 18), isHighValue: false),
            SpawnPoint(position: CGPoint(x: -300, y: -80), isHighValue: false),
            SpawnPoint(position: CGPoint(x: 300, y: -80), isHighValue: false),
        ]

        let guardStarts = [
            CGPoint(x: -280, y: 110),
            CGPoint(x: 280, y: 110),
            CGPoint(x: 0, y: 50),
        ]

        let patrolPaths: [[CGPoint]] = [
            [CGPoint(x: -280, y: 110), CGPoint(x: -280, y: -50), CGPoint(x: -130, y: -50), CGPoint(x: -130, y: 110)],
            [CGPoint(x: 280, y: 110), CGPoint(x: 280, y: -50), CGPoint(x: 130, y: -50), CGPoint(x: 130, y: 110)],
            [CGPoint(x: 0, y: 50), CGPoint(x: -100, y: -80), CGPoint(x: 100, y: -80), CGPoint(x: 0, y: 50)],
        ]

        return KitchenLayout(
            floorColor: r.floorColor,
            wallColor: r.wallColor,
            counterColor: r.counterColor,
            servingCounterColor: r.servingCounterColor,
            wallRects: walls,
            counterRects: counters,
            servingRects: serving,
            spawnPoints: spawnPoints,
            playerStart: CGPoint(x: 0, y: -60),
            guardStarts: guardStarts,
            patrolPaths: patrolPaths
        )
    }

    // MARK: - Layout 1: Queen Burger (flame-grill theme, more open)

    private static func queenBurgerLayout(_ r: RestaurantType) -> KitchenLayout {
        let walls: [CGRect] = [
            CGRect(x: -400, y: 140, width: 800, height: 14),
            CGRect(x: -400, y: -155, width: 280, height: 14),
            CGRect(x: 120, y: -155, width: 280, height: 14),
            CGRect(x: -400, y: -155, width: 14, height: 310),
            CGRect(x: 386, y: -155, width: 14, height: 310),
        ]

        let counters: [CGRect] = [
            // Left prep (compact)
            CGRect(x: -360, y: 10, width: 100, height: 40),
            // Two grill stations (spread out)
            CGRect(x: -120, y: 20, width: 70, height: 40),
            CGRect(x: 50, y: 20, width: 70, height: 40),
            // Right storage (compact)
            CGRect(x: 270, y: 10, width: 90, height: 50),
        ]

        let serving: [CGRect] = [
            CGRect(x: -280, y: 80, width: 560, height: 40),
        ]

        let spawnPoints: [SpawnPoint] = [
            SpawnPoint(position: CGPoint(x: -180, y: 105), isHighValue: true),
            SpawnPoint(position: CGPoint(x: 0, y: 105), isHighValue: true),
            SpawnPoint(position: CGPoint(x: 180, y: 105), isHighValue: true),
            SpawnPoint(position: CGPoint(x: -310, y: 35), isHighValue: false),
            SpawnPoint(position: CGPoint(x: -85, y: 45), isHighValue: false),
            SpawnPoint(position: CGPoint(x: 85, y: 45), isHighValue: false),
            SpawnPoint(position: CGPoint(x: 315, y: 40), isHighValue: false),
        ]

        let guardStarts = [
            CGPoint(x: -300, y: 100),
            CGPoint(x: 300, y: 100),
            CGPoint(x: 0, y: 0),
        ]

        let patrolPaths: [[CGPoint]] = [
            [CGPoint(x: -300, y: 100), CGPoint(x: -300, y: -80), CGPoint(x: -80, y: -80), CGPoint(x: -80, y: 100)],
            [CGPoint(x: 300, y: 100), CGPoint(x: 300, y: -80), CGPoint(x: 100, y: -80), CGPoint(x: 100, y: 100)],
            [CGPoint(x: 0, y: 50), CGPoint(x: -100, y: -50), CGPoint(x: 100, y: -50)],
        ]

        return KitchenLayout(
            floorColor: r.floorColor, wallColor: r.wallColor,
            counterColor: r.counterColor, servingCounterColor: r.servingCounterColor,
            wallRects: walls, counterRects: counters, servingRects: serving,
            spawnPoints: spawnPoints, playerStart: CGPoint(x: 0, y: -60),
            guardStarts: guardStarts, patrolPaths: patrolPaths
        )
    }

    // MARK: - Layout 2: Freckle's (maze-ier, square counters)

    private static func frecklesLayout(_ r: RestaurantType) -> KitchenLayout {
        let walls: [CGRect] = [
            CGRect(x: -400, y: 140, width: 800, height: 14),
            CGRect(x: -400, y: -155, width: 280, height: 14),
            CGRect(x: 120, y: -155, width: 280, height: 14),
            CGRect(x: -400, y: -155, width: 14, height: 310),
            CGRect(x: 386, y: -155, width: 14, height: 310),
        ]

        let counters: [CGRect] = [
            CGRect(x: -360, y: 10, width: 120, height: 35),
            CGRect(x: -80, y: 20, width: 160, height: 35),
            CGRect(x: 250, y: 10, width: 110, height: 35),
            // Small side tables
            CGRect(x: -360, y: -80, width: 80, height: 30),
            CGRect(x: 280, y: -80, width: 80, height: 30),
        ]

        let serving: [CGRect] = [
            CGRect(x: -340, y: 80, width: 680, height: 40),
        ]

        let spawnPoints: [SpawnPoint] = [
            SpawnPoint(position: CGPoint(x: -200, y: 105), isHighValue: true),
            SpawnPoint(position: CGPoint(x: 0, y: 105), isHighValue: true),
            SpawnPoint(position: CGPoint(x: 200, y: 105), isHighValue: true),
            SpawnPoint(position: CGPoint(x: -300, y: 32), isHighValue: false),
            SpawnPoint(position: CGPoint(x: 0, y: 42), isHighValue: false),
            SpawnPoint(position: CGPoint(x: 305, y: 32), isHighValue: false),
            SpawnPoint(position: CGPoint(x: -320, y: -62), isHighValue: false),
            SpawnPoint(position: CGPoint(x: 320, y: -62), isHighValue: false),
        ]

        let guardStarts = [
            CGPoint(x: -300, y: 100),
            CGPoint(x: 300, y: 100),
            CGPoint(x: 0, y: 50),
        ]

        let patrolPaths: [[CGPoint]] = [
            [CGPoint(x: -300, y: 100), CGPoint(x: -300, y: -100), CGPoint(x: -50, y: -100), CGPoint(x: -50, y: 100)],
            [CGPoint(x: 300, y: 100), CGPoint(x: 300, y: -100), CGPoint(x: 50, y: -100), CGPoint(x: 50, y: 100)],
            [CGPoint(x: 0, y: 50), CGPoint(x: -150, y: -80), CGPoint(x: 150, y: -80)],
        ]

        return KitchenLayout(
            floorColor: r.floorColor, wallColor: r.wallColor,
            counterColor: r.counterColor, servingCounterColor: r.servingCounterColor,
            wallRects: walls, counterRects: counters, servingRects: serving,
            spawnPoints: spawnPoints, playerStart: CGPoint(x: 0, y: -60),
            guardStarts: guardStarts, patrolPaths: patrolPaths
        )
    }

    // MARK: - Layout 3: Papa Rooster's (chicken fryers in corners)

    private static func papaRoostersLayout(_ r: RestaurantType) -> KitchenLayout {
        let walls: [CGRect] = [
            CGRect(x: -400, y: 140, width: 800, height: 14),
            // Bottom wall — wide center gap for entry
            CGRect(x: -400, y: -155, width: 310, height: 14),
            CGRect(x: 90, y: -155, width: 310, height: 14),
            CGRect(x: -400, y: -155, width: 14, height: 310),
            CGRect(x: 386, y: -155, width: 14, height: 310),
        ]

        let counters: [CGRect] = [
            // Compact fryer stations in corners (smaller, won't block paths)
            CGRect(x: -370, y: 60, width: 60, height: 50),   // top-left fryer
            CGRect(x: 310, y: 60, width: 60, height: 50),    // top-right fryer
            CGRect(x: -370, y: -110, width: 60, height: 45),  // bottom-left fryer
            CGRect(x: 310, y: -110, width: 60, height: 45),   // bottom-right fryer
            // Smaller center prep island
            CGRect(x: -60, y: 0, width: 120, height: 40),
        ]

        let serving: [CGRect] = [
            CGRect(x: -250, y: 80, width: 500, height: 42),
        ]

        let spawnPoints: [SpawnPoint] = [
            SpawnPoint(position: CGPoint(x: -150, y: 108), isHighValue: true),
            SpawnPoint(position: CGPoint(x: 0, y: 108), isHighValue: true),
            SpawnPoint(position: CGPoint(x: 150, y: 108), isHighValue: true),
            SpawnPoint(position: CGPoint(x: -340, y: 90), isHighValue: false),
            SpawnPoint(position: CGPoint(x: 340, y: 90), isHighValue: false),
            SpawnPoint(position: CGPoint(x: -340, y: -85), isHighValue: false),
            SpawnPoint(position: CGPoint(x: 340, y: -85), isHighValue: false),
            SpawnPoint(position: CGPoint(x: -10, y: 25), isHighValue: false),
            SpawnPoint(position: CGPoint(x: 50, y: 25), isHighValue: false),
        ]

        let guardStarts = [
            CGPoint(x: -280, y: 100),
            CGPoint(x: 280, y: 100),
            CGPoint(x: 0, y: 50),
        ]

        let patrolPaths: [[CGPoint]] = [
            [CGPoint(x: -280, y: 100), CGPoint(x: -280, y: -80), CGPoint(x: -100, y: -80), CGPoint(x: -100, y: 100)],
            [CGPoint(x: 280, y: 100), CGPoint(x: 280, y: -80), CGPoint(x: 100, y: -80), CGPoint(x: 100, y: 100)],
            [CGPoint(x: 0, y: 50), CGPoint(x: 0, y: -100), CGPoint(x: -180, y: -100), CGPoint(x: 180, y: -100)],
        ]

        return KitchenLayout(
            floorColor: r.floorColor, wallColor: r.wallColor,
            counterColor: r.counterColor, servingCounterColor: r.servingCounterColor,
            wallRects: walls, counterRects: counters, servingRects: serving,
            spawnPoints: spawnPoints, playerStart: CGPoint(x: 0, y: -60),
            guardStarts: guardStarts, patrolPaths: patrolPaths
        )
    }

    // MARK: - Node builder from layout

    // Door gap configuration
    private static let doorGapY: CGFloat = -10   // center of door gap
    private static let doorGapHeight: CGFloat = 60 // height of gap

    static func buildKitchenNode(layout: KitchenLayout, restaurant: RestaurantType) -> SKNode {
        let container = SKNode()
        container.name = "kitchen"

        // Floor — full play area
        let floor = SKShapeNode(rectOf: CGSize(width: 800, height: 310))
        floor.fillColor = layout.floorColor
        floor.strokeColor = .clear
        floor.position = CGPoint(x: 0, y: -8)
        floor.zPosition = -10
        container.addChild(floor)

        // Floor tile lines (decorative grid)
        let tileSize: CGFloat = 60
        for col in stride(from: CGFloat(-400), through: 400, by: tileSize) {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: col, y: -162))
            path.addLine(to: CGPoint(x: col, y: 155))
            line.path = path
            line.strokeColor = UIColor(white: 0.0, alpha: 0.06)
            line.lineWidth = 1
            line.zPosition = -9
            container.addChild(line)
        }
        for row in stride(from: CGFloat(-160), through: 155, by: tileSize) {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -400, y: row))
            path.addLine(to: CGPoint(x: 400, y: row))
            line.path = path
            line.strokeColor = UIColor(white: 0.0, alpha: 0.06)
            line.lineWidth = 1
            line.zPosition = -9
            container.addChild(line)
        }

        let hasLeftDoor = restaurant.leftNeighbor != nil
        let hasRightDoor = restaurant.rightNeighbor != nil

        // Walls — split side walls for doors
        for rect in layout.wallRects {
            let isSideWall = (rect.height >= 300) &&
                (rect.minX <= -390 || rect.minX >= 380)
            let isLeftWall = isSideWall && rect.minX <= -390
            let isRightWall = isSideWall && rect.minX >= 380

            if isLeftWall && hasLeftDoor {
                // Split left wall into top + bottom segments with door gap
                let gapBottom = doorGapY - doorGapHeight / 2
                let gapTop = doorGapY + doorGapHeight / 2
                let bottomSeg = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: gapBottom - rect.minY)
                let topSeg = CGRect(x: rect.minX, y: gapTop, width: rect.width, height: rect.maxY - gapTop)
                addWall(to: container, rect: bottomSeg, color: layout.wallColor)
                addWall(to: container, rect: topSeg, color: layout.wallColor)
                addDoor(to: container, side: .left, neighbor: restaurant.leftNeighbor!, wallColor: layout.wallColor)
            } else if isRightWall && hasRightDoor {
                let gapBottom = doorGapY - doorGapHeight / 2
                let gapTop = doorGapY + doorGapHeight / 2
                let bottomSeg = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: gapBottom - rect.minY)
                let topSeg = CGRect(x: rect.minX, y: gapTop, width: rect.width, height: rect.maxY - gapTop)
                addWall(to: container, rect: bottomSeg, color: layout.wallColor)
                addWall(to: container, rect: topSeg, color: layout.wallColor)
                addDoor(to: container, side: .right, neighbor: restaurant.rightNeighbor!, wallColor: layout.wallColor)
            } else {
                addWall(to: container, rect: rect, color: layout.wallColor)
            }
        }

        // Regular counters
        for rect in layout.counterRects {
            addKitchenCounter(to: container, rect: rect, fill: layout.counterColor,
                              accent: restaurant.primaryColor, isServing: false)
        }

        // Serving counters (different color, labeled)
        for rect in layout.servingRects {
            addKitchenCounter(to: container, rect: rect, fill: layout.servingCounterColor,
                              accent: restaurant.secondaryColor, isServing: true)
        }

        // Entry mat (where player enters)
        let mat = SKShapeNode(rectOf: CGSize(width: 80, height: 18))
        mat.fillColor = UIColor(red: 0.3, green: 0.6, blue: 0.35, alpha: 0.7)
        mat.strokeColor = .black
        mat.lineWidth = 2
        mat.position = CGPoint(x: 0, y: -148)
        mat.zPosition = -8
        container.addChild(mat)

        let matLabel = SKLabelNode(text: "STAFF ONLY")
        matLabel.fontName = "AvenirNext-Bold"
        matLabel.fontSize = 6
        matLabel.fontColor = UIColor(white: 1.0, alpha: 0.8)
        matLabel.horizontalAlignmentMode = .center
        matLabel.verticalAlignmentMode = .center
        matLabel.position = CGPoint(x: 0, y: -148)
        matLabel.zPosition = -7
        container.addChild(matLabel)

        return container
    }

    private static func makeCounter(rect: CGRect, fill: UIColor, stroke: UIColor, lineWidth: CGFloat) -> SKShapeNode {
        let node = SKShapeNode(rect: rect, cornerRadius: 4)
        node.fillColor = fill
        node.strokeColor = stroke
        node.lineWidth = lineWidth
        return node
    }

    enum DoorSide { case left, right }

    private static func addWall(to parent: SKNode, rect: CGRect, color: UIColor) {
        let wall = makeCounter(rect: rect, fill: color, stroke: .black, lineWidth: 3)
        wall.physicsBody = SKPhysicsBody(rectangleOf: rect.size,
                                         center: CGPoint(x: rect.midX, y: rect.midY))
        wall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        wall.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.guard_
        wall.physicsBody?.contactTestBitMask = PhysicsCategory.none
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.restitution = 0
        parent.addChild(wall)
    }

    private static func addDoor(to parent: SKNode, side: DoorSide, neighbor: RestaurantType, wallColor: UIColor) {
        let x: CGFloat = side == .left ? -400 : 393
        let triggerX: CGFloat = side == .left ? -395 : 390
        let arrowDir: CGFloat = side == .left ? -1 : 1

        // Door frame visual
        let frameRect = CGRect(x: x - 3, y: doorGapY - doorGapHeight / 2, width: 20, height: doorGapHeight)
        let frame = SKShapeNode(rect: frameRect, cornerRadius: 3)
        frame.fillColor = neighbor.primaryColor.withAlphaComponent(0.35)
        frame.strokeColor = neighbor.primaryColor
        frame.lineWidth = 2.5
        frame.zPosition = 1
        parent.addChild(frame)

        // Arrow indicator
        let arrow = SKLabelNode(text: side == .left ? "◀" : "▶")
        arrow.fontSize = 18
        arrow.fontColor = neighbor.primaryColor
        arrow.horizontalAlignmentMode = .center
        arrow.verticalAlignmentMode = .center
        arrow.position = CGPoint(x: triggerX, y: doorGapY + 8)
        arrow.zPosition = 3
        parent.addChild(arrow)

        // Neighbor name label
        let nameLabel = SKLabelNode(text: neighbor.displayName)
        nameLabel.fontName = "AvenirNext-Bold"
        nameLabel.fontSize = 7
        nameLabel.fontColor = neighbor.primaryColor
        nameLabel.horizontalAlignmentMode = .center
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = CGPoint(x: triggerX, y: doorGapY - 12)
        nameLabel.zPosition = 3
        parent.addChild(nameLabel)

        // Pulse animation on arrow
        arrow.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: arrowDir * 4, y: 0, duration: 0.5),
            SKAction.moveBy(x: arrowDir * -4, y: 0, duration: 0.5)
        ])))

        // Door trigger zone (sensor body — detects contact but no collision)
        let trigger = SKShapeNode(rectOf: CGSize(width: 20, height: doorGapHeight - 10))
        trigger.fillColor = .clear
        trigger.strokeColor = .clear
        trigger.position = CGPoint(x: triggerX, y: doorGapY)
        trigger.zPosition = 0
        trigger.name = side == .left ? "doorLeft" : "doorRight"
        trigger.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: doorGapHeight - 10))
        trigger.physicsBody?.categoryBitMask = PhysicsCategory.door
        trigger.physicsBody?.contactTestBitMask = PhysicsCategory.player
        trigger.physicsBody?.collisionBitMask = PhysicsCategory.none
        trigger.physicsBody?.isDynamic = false
        parent.addChild(trigger)
    }

    private static func addKitchenCounter(to parent: SKNode, rect: CGRect, fill: UIColor, accent: UIColor, isServing: Bool) {
        // Main counter surface
        let node = SKShapeNode(rect: rect, cornerRadius: 5)
        node.fillColor = fill
        node.strokeColor = .black
        node.lineWidth = 3
        node.zPosition = 1
        parent.addChild(node)

        // Counter edge highlight
        let shrunk = rect.insetBy(dx: 4, dy: 4)
        let highlight = SKShapeNode(rect: shrunk, cornerRadius: 3)
        highlight.fillColor = .clear
        highlight.strokeColor = UIColor(white: 1.0, alpha: 0.25)
        highlight.lineWidth = 2
        highlight.zPosition = 2
        parent.addChild(highlight)

        if isServing {
            // Serving counter label
            let label = SKLabelNode(text: "ORDERS")
            label.fontName = "AvenirNext-Heavy"
            label.fontSize = 8
            label.fontColor = accent
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: rect.midX, y: rect.midY)
            label.zPosition = 3
            parent.addChild(label)
        }

        // Physics body
        node.physicsBody = SKPhysicsBody(rectangleOf: rect.size,
                                         center: CGPoint(x: rect.midX, y: rect.midY))
        node.physicsBody?.categoryBitMask = PhysicsCategory.counter
        node.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.guard_
        node.physicsBody?.contactTestBitMask = PhysicsCategory.none
        node.physicsBody?.isDynamic = false
        node.physicsBody?.restitution = 0
    }
}
