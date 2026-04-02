import SpriteKit

class PlayerNode: SKNode {

    private var bodyNode: SKShapeNode!
    private var headNode: SKShapeNode!
    private var maskNode: SKShapeNode!
    private var leftEye: SKShapeNode!
    private var rightEye: SKShapeNode!
    private var leftPupil: SKShapeNode!
    private var rightPupil: SKShapeNode!
    private var bellyNode: SKShapeNode?

    private(set) var currentFatStage: Int = -1  // force initial draw

    // Colors for the burglar character
    static let hoodieFill  = UIColor(red: 0.20, green: 0.50, blue: 0.22, alpha: 1) // dark green hoodie
    static let hoodieStroke = UIColor.black
    static let skinColor   = UIColor(red: 0.98, green: 0.82, blue: 0.65, alpha: 1)
    static let maskColor   = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)

    override init() {
        super.init()
        updateFatStage(0, animated: false)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    func updateFatStage(_ stage: Int, animated: Bool = true) {
        guard stage != currentFatStage else { return }
        currentFatStage = stage
        rebuildCharacter()
        if animated {
            // Bounce "pop" animation when getting fatter
            let scaleUp = SKAction.scale(to: 1.25, duration: 0.12)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.10)
            scaleUp.timingMode = .easeOut
            scaleDown.timingMode = .easeIn
            run(SKAction.sequence([scaleUp, scaleDown]))
        }
    }

    private func rebuildCharacter() {
        removeAllChildren()

        let radius = GameState.shared.playerRadius()

        // Body — main circle (hoodie)
        let body = SKShapeNode(circleOfRadius: radius)
        body.fillColor = Self.hoodieFill
        body.strokeColor = Self.hoodieStroke
        body.lineWidth = 3.5
        body.zPosition = 1
        addChild(body)
        bodyNode = body

        // Belly rolls for fat stages 2+
        if currentFatStage >= 2 {
            let bellyRadius = radius * 0.6
            let belly = SKShapeNode(circleOfRadius: bellyRadius)
            belly.fillColor = UIColor(red: 0.22, green: 0.55, blue: 0.25, alpha: 0.8)
            belly.strokeColor = Self.hoodieStroke
            belly.lineWidth = 2
            belly.position = CGPoint(x: 0, y: -radius * 0.25)
            belly.zPosition = 2
            addChild(belly)
            bellyNode = belly
        }

        // Head — slightly above center (top of circle)
        let headRadius = radius * 0.68
        let head = SKShapeNode(circleOfRadius: headRadius)
        head.fillColor = Self.skinColor
        head.strokeColor = Self.hoodieStroke
        head.lineWidth = 2.5
        head.position = CGPoint(x: 0, y: radius * 0.35)
        head.zPosition = 3
        addChild(head)
        headNode = head

        // Mask across eyes
        let maskW = headRadius * 1.6
        let maskH = headRadius * 0.38
        let maskPath = UIBezierPath(roundedRect: CGRect(x: -maskW/2, y: -maskH/2, width: maskW, height: maskH), cornerRadius: 4)
        let mask = SKShapeNode(path: maskPath.cgPath)
        mask.fillColor = Self.maskColor
        mask.strokeColor = Self.hoodieStroke
        mask.lineWidth = 1.5
        mask.position = CGPoint(x: 0, y: headRadius * 0.1)
        mask.zPosition = 4
        head.addChild(mask)
        maskNode = mask

        // Eyes (white circles peeking above mask)
        let eyeR: CGFloat = headRadius * 0.24
        let eyeSpacing: CGFloat = headRadius * 0.48

        let lEye = SKShapeNode(circleOfRadius: eyeR)
        lEye.fillColor = .white
        lEye.strokeColor = .black
        lEye.lineWidth = 1.2
        lEye.position = CGPoint(x: -eyeSpacing, y: headRadius * 0.18)
        lEye.zPosition = 5
        head.addChild(lEye)
        leftEye = lEye

        let rEye = SKShapeNode(circleOfRadius: eyeR)
        rEye.fillColor = .white
        rEye.strokeColor = .black
        rEye.lineWidth = 1.2
        rEye.position = CGPoint(x: eyeSpacing, y: headRadius * 0.18)
        rEye.zPosition = 5
        head.addChild(rEye)
        rightEye = rEye

        // Pupils
        let pupilR: CGFloat = eyeR * 0.55
        let lPupil = SKShapeNode(circleOfRadius: pupilR)
        lPupil.fillColor = .black
        lPupil.strokeColor = .clear
        lPupil.position = CGPoint(x: 1, y: -1)  // slightly offset
        lPupil.zPosition = 6
        lEye.addChild(lPupil)
        leftPupil = lPupil

        let rPupil = SKShapeNode(circleOfRadius: pupilR)
        rPupil.fillColor = .black
        rPupil.strokeColor = .clear
        rPupil.position = CGPoint(x: 1, y: -1)
        rPupil.zPosition = 6
        rEye.addChild(rPupil)
        rightPupil = rPupil

        // Hoodie pocket (fat stages look more stuffed)
        if currentFatStage >= 1 {
            let pocketPath = UIBezierPath(roundedRect: CGRect(x: -radius * 0.35, y: -radius * 0.55, width: radius * 0.7, height: radius * 0.35), cornerRadius: 5)
            let pocket = SKShapeNode(path: pocketPath.cgPath)
            pocket.fillColor = UIColor(red: 0.15, green: 0.40, blue: 0.18, alpha: 1)
            pocket.strokeColor = Self.hoodieStroke
            pocket.lineWidth = 1.5
            pocket.zPosition = 2
            addChild(pocket)
        }

        // Physics body uses separate collision radius — smaller to avoid getting wedged
        physicsBody = SKPhysicsBody(circleOfRadius: GameState.shared.playerCollisionRadius())
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.food | PhysicsCategory.door
        physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.counter
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0
        physicsBody?.friction = 0.5
        physicsBody?.linearDamping = 8.0
    }

    // Eating animation — crumbs flying out
    func animateEating(in scene: SKScene) {
        guard let parent = parent else { return }
        let scenePos = scene.convert(position, from: parent)

        for _ in 0..<6 {
            let crumb = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            crumb.fillColor = [UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1),
                               UIColor(red: 0.85, green: 0.5, blue: 0.2, alpha: 1),
                               UIColor(red: 0.95, green: 0.85, blue: 0.45, alpha: 1)].randomElement()!
            crumb.strokeColor = .black
            crumb.lineWidth = 1
            crumb.position = scenePos
            crumb.zPosition = 50
            scene.addChild(crumb)

            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 25...55)
            let dest = CGPoint(x: scenePos.x + cos(angle) * distance,
                               y: scenePos.y + sin(angle) * distance)
            let fly = SKAction.move(to: dest, duration: 0.4)
            let fade = SKAction.fadeOut(withDuration: 0.3)
            let remove = SKAction.removeFromParent()
            crumb.run(SKAction.sequence([
                SKAction.group([fly, SKAction.sequence([
                    SKAction.wait(forDuration: 0.1),
                    fade
                ])]),
                remove
            ]))
        }

        // Character squish-squash
        let squishH = SKAction.scaleX(to: 1.3, duration: 0.08)
        let squishV = SKAction.scaleY(to: 0.75, duration: 0.08)
        let restoreH = SKAction.scaleX(to: 1.0, duration: 0.12)
        let restoreV = SKAction.scaleY(to: 1.0, duration: 0.12)
        run(SKAction.sequence([
            SKAction.group([squishH, squishV]),
            SKAction.group([restoreH, restoreV])
        ]))
    }

    // Speed boost visual — green sparkle glow
    func animateSpeedBoost() {
        let glow = SKShapeNode(circleOfRadius: (GameState.shared.playerRadius()) * 1.4)
        glow.fillColor = UIColor(red: 0.3, green: 1.0, blue: 0.4, alpha: 0.3)
        glow.strokeColor = UIColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 0.8)
        glow.lineWidth = 3
        glow.zPosition = 0
        glow.name = "speedBoostGlow"
        addChild(glow)

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.4),
            SKAction.scale(to: 0.95, duration: 0.4)
        ])
        glow.run(SKAction.repeatForever(pulse))
    }

    func removeSpeedBoostEffect() {
        childNode(withName: "speedBoostGlow")?.removeFromParent()
    }

    // Make player flash when taking damage
    func animateDamage() {
        let flash = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.9, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.15)
        ])
        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        bodyNode.run(flash)
        run(SKAction.repeat(blink, count: 6))
    }

    // Update eye direction to face movement
    func faceDirection(_ angle: CGFloat) {
        let eyeOffset: CGFloat = 3
        let lx = cos(angle + .pi/2) * eyeOffset
        let ly = sin(angle + .pi/2) * eyeOffset
        leftPupil?.position = CGPoint(x: lx + 1, y: ly - 1)
        rightPupil?.position = CGPoint(x: lx + 1, y: ly - 1)
    }
}
