import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Nodes
    private var player: PlayerNode!
    private var guards: [GuardNode] = []
    private var foodNodes: [FoodNode] = []
    private var hud: HUDNode!
    private var kitchenNode: SKNode!
    private var pauseOverlay: SKNode?

    // MARK: - Layout
    private var layout: KitchenLayout!
    private var restaurant: RestaurantType { GameState.shared.selectedRestaurant }

    // MARK: - Touch / Joystick
    private var joystickTouch: UITouch?
    private var joystickBase: CGPoint = .zero
    private var joystickCurrent: CGPoint = .zero
    private let joystickMaxRadius: CGFloat = 55
    private var joystickBaseNode: SKShapeNode!
    private var joystickStickNode: SKShapeNode!

    // MARK: - Game state
    private var lastUpdateTime: TimeInterval = 0
    private var foodSpawnTimer: TimeInterval = 0
    private var currentFatStage: Int = -1
    private var isGamePaused = false
    private var invincibilityTimer: TimeInterval = 0
    private let invincibilityDuration: TimeInterval = 2.0

    // MARK: - Jump
    private var isJumping = false
    private let jumpDuration: TimeInterval = 0.45

    // MARK: - Too Slow (fat stage 3 timer)
    private var tooSlowTimer: TimeInterval = 0
    private let tooSlowLimit: TimeInterval = 8.0  // seconds at fat stage 3 before game ends

    // MARK: - Music
    private var anyGuardChasing = false

    // MARK: - Scene lifecycle

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let state = GameState.shared
        layout = KitchenBuilder.build(for: restaurant)

        setupPhysics()
        buildKitchen()
        buildPlayer()
        buildGuards()
        buildHUD()
        buildJoystick()
        buildMenuButton()
        buildRestaurantBanner()
        spawnInitialFood()

        backgroundColor = UIColor(red: 0.06, green: 0.05, blue: 0.04, alpha: 1)

        // Fade in
        alpha = 0
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.fadeIn(withDuration: 0.35)
        ]))

        // Start music
        MusicManager.shared.playBackground()

        _ = state
    }

    private func setupPhysics() {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        // Invisible edge boundary prevents anything from leaving the screen
        let bounds = CGRect(x: -size.width / 2, y: -size.height / 2,
                            width: size.width, height: size.height)
        physicsBody = SKPhysicsBody(edgeLoopFrom: bounds)
        physicsBody?.categoryBitMask = PhysicsCategory.wall
        physicsBody?.restitution = 0
    }

    // MARK: - Build Methods

    private func buildKitchen() {
        kitchenNode = KitchenBuilder.buildKitchenNode(layout: layout, restaurant: restaurant)
        kitchenNode.zPosition = 0
        addChild(kitchenNode)
    }

    private func buildPlayer() {
        player = PlayerNode()
        player.position = layout.playerStart
        player.zPosition = 10
        addChild(player)
        currentFatStage = 0
    }

    // Guards can't spot the player for this long after a level loads, no
    // matter what the cone/LOS math says — a level should never open with
    // an instant catch.
    private static let startGracePeriod: TimeInterval = 1.5

    private func buildGuards() {
        let state = GameState.shared
        let diff = state.difficulty
        let guardCount = min(diff.guardCount, layout.guardStarts.count)

        for i in 0..<guardCount {
            let patrolPath = i < layout.patrolPaths.count ? layout.patrolPaths[i] : []
            let guard_ = GuardNode(
                uniformColor: restaurant.guardUniformColor,
                moveSpeed: diff.guardBaseSpeed,
                chaseDistance: diff.chaseDistance,
                patrolPath: patrolPath,
                viewConeHalfAngleDegrees: diff.viewConeHalfAngleDegrees,
                distractionChance: diff.distractionChance,
                distractionDuration: diff.distractionDuration,
                scanDuration: diff.scanDuration
            )
            guard_.position = layout.guardStarts[i]
            guard_.zPosition = 9
            guard_.graceTimer = Self.startGracePeriod
            addChild(guard_)
            guards.append(guard_)
        }
    }

    /// True if nothing in `layout`'s walls/counters/serving counters, or any
    /// currently-active food item, blocks the straight line between two
    /// points — a table, a wall, or a burger left on the counter all work as
    /// sightline cover.
    private func hasLineOfSight(from: CGPoint, to: CGPoint) -> Bool {
        for rect in layout.wallRects where segment(from, to, intersects: rect) { return false }
        for rect in layout.counterRects where segment(from, to, intersects: rect) { return false }
        for rect in layout.servingRects where segment(from, to, intersects: rect) { return false }
        for food in foodNodes where segment(from, to, passesNear: food.position, radius: 22) { return false }
        return true
    }

    /// Slab-method segment/AABB intersection test.
    private func segment(_ p0: CGPoint, _ p1: CGPoint, intersects rect: CGRect) -> Bool {
        var tMin: CGFloat = 0, tMax: CGFloat = 1
        let d = CGPoint(x: p1.x - p0.x, y: p1.y - p0.y)

        for axis in 0..<2 {
            let origin = axis == 0 ? p0.x : p0.y
            let delta = axis == 0 ? d.x : d.y
            let lo = axis == 0 ? rect.minX : rect.minY
            let hi = axis == 0 ? rect.maxX : rect.maxY

            if abs(delta) < 1e-6 {
                if origin < lo || origin > hi { return false }
            } else {
                var t0 = (lo - origin) / delta
                var t1 = (hi - origin) / delta
                if t0 > t1 { swap(&t0, &t1) }
                tMin = max(tMin, t0)
                tMax = min(tMax, t1)
                if tMin > tMax { return false }
            }
        }
        return true
    }

    /// Point-to-segment distance test, for treating food items as small
    /// circular sightline obstructions.
    private func segment(_ p0: CGPoint, _ p1: CGPoint, passesNear point: CGPoint, radius: CGFloat) -> Bool {
        let dx = p1.x - p0.x
        let dy = p1.y - p0.y
        let lengthSquared = dx * dx + dy * dy
        guard lengthSquared > 1e-6 else { return false }
        var t = ((point.x - p0.x) * dx + (point.y - p0.y) * dy) / lengthSquared
        t = max(0, min(1, t))
        let closestX = p0.x + t * dx
        let closestY = p0.y + t * dy
        let distX = point.x - closestX
        let distY = point.y - closestY
        return (distX * distX + distY * distY) < (radius * radius)
    }

    /// Range + cone + line-of-sight + not-distracted. This is the single
    /// source of truth for "can this guard see the player right now" —
    /// GuardNode itself doesn't have access to level geometry.
    private func guardCanSeePlayer(_ guard_: GuardNode) -> Bool {
        guard guard_.graceTimer <= 0, !guard_.isDistracted else { return false }

        let dx = player.position.x - guard_.position.x
        let dy = player.position.y - guard_.position.y
        let dist = sqrt(dx * dx + dy * dy)
        guard dist <= guard_.sightRange else { return false }

        let angleToPlayer = atan2(dy, dx)
        var diff = angleToPlayer - guard_.worldFacingAngle
        while diff > .pi { diff -= 2 * .pi }
        while diff < -.pi { diff += 2 * .pi }
        guard abs(diff) <= guard_.viewConeHalfAngle else { return false }

        return hasLineOfSight(from: guard_.position, to: player.position)
    }

    private func buildHUD() {
        hud = HUDNode()
        hud.zPosition = 100
        hud.setup(sceneSize: size)
        addChild(hud)
        refreshHUD()
    }

    private func buildJoystick() {
        // Base circle (always visible, dim)
        joystickBaseNode = SKShapeNode(circleOfRadius: joystickMaxRadius)
        joystickBaseNode.fillColor = UIColor(white: 1.0, alpha: 0.08)
        joystickBaseNode.strokeColor = UIColor(white: 1.0, alpha: 0.25)
        joystickBaseNode.lineWidth = 2
        joystickBaseNode.position = CGPoint(x: -size.width / 2 + 80, y: -size.height / 2 + 65)
        joystickBaseNode.zPosition = 95
        joystickBaseNode.isHidden = true
        addChild(joystickBaseNode)

        // Stick (follows finger)
        joystickStickNode = SKShapeNode(circleOfRadius: 24)
        joystickStickNode.fillColor = UIColor(white: 1.0, alpha: 0.35)
        joystickStickNode.strokeColor = UIColor(white: 1.0, alpha: 0.7)
        joystickStickNode.lineWidth = 2.5
        joystickStickNode.zPosition = 96
        joystickStickNode.isHidden = true
        addChild(joystickStickNode)
    }

    private func buildRestaurantBanner() {
        // Brief restaurant name banner at start
        let banner = SKNode()
        banner.zPosition = 102

        let bg = SKShapeNode(rectOf: CGSize(width: 340, height: 40), cornerRadius: 8)
        bg.fillColor = restaurant.primaryColor.withAlphaComponent(0.85)
        bg.strokeColor = .black
        bg.lineWidth = 2.5
        banner.addChild(bg)

        let name = SKLabelNode(text: restaurant.displayName.uppercased())
        name.fontName = "AvenirNext-Heavy"
        name.fontSize = 20
        name.fontColor = .white
        name.horizontalAlignmentMode = .center
        name.verticalAlignmentMode = .center
        banner.addChild(name)

        banner.position = CGPoint(x: 0, y: 0)
        addChild(banner)

        // Animate in then out
        banner.setScale(0.8)
        banner.alpha = 0
        banner.run(SKAction.sequence([
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.2)
            ]),
            SKAction.wait(forDuration: 1.5),
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.scale(to: 0.85, duration: 0.3)
            ]),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Food Spawning

    private func spawnInitialFood() {
        // Pre-populate some food on the kitchen counters
        let initialCount = min(6, layout.spawnPoints.count)
        let shuffled = layout.spawnPoints.shuffled()
        for i in 0..<initialCount {
            spawnFood(at: shuffled[i])
        }
    }

    private func spawnFood(at spawnPoint: SpawnPoint) {
        let state = GameState.shared
        let foodType = selectFoodType(isHighValue: spawnPoint.isHighValue, state: state)
        let food = FoodNode(type: foodType)
        food.position = spawnPoint.position
        food.zPosition = 5
        addChild(food)
        foodNodes.append(food)
    }

    private func selectFoodType(isHighValue: Bool, state: GameState) -> FoodType {
        // Chance of veggie spawn (rare!)
        if Double.random(in: 0...1) < state.difficulty.vegetableSpawnChance {
            return .veggie
        }

        if isHighValue {
            // High value items at serving counters
            let options = FoodType.randomHighValue()
            return options
        }

        // Low value — slightly boost restaurant's preferred foods
        let boosted = restaurant.boostedFoods
        if Bool.random() {
            return boosted.randomElement() ?? FoodType.randomLowValue()
        }
        return FoodType.randomLowValue()
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        guard !isGamePaused else { return }

        let dt = lastUpdateTime == 0 ? 0.016 : min(currentTime - lastUpdateTime, 0.1)
        lastUpdateTime = currentTime

        let state = GameState.shared

        // Speed boost timer
        if state.hasSpeedBoost && currentTime > state.speedBoostEndTime {
            state.hasSpeedBoost = false
            player.removeSpeedBoostEffect()
        }

        // Invincibility timer
        if invincibilityTimer > 0 {
            invincibilityTimer -= dt
            if invincibilityTimer <= 0 {
                invincibilityTimer = 0
                state.isInvincible = false
                player.alpha = 1.0
            }
        }

        // Player movement from joystick
        updatePlayerMovement(dt: dt)

        // Clamp player to play area
        player.position.x = max(-380, min(376, player.position.x))
        player.position.y = max(-145, min(140, player.position.y))

        // Guard AI + chase music + distance-based catch detection
        var chasing = false
        for guard_ in guards {
            let spotted = guardCanSeePlayer(guard_)
            guard_.update(playerPosition: player.position, spotted: spotted, dt: dt)
            if guard_.isChasing { chasing = true }

            // Distance-based guard catch (replaces physics contact)
            if guard_.stunTimer <= 0 && guard_.distanceTo(player.position) < GuardNode.catchRadius {
                handleGuardCatch(guard_)
            }
        }
        if chasing != anyGuardChasing {
            anyGuardChasing = chasing
            if chasing {
                MusicManager.shared.playAlarm()
            } else {
                MusicManager.shared.stopAlarm()
            }
        }

        // Food spawn timer
        foodSpawnTimer += dt
        if foodSpawnTimer >= state.difficulty.foodSpawnInterval {
            foodSpawnTimer = 0
            spawnRandomFood()
        }

        // Check fat stage change
        let newStage = state.fatStage
        if newStage != currentFatStage {
            currentFatStage = newStage
            player.updateFatStage(newStage, animated: true)
            hud.updateFatStage(newStage, fraction: state.fatFraction)
            if newStage > 0 {
                showFatStageAlert(stage: newStage)
            }
        }

        // Too slow — at fat stage 3, start countdown to game over
        if state.fatStage >= 3 {
            tooSlowTimer += dt
            if tooSlowTimer >= tooSlowLimit {
                triggerTooSlowGameOver()
            }
        }
    }

    private func updatePlayerMovement(dt: TimeInterval) {
        guard joystickTouch != nil else {
            // Dampen to stop
            physicsWorld.gravity = .zero
            player.physicsBody?.velocity = CGVector(
                dx: (player.physicsBody?.velocity.dx ?? 0) * 0.7,
                dy: (player.physicsBody?.velocity.dy ?? 0) * 0.7
            )
            return
        }

        let state = GameState.shared
        let baseSpeed: CGFloat = 200
        let speedMult = state.playerSpeedMultiplier()

        let dx = joystickCurrent.x - joystickBase.x
        let dy = joystickCurrent.y - joystickBase.y
        let dist = sqrt(dx * dx + dy * dy)

        if dist > 5 {
            let nx = dx / dist
            let ny = dy / dist
            // Intensity: 0..1 based on how far finger is from base
            let intensity = min(dist / joystickMaxRadius, 1.0)
            let vx = nx * baseSpeed * speedMult * intensity
            let vy = ny * baseSpeed * speedMult * intensity

            player.physicsBody?.velocity = CGVector(dx: vx, dy: vy)

            // Face the direction of movement
            let angle = atan2(ny, nx)
            player.zRotation = angle - .pi / 2
            player.faceDirection(angle)
        }
    }

    private func spawnRandomFood() {
        // Only spawn if there's room (max food items limit)
        guard foodNodes.filter({ $0.parent != nil }).count < layout.spawnPoints.count else { return }

        // Find an unoccupied spawn point
        let occupied = Set(foodNodes.compactMap { food -> CGPoint? in
            guard food.parent != nil else { return nil }
            return food.position
        }.map { "\(Int($0.x)),\(Int($0.y))" })

        let free = layout.spawnPoints.filter { sp in
            !occupied.contains("\(Int(sp.position.x)),\(Int(sp.position.y))")
        }

        guard let point = free.randomElement() else { return }
        spawnFood(at: point)
    }

    // MARK: - Physics Contact

    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.categoryBitMask
        let b = contact.bodyB.categoryBitMask

        // Player touches food
        if (a == PhysicsCategory.player && b == PhysicsCategory.food) ||
           (a == PhysicsCategory.food && b == PhysicsCategory.player) {
            let foodBody = a == PhysicsCategory.food ? contact.bodyA : contact.bodyB
            if let foodNode = foodBody.node as? FoodNode {
                handleFoodPickup(foodNode)
            }
        }

        // Guard catch is now distance-based in update() — no physics contact needed

        // Player touches door
        if (a == PhysicsCategory.player && b == PhysicsCategory.door) ||
           (a == PhysicsCategory.door && b == PhysicsCategory.player) {
            let doorBody = a == PhysicsCategory.door ? contact.bodyA : contact.bodyB
            if let doorNode = doorBody.node {
                handleDoorTransition(doorNode)
            }
        }
    }

    private func handleFoodPickup(_ foodNode: FoodNode) {
        guard foodNode.parent != nil else { return }
        let foodType = foodNode.foodType
        let pickupPos = foodNode.position

        // Remove from tracking
        foodNodes.removeAll { $0 === foodNode }

        // Update game state
        let state = GameState.shared
        state.collectFood(foodType)

        // Animate pickup
        foodNode.animatePickup { }

        // Player eating animation
        player.animateEating(in: self)

        // Fancy particle burst at pickup location
        spawnFoodParticles(at: pickupPos, foodType: foodType)

        // Speed boost from vegetable
        if foodType.isVegetable {
            state.hasSpeedBoost = true
            state.speedBoostEndTime = lastUpdateTime + 5.0
            player.animateSpeedBoost()
        }

        // Update HUD
        refreshHUD()
        hud.showFoodPickup(foodType, scoreAdded: foodType.points)

        // Shake screen briefly for high value
        if foodType.isHighValue {
            run(SKAction.sequence([
                SKAction.scale(to: 1.015, duration: 0.04),
                SKAction.scale(to: 1.0, duration: 0.04)
            ]))
        }
    }

    private func handleGuardCatch(_ guardNode: GuardNode) {
        let state = GameState.shared
        guard !state.isInvincible else { return }

        let lifeLost = state.takeDamage()
        state.isInvincible = true
        invincibilityTimer = invincibilityDuration

        // Visual feedback
        player.animateDamage()
        guardNode.recoilFromPlayer()
        hud.showGuardAlert()
        screenFlash(color: UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 0.4))

        refreshHUD()

        if lifeLost {
            hud.updateLives(state.lives)
            if state.isGameOver {
                run(SKAction.wait(forDuration: 1.0)) { [weak self] in
                    self?.triggerGameOver()
                }
            }
        }
    }

    private func triggerGameOver() {
        guard !isGamePaused else { return }
        isGamePaused = true
        let state = GameState.shared
        MusicManager.shared.stopAll()

        // Save high score
        HighScoreManager.shared.saveScore(
            score: state.score,
            difficulty: state.difficulty,
            restaurant: state.selectedRestaurant,
            fatStage: state.fatStage
        )

        // Find nearest guard for arrest animation
        let nearestGuard = guards.min(by: {
            let d1 = hypot($0.position.x - player.position.x, $0.position.y - player.position.y)
            let d2 = hypot($1.position.x - player.position.x, $1.position.y - player.position.y)
            return d1 < d2
        })

        // Stop all guards
        for g in guards { g.physicsBody?.velocity = .zero }

        // Player falls face-down (arrested)
        player.physicsBody?.velocity = .zero
        player.physicsBody?.isDynamic = false

        let faceDown = SKAction.sequence([
            SKAction.group([
                SKAction.rotate(toAngle: .pi, duration: 0.3),
                SKAction.scaleY(to: 0.4, duration: 0.3),
                SKAction.scaleX(to: 1.2, duration: 0.3)
            ]),
        ])

        // Guard walks over and stands over player
        if let guard_ = nearestGuard {
            guard_.physicsBody?.velocity = .zero
            let walkTo = SKAction.move(to: CGPoint(x: player.position.x, y: player.position.y + 25), duration: 0.6)
            walkTo.timingMode = .easeInEaseOut
            guard_.run(walkTo)
        }

        player.run(faceDown)

        // Flash "BUSTED!" text
        run(SKAction.wait(forDuration: 0.5)) { [weak self] in
            guard let self = self else { return }
            let busted = SKLabelNode(text: "BUSTED!")
            busted.fontName = "AvenirNext-Heavy"
            busted.fontSize = 40
            busted.fontColor = UIColor(red: 1.0, green: 0.15, blue: 0.1, alpha: 1)
            busted.horizontalAlignmentMode = .center
            busted.position = CGPoint(x: 0, y: 20)
            busted.zPosition = 150
            busted.setScale(0.3)
            self.addChild(busted)
            busted.run(SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.15),
                SKAction.scale(to: 1.0, duration: 0.08)
            ]))

            // Dim background
            self.screenFlash(color: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6))
        }

        // Transition to game over scene after arrest plays out
        run(SKAction.wait(forDuration: 2.0)) { [weak self] in
            guard let self = self else { return }
            let gameOver = GameOverScene(size: self.size, score: state.score, fatStage: state.fatStage)
            gameOver.scaleMode = self.scaleMode
            self.view?.presentScene(gameOver, transition: SKTransition.fade(with: .black, duration: 0.6))
        }
    }

    private func triggerTooSlowGameOver() {
        guard !isGamePaused else { return }
        isGamePaused = true
        let state = GameState.shared
        MusicManager.shared.stopAll()

        // Save high score
        HighScoreManager.shared.saveScore(
            score: state.score,
            difficulty: state.difficulty,
            restaurant: state.selectedRestaurant,
            fatStage: state.fatStage
        )

        // Player collapses from being too fat
        player.physicsBody?.velocity = .zero
        player.physicsBody?.isDynamic = false

        let collapse = SKAction.group([
            SKAction.scaleY(to: 0.3, duration: 0.5),
            SKAction.scaleX(to: 1.5, duration: 0.5),
            SKAction.rotate(byAngle: .pi * 0.5, duration: 0.5)
        ])
        collapse.timingMode = .easeIn
        player.run(collapse)

        // "TOO FAT TO ESCAPE!" text
        run(SKAction.wait(forDuration: 0.3)) { [weak self] in
            guard let self = self else { return }
            let label = SKLabelNode(text: "TOO FAT TO ESCAPE!")
            label.fontName = "AvenirNext-Heavy"
            label.fontSize = 32
            label.fontColor = UIColor(red: 1.0, green: 0.5, blue: 0.1, alpha: 1)
            label.horizontalAlignmentMode = .center
            label.position = CGPoint(x: 0, y: 20)
            label.zPosition = 150
            label.setScale(0.3)
            self.addChild(label)
            label.run(SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.15),
                SKAction.scale(to: 1.0, duration: 0.08)
            ]))
            self.screenFlash(color: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6))
        }

        // Transition
        run(SKAction.wait(forDuration: 2.2)) { [weak self] in
            guard let self = self else { return }
            let gameOver = GameOverScene(size: self.size, score: state.score, fatStage: state.fatStage)
            gameOver.scaleMode = self.scaleMode
            self.view?.presentScene(gameOver, transition: SKTransition.fade(with: .black, duration: 0.6))
        }
    }

    // MARK: - Door Transitions

    private var isTransitioning = false

    private func handleDoorTransition(_ doorNode: SKNode) {
        guard !isTransitioning, !isGamePaused else { return }
        isTransitioning = true

        let state = GameState.shared
        let isLeft = doorNode.name == "doorLeft"
        let target = isLeft ? restaurant.leftNeighbor : restaurant.rightNeighbor
        guard let nextRestaurant = target else {
            isTransitioning = false
            return
        }

        MusicManager.shared.stopAlarm()

        // Slide transition direction
        let slideDir: SKTransitionDirection = isLeft ? .left : .right

        // Update selected restaurant (state carries over — score, health, lives, fat)
        state.selectedRestaurant = nextRestaurant

        // Create new game scene for the next restaurant
        let nextScene = GameScene(size: size)
        nextScene.scaleMode = scaleMode
        view?.presentScene(nextScene, transition: SKTransition.push(with: slideDir, duration: 0.4))
    }

    // MARK: - Helpers

    private func refreshHUD() {
        let state = GameState.shared
        hud.updateScore(state.score)
        hud.updateLives(state.lives)
        hud.updateHealth(state.health)
        hud.updateFatStage(state.fatStage, fraction: state.fatFraction)
    }

    private func screenFlash(color: UIColor) {
        let flash = SKShapeNode(rectOf: size)
        flash.fillColor = color
        flash.strokeColor = .clear
        flash.zPosition = 150
        addChild(flash)
        flash.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ]))
    }

    private func showFatStageAlert(stage: Int) {
        let messages = ["", "Getting chubby!", "You're getting FAT!", "ABSOLUTELY MASSIVE!!"]
        let alert = SKLabelNode(text: messages[min(stage, 3)])
        alert.fontName = "AvenirNext-Heavy"
        alert.fontSize = 20
        alert.fontColor = UIColor(red: 1.0, green: 0.5, blue: 0.1, alpha: 1)
        alert.horizontalAlignmentMode = .center
        alert.position = CGPoint(x: 0, y: -30)
        alert.zPosition = 101
        addChild(alert)

        alert.setScale(0.5)
        alert.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.1, duration: 0.2),
                SKAction.fadeIn(withDuration: 0.1)
            ]),
            SKAction.scale(to: 1.0, duration: 0.05),
            SKAction.wait(forDuration: 1.2),
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Menu Button & Pause

    private func buildMenuButton() {
        let btn = SKNode()
        btn.name = "menuButton"
        btn.position = CGPoint(x: size.width / 2 - 30, y: -size.height / 2 + 25)
        btn.zPosition = 110

        let bg = SKShapeNode(rectOf: CGSize(width: 40, height: 28), cornerRadius: 6)
        bg.fillColor = UIColor(white: 0.15, alpha: 0.85)
        bg.strokeColor = UIColor(white: 0.5, alpha: 0.8)
        bg.lineWidth = 1.5
        btn.addChild(bg)

        let label = SKLabelNode(text: "☰")
        label.fontSize = 18
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        btn.addChild(label)

        addChild(btn)
    }

    private func showPauseMenu() {
        guard pauseOverlay == nil else { return }
        isGamePaused = true
        MusicManager.shared.pauseAll()

        let overlay = SKNode()
        overlay.name = "pauseOverlay"
        overlay.zPosition = 200

        let dim = SKShapeNode(rectOf: size)
        dim.fillColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        dim.strokeColor = .clear
        overlay.addChild(dim)

        let title = SKLabelNode(text: "PAUSED")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 36
        title.fontColor = UIColor(red: 1.0, green: 0.85, blue: 0.15, alpha: 1)
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: 60)
        overlay.addChild(title)

        addPauseButton(to: overlay, text: "RESUME", name: "resume",
                       color: UIColor(red: 0.2, green: 0.8, blue: 0.35, alpha: 1),
                       y: 0)
        addPauseButton(to: overlay, text: "MAIN MENU", name: "quitToMenu",
                       color: UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 1),
                       y: -50)

        addChild(overlay)
        pauseOverlay = overlay
    }

    private func addPauseButton(to parent: SKNode, text: String, name: String, color: UIColor, y: CGFloat) {
        let btn = SKNode()
        btn.name = name
        btn.position = CGPoint(x: 0, y: y)

        let bg = SKShapeNode(rectOf: CGSize(width: 200, height: 38), cornerRadius: 10)
        bg.fillColor = color.withAlphaComponent(0.25)
        bg.strokeColor = color
        bg.lineWidth = 2.5
        btn.addChild(bg)

        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = 16
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        btn.addChild(label)

        parent.addChild(btn)
    }

    private func dismissPauseMenu() {
        pauseOverlay?.removeFromParent()
        pauseOverlay = nil
        isGamePaused = false
        MusicManager.shared.resumeAll()
    }

    private func quitToMainMenu() {
        MusicManager.shared.stopAll()
        let menu = MainMenuScene(size: size)
        menu.scaleMode = scaleMode
        view?.presentScene(menu, transition: SKTransition.fade(withDuration: 0.4))
    }

    // MARK: - Jump

    private func performJump() {
        guard !isJumping else { return }
        isJumping = true

        // Visual: player scales up and adds shadow underneath
        let shadow = SKShapeNode(ellipseOf: CGSize(width: 40, height: 16))
        shadow.fillColor = UIColor(white: 0, alpha: 0.35)
        shadow.strokeColor = .clear
        shadow.position = player.position
        shadow.zPosition = player.zPosition - 1
        shadow.name = "jumpShadow"
        addChild(shadow)

        // Disable guard contact AND wall/counter collision so we can jump over obstacles
        player.physicsBody?.contactTestBitMask = PhysicsCategory.food
        player.physicsBody?.collisionBitMask = PhysicsCategory.none

        // Directional boost — launch in current movement direction
        let currentVel = player.physicsBody?.velocity ?? .zero
        let speed = sqrt(currentVel.dx * currentVel.dx + currentVel.dy * currentVel.dy)
        if speed > 10 {
            // Boost in the direction the player is already moving
            let nx = currentVel.dx / speed
            let ny = currentVel.dy / speed
            let boostStrength: CGFloat = 280
            player.physicsBody?.velocity = CGVector(dx: nx * boostStrength, dy: ny * boostStrength)
        } else if joystickTouch != nil {
            // Use joystick direction even if velocity hasn't built up yet
            let dx = joystickCurrent.x - joystickBase.x
            let dy = joystickCurrent.y - joystickBase.y
            let dist = sqrt(dx * dx + dy * dy)
            if dist > 5 {
                let nx = dx / dist
                let ny = dy / dist
                let boostStrength: CGFloat = 250
                player.physicsBody?.velocity = CGVector(dx: nx * boostStrength, dy: ny * boostStrength)
            }
        }

        // Raise zPosition so player visually floats over counters
        let originalZ = player.zPosition
        player.zPosition = 50

        let jumpUp = SKAction.group([
            SKAction.scale(to: 1.4, duration: jumpDuration * 0.45),
            SKAction.moveBy(x: 0, y: 20, duration: jumpDuration * 0.45)
        ])
        jumpUp.timingMode = .easeOut
        let jumpDown = SKAction.group([
            SKAction.scale(to: 1.0, duration: jumpDuration * 0.55),
            SKAction.moveBy(x: 0, y: -20, duration: jumpDuration * 0.55)
        ])
        jumpDown.timingMode = .easeIn

        player.run(SKAction.sequence([jumpUp, jumpDown])) { [weak self] in
            guard let self = self else { return }
            self.isJumping = false
            self.player.zPosition = originalZ
            // Restore collision and contact
            self.player.physicsBody?.contactTestBitMask = PhysicsCategory.food | PhysicsCategory.door
            self.player.physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.counter
            // Kill velocity on landing so player doesn't slide into walls
            self.player.physicsBody?.velocity = .zero
            shadow.removeFromParent()
        }

        // Shadow stays at launch position, shrinks/grows opposite to player
        shadow.run(SKAction.sequence([
            SKAction.scale(to: 0.6, duration: jumpDuration * 0.45),
            SKAction.scale(to: 1.0, duration: jumpDuration * 0.55),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Food Particles

    private func spawnFoodParticles(at pos: CGPoint, foodType: FoodType) {
        let colors: [UIColor] = foodType.isVegetable
            ? [.green, UIColor(red: 0.3, green: 0.9, blue: 0.4, alpha: 1), .yellow]
            : [foodType.bodyColor, foodType.accentColor, UIColor(red: 1, green: 0.9, blue: 0.3, alpha: 1)]

        // Burst of 12 particles
        for i in 0..<12 {
            let size = CGFloat.random(in: 3...8)
            let particle: SKShapeNode
            if i % 3 == 0 {
                particle = SKShapeNode(rectOf: CGSize(width: size, height: size), cornerRadius: 1)
            } else {
                particle = SKShapeNode(circleOfRadius: size / 2)
            }
            particle.fillColor = colors[i % colors.count]
            particle.strokeColor = .black
            particle.lineWidth = 0.8
            particle.position = pos
            particle.zPosition = 50

            // Sparkle glow for veggies
            if foodType.isVegetable {
                particle.glowWidth = 3
            }

            addChild(particle)

            let angle = CGFloat(i) / 12.0 * 2 * .pi + CGFloat.random(in: -0.3...0.3)
            let dist = CGFloat.random(in: 30...70)
            let dest = CGPoint(x: pos.x + cos(angle) * dist,
                               y: pos.y + sin(angle) * dist)

            let fly = SKAction.move(to: dest, duration: Double.random(in: 0.3...0.5))
            fly.timingMode = .easeOut
            let spin = SKAction.rotate(byAngle: CGFloat.random(in: -4...4), duration: 0.4)
            let fade = SKAction.fadeOut(withDuration: 0.25)
            let scaleDown = SKAction.scale(to: 0.2, duration: 0.35)

            particle.run(SKAction.sequence([
                SKAction.group([fly, spin, SKAction.sequence([
                    SKAction.wait(forDuration: 0.15),
                    SKAction.group([fade, scaleDown])
                ])]),
                SKAction.removeFromParent()
            ]))
        }

        // Score "+X" floating text at pickup
        let scoreText = SKLabelNode(text: "+\(foodType.points)")
        scoreText.fontName = "AvenirNext-Heavy"
        scoreText.fontSize = foodType.isHighValue ? 18 : 14
        scoreText.fontColor = foodType.isVegetable
            ? UIColor(red: 0.2, green: 1.0, blue: 0.4, alpha: 1)
            : UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1)
        scoreText.position = CGPoint(x: pos.x, y: pos.y + 15)
        scoreText.zPosition = 55
        addChild(scoreText)

        scoreText.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 40, duration: 0.8),
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.4),
                    SKAction.fadeOut(withDuration: 0.4)
                ])
            ]),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)

            // Check pause overlay buttons first
            if let overlay = pauseOverlay {
                let hits = overlay.nodes(at: overlay.convert(loc, from: self))
                    .compactMap { $0.name ?? $0.parent?.name }
                if hits.contains("resume") { dismissPauseMenu(); return }
                if hits.contains("quitToMenu") { quitToMainMenu(); return }
                return  // absorb all touches while paused
            }

            // Menu button
            let sceneHits = nodes(at: loc).compactMap { $0.name ?? $0.parent?.name }
            if sceneHits.contains("menuButton") {
                showPauseMenu()
                return
            }

            // Left half = joystick, right half = jump
            if loc.x < 0 && joystickTouch == nil {
                joystickTouch = touch
                joystickBase = loc
                joystickCurrent = loc

                joystickBaseNode.position = loc
                joystickBaseNode.isHidden = false
                joystickStickNode.position = loc
                joystickStickNode.isHidden = false
            } else if loc.x >= 0 {
                // Right side tap = jump
                performJump()
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard pauseOverlay == nil else { return }
        for touch in touches {
            if touch === joystickTouch {
                let loc = touch.location(in: self)
                joystickCurrent = loc

                let dx = loc.x - joystickBase.x
                let dy = loc.y - joystickBase.y
                let dist = sqrt(dx * dx + dy * dy)
                if dist <= joystickMaxRadius {
                    joystickStickNode.position = loc
                } else {
                    let nx = dx / dist
                    let ny = dy / dist
                    joystickStickNode.position = CGPoint(
                        x: joystickBase.x + nx * joystickMaxRadius,
                        y: joystickBase.y + ny * joystickMaxRadius
                    )
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch === joystickTouch {
                joystickTouch = nil
                joystickCurrent = joystickBase
                joystickBaseNode.isHidden = true
                joystickStickNode.isHidden = true
                player.physicsBody?.velocity = .zero
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}
