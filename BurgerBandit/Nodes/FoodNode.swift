import SpriteKit

class FoodNode: SKNode {

    let foodType: FoodType
    private var mainShape: SKShapeNode!

    init(type: FoodType) {
        self.foodType = type
        super.init()
        buildVisual()
        setupPhysics()
        animateAppear()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func buildVisual() {
        switch foodType {
        case .completeBurger:
            buildBurger()
        case .fries:
            buildFries()
        case .rawPatty:
            buildRawPatty()
        case .bun:
            buildBun()
        case .condimentPacket:
            buildCondiment()
        case .chickenPiece:
            buildChicken()
        case .softDrink:
            buildDrink()
        case .veggie:
            buildVeggie()
        }

        // Floating label for high-value and veggie items
        if foodType.isHighValue || foodType.isVegetable {
            let label = SKLabelNode(text: "\(foodType.points)pts")
            label.fontName = "AvenirNext-Heavy"
            label.fontSize = foodType.isVegetable ? 10 : 8
            label.fontColor = foodType.isVegetable
                ? UIColor(red: 0.1, green: 0.8, blue: 0.2, alpha: 1)
                : UIColor(red: 0.95, green: 0.8, blue: 0.0, alpha: 1)
            label.position = CGPoint(x: 0, y: 22)
            label.zPosition = 5
            addChild(label)

            let bob = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 3, duration: 0.6),
                SKAction.moveBy(x: 0, y: -3, duration: 0.6)
            ])
            label.run(SKAction.repeatForever(bob))
        }
    }

    // MARK: - Food visual builders

    private func buildBurger() {
        // Sesame bun (top view = stacked circles)
        let bun = SKShapeNode(circleOfRadius: 16)
        bun.fillColor = UIColor(red: 0.9, green: 0.7, blue: 0.35, alpha: 1)
        bun.strokeColor = .black
        bun.lineWidth = 3
        bun.zPosition = 1
        addChild(bun)
        mainShape = bun

        // Sesame seeds
        for i in 0..<5 {
            let angle = CGFloat(i) / 5 * 2 * .pi + 0.2
            let r: CGFloat = 8
            let seed = SKShapeNode(ellipseOf: CGSize(width: 4, height: 2.5))
            seed.fillColor = UIColor(red: 0.95, green: 0.92, blue: 0.7, alpha: 1)
            seed.strokeColor = .clear
            seed.position = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
            seed.zRotation = angle
            seed.zPosition = 2
            addChild(seed)
        }

        // Patty peeking out
        let patty = SKShapeNode(circleOfRadius: 13)
        patty.fillColor = UIColor(red: 0.6, green: 0.3, blue: 0.1, alpha: 1)
        patty.strokeColor = .black
        patty.lineWidth = 2
        patty.position = CGPoint(x: 2, y: -2)
        patty.zPosition = 0
        addChild(patty)

        // Lettuce ring
        let lettuce = SKShapeNode(circleOfRadius: 15)
        lettuce.fillColor = .clear
        lettuce.strokeColor = UIColor(red: 0.25, green: 0.75, blue: 0.25, alpha: 0.8)
        lettuce.lineWidth = 4
        lettuce.position = CGPoint(x: 1, y: -1)
        lettuce.zPosition = 0.5
        addChild(lettuce)
    }

    private func buildFries() {
        // Fry container (red box top view)
        let boxPath = UIBezierPath(roundedRect: CGRect(x: -12, y: -14, width: 24, height: 28), cornerRadius: 3)
        let box = SKShapeNode(path: boxPath.cgPath)
        box.fillColor = UIColor(red: 0.9, green: 0.15, blue: 0.15, alpha: 1)
        box.strokeColor = .black
        box.lineWidth = 3
        box.zPosition = 1
        addChild(box)
        mainShape = box

        // Fry sticks sticking out top
        for i in 0..<5 {
            let x = CGFloat(i) * 5 - 10
            let height = CGFloat.random(in: 14...22)
            let fryPath = UIBezierPath(roundedRect: CGRect(x: x - 1.5, y: 2, width: 4, height: height), cornerRadius: 2)
            let fry = SKShapeNode(path: fryPath.cgPath)
            fry.fillColor = UIColor(red: 1.0, green: 0.88, blue: 0.3, alpha: 1)
            fry.strokeColor = .black
            fry.lineWidth = 1.5
            fry.zPosition = 2
            addChild(fry)
        }
    }

    private func buildRawPatty() {
        mainShape = SKShapeNode(circleOfRadius: 14)
        mainShape.fillColor = UIColor(red: 0.85, green: 0.45, blue: 0.35, alpha: 1)
        mainShape.strokeColor = .black
        mainShape.lineWidth = 3
        addChild(mainShape)
        // Pink squiggles for raw meat texture
        for i in 0..<3 {
            let line = UIBezierPath()
            let startX = CGFloat(i - 1) * 7 - 4
            line.move(to: CGPoint(x: startX, y: -6))
            line.addQuadCurve(to: CGPoint(x: startX + 4, y: 6), controlPoint: CGPoint(x: startX + 8, y: 0))
            let vein = SKShapeNode(path: line.cgPath)
            vein.strokeColor = UIColor(red: 0.95, green: 0.7, blue: 0.65, alpha: 0.7)
            vein.lineWidth = 1.5
            vein.zPosition = 2
            addChild(vein)
        }
    }

    private func buildBun() {
        mainShape = SKShapeNode(circleOfRadius: 14)
        mainShape.fillColor = UIColor(red: 0.95, green: 0.82, blue: 0.55, alpha: 1)
        mainShape.strokeColor = .black
        mainShape.lineWidth = 3
        addChild(mainShape)
        // Shine spot
        let shine = SKShapeNode(ellipseOf: CGSize(width: 8, height: 5))
        shine.fillColor = UIColor(white: 1.0, alpha: 0.4)
        shine.strokeColor = .clear
        shine.position = CGPoint(x: -3, y: 5)
        shine.zPosition = 2
        addChild(shine)
    }

    private func buildCondiment() {
        // Ketchup packet — top-down view
        let packetPath = UIBezierPath(roundedRect: CGRect(x: -7, y: -12, width: 14, height: 24), cornerRadius: 4)
        mainShape = SKShapeNode(path: packetPath.cgPath)
        mainShape.fillColor = UIColor(red: 0.92, green: 0.15, blue: 0.12, alpha: 1)
        mainShape.strokeColor = .black
        mainShape.lineWidth = 2.5
        addChild(mainShape)
        // White label strip
        let label = SKShapeNode(rectOf: CGSize(width: 10, height: 9))
        label.fillColor = UIColor(white: 1.0, alpha: 0.9)
        label.strokeColor = .black
        label.lineWidth = 1
        label.zPosition = 2
        addChild(label)
    }

    private func buildChicken() {
        // Chicken strip — irregular oval
        let path = UIBezierPath(ovalIn: CGRect(x: -14, y: -9, width: 28, height: 18))
        mainShape = SKShapeNode(path: path.cgPath)
        mainShape.fillColor = UIColor(red: 0.98, green: 0.75, blue: 0.25, alpha: 1)
        mainShape.strokeColor = .black
        mainShape.lineWidth = 3
        addChild(mainShape)
        // Crispy texture dots
        for _ in 0..<6 {
            let dot = SKShapeNode(circleOfRadius: 2)
            dot.fillColor = UIColor(red: 0.75, green: 0.5, blue: 0.1, alpha: 0.7)
            dot.strokeColor = .clear
            dot.position = CGPoint(x: CGFloat.random(in: -10...10), y: CGFloat.random(in: -5...5))
            dot.zPosition = 2
            addChild(dot)
        }
    }

    private func buildDrink() {
        // Cup from top — circle with cross straw
        mainShape = SKShapeNode(circleOfRadius: 13)
        mainShape.fillColor = UIColor(red: 0.35, green: 0.7, blue: 0.95, alpha: 1)
        mainShape.strokeColor = .black
        mainShape.lineWidth = 3
        addChild(mainShape)

        // Straw
        let strawPath = UIBezierPath(roundedRect: CGRect(x: 4, y: -15, width: 5, height: 20), cornerRadius: 2)
        let straw = SKShapeNode(path: strawPath.cgPath)
        straw.fillColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1)
        straw.strokeColor = .black
        straw.lineWidth = 1.5
        straw.zPosition = 3
        addChild(straw)

        // Lid ring
        let lid = SKShapeNode(circleOfRadius: 13)
        lid.fillColor = .clear
        lid.strokeColor = UIColor(red: 0.15, green: 0.45, blue: 0.8, alpha: 1)
        lid.lineWidth = 4
        lid.zPosition = 2
        addChild(lid)
    }

    private func buildVeggie() {
        // Leafy green — jagged circle
        let leafPath = UIBezierPath()
        let n = 12
        let outerR: CGFloat = 16
        let innerR: CGFloat = 10
        for i in 0..<n {
            let angle = CGFloat(i) / CGFloat(n) * 2 * .pi - .pi / 2
            let r = i % 2 == 0 ? outerR : innerR
            let pt = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
            if i == 0 { leafPath.move(to: pt) } else { leafPath.addLine(to: pt) }
        }
        leafPath.close()
        mainShape = SKShapeNode(path: leafPath.cgPath)
        mainShape.fillColor = UIColor(red: 0.2, green: 0.82, blue: 0.28, alpha: 1)
        mainShape.strokeColor = .black
        mainShape.lineWidth = 3
        addChild(mainShape)

        // Sparkle / glow effect for rarity
        let glow = SKShapeNode(circleOfRadius: 20)
        glow.fillColor = UIColor(red: 0.3, green: 1.0, blue: 0.4, alpha: 0.15)
        glow.strokeColor = UIColor(red: 0.3, green: 0.9, blue: 0.35, alpha: 0.5)
        glow.lineWidth = 2
        glow.zPosition = -1
        addChild(glow)

        // Pulsing glow
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        glow.run(SKAction.repeatForever(pulse))
    }

    // MARK: - Animations

    private func animateAppear() {
        setScale(0)
        run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.15),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))

        // Gentle bob
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 3, duration: 0.8),
            SKAction.moveBy(x: 0, y: -3, duration: 0.8)
        ])
        run(SKAction.repeatForever(bob))
    }

    func animatePickup(completion: @escaping () -> Void) {
        removeAction(forKey: "bob")
        let scaleUp = SKAction.scale(to: 1.6, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.15)
        let remove = SKAction.removeFromParent()
        run(SKAction.sequence([
            scaleUp,
            SKAction.group([fadeOut, SKAction.scale(to: 2.0, duration: 0.15)]),
            remove,
            SKAction.run(completion)
        ]))
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: 16)
        physicsBody?.categoryBitMask = PhysicsCategory.food
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
    }
}
