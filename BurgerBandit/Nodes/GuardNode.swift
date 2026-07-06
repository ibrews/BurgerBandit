import SpriteKit

class GuardNode: SKNode {

    private enum State {
        case patrol      // walking the patrol path, actively scanning
        case distracted  // stopped, looking at a fixed prop, can't spot the player
        case chasing     // actively moving toward a spotted player
    }

    let uniformColor: UIColor
    var moveSpeed: CGFloat
    var sightRange: CGFloat
    var viewConeHalfAngle: CGFloat   // radians
    var distractionChance: Double
    var distractionDuration: ClosedRange<TimeInterval>
    var scanDuration: ClosedRange<TimeInterval>
    var patrolPath: [CGPoint]

    private var patrolIndex: Int = 0
    private(set) var isChasing: Bool = false
    private(set) var isDistracted: Bool = false
    var stunTimer: TimeInterval = 0
    /// Forces isDistracted for a startup window so guards can never spot the
    /// player the instant a level loads, regardless of cone/LOS math.
    var graceTimer: TimeInterval = 0

    private var state: State = .patrol
    private var stateTimer: TimeInterval = 0

    private var bodyNode: SKShapeNode!
    private var headNode: SKShapeNode!
    private var alertNode: SKNode!
    private var distractionIconNode: SKLabelNode!
    private var visionCone: SKShapeNode!

    // zRotation; world-space forward direction is `facingAngle + .pi/2`
    // (matches the -90° offset baked into the character art's local +y "up").
    private var facingAngle: CGFloat = 0
    var worldFacingAngle: CGFloat { facingAngle + .pi / 2 }

    // Play area bounds
    static let boundsMinX: CGFloat = -380
    static let boundsMaxX: CGFloat = 376
    static let boundsMinY: CGFloat = -145
    static let boundsMaxY: CGFloat = 140

    // Collision radius for distance-based "bumped into a guard" catch —
    // independent of vision, always active (even mid-distraction).
    static let catchRadius: CGFloat = 28

    private static let distractionFlavors = ["📱", "📺", "🧱"]

    init(uniformColor: UIColor, moveSpeed: CGFloat, chaseDistance: CGFloat, patrolPath: [CGPoint],
         viewConeHalfAngleDegrees: CGFloat = 28, distractionChance: Double = 0.4,
         distractionDuration: ClosedRange<TimeInterval> = 2.0...4.0,
         scanDuration: ClosedRange<TimeInterval> = 2.5...4.5) {
        self.uniformColor = uniformColor
        self.moveSpeed = moveSpeed
        self.sightRange = chaseDistance
        self.viewConeHalfAngle = viewConeHalfAngleDegrees * .pi / 180
        self.distractionChance = distractionChance
        self.distractionDuration = distractionDuration
        self.scanDuration = scanDuration
        self.patrolPath = patrolPath
        super.init()
        buildCharacter()
        stateTimer = Double.random(in: scanDuration)
        // NO physics body — collision is distance-based in GameScene
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func buildCharacter() {
        // Vision cone — drawn first so it renders under the body/head.
        visionCone = buildVisionCone()
        visionCone.zPosition = -0.5
        addChild(visionCone)

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
        badge.fillColor = UIColor(red: 0.95, green: 0.82, blue: 0.1, alpha: 1)
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

        addAngryEyebrows()

        // Eyes
        for xOff: CGFloat in [-5, 5] {
            let eye = SKShapeNode(ellipseOf: CGSize(width: 7, height: 6))
            eye.fillColor = UIColor(red: 0.15, green: 0.1, blue: 0.05, alpha: 1)
            eye.strokeColor = .black
            eye.lineWidth = 1
            eye.position = CGPoint(x: xOff, y: 2)
            eye.zPosition = 4
            headNode.addChild(eye)
        }

        // Angry mouth
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

        // Distraction icon (phone/TV/wall — shown while distracted)
        distractionIconNode = SKLabelNode(text: Self.distractionFlavors[0])
        distractionIconNode.fontSize = 20
        distractionIconNode.verticalAlignmentMode = .center
        distractionIconNode.horizontalAlignmentMode = .center
        distractionIconNode.position = CGPoint(x: 0, y: 32)
        distractionIconNode.zPosition = 10
        distractionIconNode.isHidden = true
        addChild(distractionIconNode)
    }

    private func buildVisionCone() -> SKShapeNode {
        // A pie slice pointing in local +y ("up"), matching how the body/head
        // are authored — so it automatically tracks facingAngle via zRotation.
        let path = CGMutablePath()
        path.move(to: .zero)
        let steps = 12
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let angle = (-viewConeHalfAngle) + t * (2 * viewConeHalfAngle) + .pi / 2
            path.addLine(to: CGPoint(x: cos(angle) * sightRange, y: sin(angle) * sightRange))
        }
        path.closeSubpath()
        let cone = SKShapeNode(path: path)
        cone.fillColor = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 0.16)
        cone.strokeColor = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 0.3)
        cone.lineWidth = 1.5
        return cone
    }

    private func addAngryEyebrows() {
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
        headNode.addChild(rightBrow)
    }

    private func buildAlertNode() -> SKNode {
        let container = SKNode()
        let bubble = SKShapeNode(circleOfRadius: 14)
        bubble.fillColor = UIColor(red: 1.0, green: 0.95, blue: 0.2, alpha: 1)
        bubble.strokeColor = .black
        bubble.lineWidth = 2.5
        container.addChild(bubble)
        let exclaim = SKLabelNode(text: "!")
        exclaim.fontName = "AvenirNext-Heavy"
        exclaim.fontSize = 18
        exclaim.fontColor = UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1)
        exclaim.horizontalAlignmentMode = .center
        exclaim.verticalAlignmentMode = .center
        container.addChild(exclaim)
        return container
    }

    /// GameScene owns level geometry and the player's position, so it decides
    /// whether this guard can actually SEE the player right now (range + cone
    /// + line-of-sight + not-distracted) and passes the verdict in as
    /// `spotted`. This node only owns movement, patrol, and the
    /// distraction/scan state machine.
    func update(playerPosition: CGPoint, spotted: Bool, dt: TimeInterval) {
        if stunTimer > 0 {
            stunTimer -= dt
            return
        }
        if graceTimer > 0 {
            graceTimer -= dt
        }

        let wasChasing = isChasing
        isChasing = spotted

        if isChasing != wasChasing {
            alertNode.isHidden = !isChasing
            if isChasing {
                // Being spotted-and-chasing always interrupts a distraction.
                setDistracted(false)
                alertNode.setScale(0)
                alertNode.run(SKAction.sequence([
                    SKAction.scale(to: 1.3, duration: 0.1),
                    SKAction.scale(to: 1.0, duration: 0.08)
                ]))
            }
        }

        if isChasing {
            let dx = playerPosition.x - position.x
            let dy = playerPosition.y - position.y
            let dist = sqrt(dx * dx + dy * dy)
            moveToward(playerPosition: playerPosition, dist: dist, dt: dt)
        } else {
            updateScanState(dt: dt)
            if isDistracted || graceTimer > 0 {
                // Standing still, looking at the fixed prop — no movement.
            } else {
                patrol(dt: dt)
            }
        }

        clampToBounds()
    }

    private func updateScanState(dt: TimeInterval) {
        stateTimer -= dt
        guard stateTimer <= 0 else { return }

        if isDistracted {
            setDistracted(false)
            stateTimer = Double.random(in: scanDuration)
        } else {
            if Double.random(in: 0...1) < distractionChance {
                setDistracted(true)
                stateTimer = Double.random(in: distractionDuration)
            } else {
                // Stay scanning a little longer instead of rolling every tick.
                stateTimer = Double.random(in: scanDuration)
            }
        }
    }

    private func setDistracted(_ distracted: Bool) {
        isDistracted = distracted
        distractionIconNode.isHidden = !distracted
        if distracted {
            distractionIconNode.text = Self.distractionFlavors.randomElement()
            // Look at a fixed, arbitrary world direction — "not looking at you."
            let targetWorld = CGFloat.random(in: 0..<(2 * .pi))
            rotateFacing(towardWorldAngle: targetWorld, dt: 1.0) // snap immediately
        }
    }

    private func moveToward(playerPosition: CGPoint, dist: CGFloat, dt: TimeInterval) {
        // Stop at catch radius — don't push into the player
        guard dist > GuardNode.catchRadius else { return }

        let dx = playerPosition.x - position.x
        let dy = playerPosition.y - position.y
        let nx = dx / dist
        let ny = dy / dist
        let step = moveSpeed * CGFloat(dt)
        position.x += nx * step
        position.y += ny * step

        rotateFacing(towardWorldAngle: atan2(ny, nx), dt: dt)
    }

    private func patrol(dt: TimeInterval) {
        guard !patrolPath.isEmpty else { return }
        let target = patrolPath[patrolIndex]
        let dx = target.x - position.x
        let dy = target.y - position.y
        let dist = sqrt(dx * dx + dy * dy)

        if dist < 10 {
            patrolIndex = (patrolIndex + 1) % patrolPath.count
            return
        }

        let nx = dx / dist
        let ny = dy / dist
        let step = moveSpeed * 0.55 * CGFloat(dt)
        position.x += nx * step
        position.y += ny * step

        rotateFacing(towardWorldAngle: atan2(ny, nx), dt: dt)
    }

    /// `worldAngle` is a true world-space direction (0 = +x). Converts to the
    /// -90°-offset `facingAngle`/`zRotation` convention the character art uses.
    private func rotateFacing(towardWorldAngle worldAngle: CGFloat, dt: TimeInterval) {
        let targetAngle = worldAngle - .pi / 2
        var diff = targetAngle - facingAngle
        while diff > .pi { diff -= 2 * .pi }
        while diff < -.pi { diff += 2 * .pi }
        facingAngle += diff * min(CGFloat(dt) * 8, 1.0)
        zRotation = facingAngle
    }

    private func clampToBounds() {
        position.x = max(GuardNode.boundsMinX, min(GuardNode.boundsMaxX, position.x))
        position.y = max(GuardNode.boundsMinY, min(GuardNode.boundsMaxY, position.y))
    }

    // Called when guard catches player — freeze in place
    func recoilFromPlayer() {
        stunTimer = 1.5
        alertNode.isHidden = true
        let flash = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.08)
        ])
        run(flash)
    }

    // Distance to a point (for external collision checks)
    func distanceTo(_ point: CGPoint) -> CGFloat {
        let dx = point.x - position.x
        let dy = point.y - position.y
        return sqrt(dx * dx + dy * dy)
    }
}
