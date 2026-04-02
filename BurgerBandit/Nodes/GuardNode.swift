import SpriteKit

class GuardNode: SKNode {

    let uniformColor: UIColor
    var moveSpeed: CGFloat
    var chaseDistance: CGFloat
    var patrolPath: [CGPoint]
    private var patrolIndex: Int = 0
    private(set) var isChasing: Bool = false
    private var isStunned: Bool = false
    private var bodyNode: SKShapeNode!
    private var headNode: SKShapeNode!
    private var alertNode: SKNode!

    init(uniformColor: UIColor, moveSpeed: CGFloat, chaseDistance: CGFloat, patrolPath: [CGPoint]) {
        self.uniformColor = uniformColor
        self.moveSpeed = moveSpeed
        self.chaseDistance = chaseDistance
        self.patrolPath = patrolPath
        super.init()
        buildCharacter()
        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func buildCharacter() {
        // Guard body — top-down square silhouette
        let bodySize = CGSize(width: 36, height: 36)
        let bodyPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: -18, y: -18), size: bodySize), cornerRadius: 6)
        bodyNode = SKShapeNode(path: bodyPath.cgPath)
        bodyNode.fillColor = uniformColor
        bodyNode.strokeColor = .black
        bodyNode.lineWidth = 3
        bodyNode.zPosition = 1
        addChild(bodyNode)

        // Badge on uniform
        let badge = SKShapeNode(rectOf: CGSize(width: 8, height: 6))
        badge.fillColor = UIColor(red: 0.95, green: 0.82, blue: 0.1, alpha: 1) // gold badge
        badge.strokeColor = .black
        badge.lineWidth = 1
        badge.position = CGPoint(x: 5, y: 5)
        badge.zPosition = 2
        addChild(badge)

        // Head — circle above body
        headNode = SKShapeNode(circleOfRadius: 14)
        headNode.fillColor = UIColor(red: 0.98, green: 0.82, blue: 0.65, alpha: 1)
        headNode.strokeColor = .black
        headNode.lineWidth = 2.5
        headNode.position = CGPoint(x: 0, y: 10)
        headNode.zPosition = 3
        addChild(headNode)

        // Cap
        let capPath = UIBezierPath(roundedRect: CGRect(x: -14, y: 8, width: 28, height: 11), cornerRadius: 4)
        let cap = SKShapeNode(path: capPath.cgPath)
        cap.fillColor = uniformColor
        cap.strokeColor = .black
        cap.lineWidth = 2
        cap.zPosition = 4
        headNode.addChild(cap)

        let capBrim = SKShapeNode(rectOf: CGSize(width: 32, height: 5))
        capBrim.fillColor = uniformColor
        capBrim.strokeColor = .black
        capBrim.lineWidth = 1.5
        capBrim.position = CGPoint(x: 0, y: 8)
        capBrim.zPosition = 5
        headNode.addChild(capBrim)

        // Angry eyebrows
        addAngryEyebrows()

        // Eyes
        let leftEye = SKShapeNode(ellipseOf: CGSize(width: 7, height: 6))
        leftEye.fillColor = UIColor(red: 0.15, green: 0.1, blue: 0.05, alpha: 1)
        leftEye.strokeColor = .black
        leftEye.lineWidth = 1
        leftEye.position = CGPoint(x: -5, y: 2)
        leftEye.zPosition = 4
        headNode.addChild(leftEye)

        let rightEye = SKShapeNode(ellipseOf: CGSize(width: 7, height: 6))
        rightEye.fillColor = UIColor(red: 0.15, green: 0.1, blue: 0.05, alpha: 1)
        rightEye.strokeColor = .black
        rightEye.lineWidth = 1
        rightEye.position = CGPoint(x: 5, y: 2)
        rightEye.zPosition = 4
        headNode.addChild(rightEye)

        // Angry mouth (frown)
        let mouthPath = UIBezierPath()
        mouthPath.move(to: CGPoint(x: -6, y: -5))
        mouthPath.addQuadCurve(to: CGPoint(x: 6, y: -5), controlPoint: CGPoint(x: 0, y: -9))
        let mouth = SKShapeNode(path: mouthPath.cgPath)
        mouth.strokeColor = UIColor(red: 0.5, green: 0.15, blue: 0.1, alpha: 1)
        mouth.lineWidth = 2
        mouth.zPosition = 4
        headNode.addChild(mouth)

        // Alert node (! exclamation — shown when chasing)
        alertNode = buildAlertNode()
        alertNode.isHidden = true
        alertNode.position = CGPoint(x: 0, y: 32)
        alertNode.zPosition = 10
        addChild(alertNode)
    }

    private func addAngryEyebrows() {
        // Left eyebrow (angled inward = angry)
        let lbrow = UIBezierPath()
        lbrow.move(to: CGPoint(x: -9, y: 8))
        lbrow.addLine(to: CGPoint(x: -2, y: 11))
        let leftBrow = SKShapeNode(path: lbrow.cgPath)
        leftBrow.strokeColor = UIColor(red: 0.25, green: 0.15, blue: 0.05, alpha: 1)
        leftBrow.lineWidth = 2.5
        leftBrow.lineCap = .round
        leftBrow.zPosition = 4
        headNode.addChild(leftBrow)

        let rbrow = UIBezierPath()
        rbrow.move(to: CGPoint(x: 2, y: 11))
        rbrow.addLine(to: CGPoint(x: 9, y: 8))
        let rightBrow = SKShapeNode(path: rbrow.cgPath)
        rightBrow.strokeColor = UIColor(red: 0.25, green: 0.15, blue: 0.05, alpha: 1)
        rightBrow.lineWidth = 2.5
        rightBrow.lineCap = .round
        rightBrow.zPosition = 4
        headNode.addChild(rightBrow)
    }

    private func buildAlertNode() -> SKNode {
        let container = SKNode()
        // Background bubble
        let bubble = SKShapeNode(circleOfRadius: 14)
        bubble.fillColor = UIColor(red: 1.0, green: 0.95, blue: 0.2, alpha: 1)
        bubble.strokeColor = .black
        bubble.lineWidth = 2.5
        container.addChild(bubble)
        // Exclamation mark
        let exclaim = SKLabelNode(text: "!")
        exclaim.fontName = "AvenirNext-Heavy"
        exclaim.fontSize = 18
        exclaim.fontColor = UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1)
        exclaim.horizontalAlignmentMode = .center
        exclaim.verticalAlignmentMode = .center
        container.addChild(exclaim)
        return container
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 30))
        physicsBody?.categoryBitMask = PhysicsCategory.guard_
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.counter
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0
        physicsBody?.friction = 0.5
        physicsBody?.linearDamping = 10.0
    }

    // Called every frame from GameScene
    func update(playerPosition: CGPoint, dt: TimeInterval) {
        guard !isStunned else {
            physicsBody?.velocity = .zero
            return
        }

        let dx = playerPosition.x - position.x
        let dy = playerPosition.y - position.y
        let dist = sqrt(dx * dx + dy * dy)

        let wasChasing = isChasing
        isChasing = dist < chaseDistance

        if isChasing != wasChasing {
            alertNode.isHidden = !isChasing
            if isChasing {
                // Alert pop animation
                alertNode.setScale(0)
                alertNode.run(SKAction.sequence([
                    SKAction.scale(to: 1.3, duration: 0.1),
                    SKAction.scale(to: 1.0, duration: 0.08)
                ]))
            }
        }

        if isChasing {
            moveToward(target: playerPosition, dist: dist, dt: dt)
        } else {
            patrol(dt: dt)
        }
    }

    private func moveToward(target: CGPoint, dist: CGFloat, dt: TimeInterval) {
        guard dist > 5 else { return }
        let dx = target.x - position.x
        let dy = target.y - position.y
        let nx = dx / dist
        let ny = dy / dist
        physicsBody?.velocity = CGVector(dx: nx * moveSpeed * 60, dy: ny * moveSpeed * 60)
        // Face movement direction
        zRotation = atan2(ny, nx) - .pi / 2
    }

    private func patrol(dt: TimeInterval) {
        guard !patrolPath.isEmpty else { return }
        let target = patrolPath[patrolIndex]
        let dx = target.x - position.x
        let dy = target.y - position.y
        let dist = sqrt(dx * dx + dy * dy)

        if dist < 8 {
            patrolIndex = (patrolIndex + 1) % patrolPath.count
            return
        }

        let nx = dx / dist
        let ny = dy / dist
        let patrolSpeed = moveSpeed * 0.55
        physicsBody?.velocity = CGVector(dx: nx * patrolSpeed * 60, dy: ny * patrolSpeed * 60)
        zRotation = atan2(ny, nx) - .pi / 2
    }

    // Called when guard catches player — stun and push back
    func recoilFromPlayer() {
        isStunned = true
        physicsBody?.velocity = .zero
        alertNode.isHidden = true

        // Push guard away from current position (backward from facing)
        let pushDist: CGFloat = 80
        let pushDir = zRotation + .pi / 2 + .pi  // reverse of facing
        let pushX = cos(pushDir) * pushDist
        let pushY = sin(pushDir) * pushDist

        run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.2, duration: 0.1),
                SKAction.moveBy(x: pushX, y: pushY, duration: 0.25)
            ]),
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.wait(forDuration: 1.2),
            SKAction.run { [weak self] in self?.isStunned = false }
        ]))
    }
}
