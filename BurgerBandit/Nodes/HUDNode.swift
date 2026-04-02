import SpriteKit

class HUDNode: SKNode {

    private var scoreLabel: SKLabelNode!
    private var livesContainer: SKNode!
    private var healthBarFill: SKShapeNode!
    private var healthBarBg: SKShapeNode!
    private var healthLabel: SKLabelNode!
    private var fatMeter: SKShapeNode!
    private var fatLabel: SKLabelNode!
    private var pickupLabel: SKLabelNode!

    private let barWidth: CGFloat = 120
    private let barHeight: CGFloat = 16

    // Position relative to scene (call after adding to scene)
    func setup(sceneSize: CGSize) {
        let top = sceneSize.height / 2 - 20
        let left = -sceneSize.width / 2 + 12

        buildBackground(sceneSize: sceneSize)
        buildScoreLabel(x: 0, y: top - 5)
        buildLives(x: left + 10, y: top - 5)
        buildHealthBar(x: left + 165, y: top - 5)
        buildFatMeter(x: sceneSize.width / 2 - 145, y: top - 5)
        buildPickupLabel(y: top - 60)
    }

    private func buildBackground(sceneSize: CGSize) {
        let bg = SKShapeNode(rectOf: CGSize(width: sceneSize.width, height: 40))
        bg.fillColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 0.85)
        bg.strokeColor = UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1)
        bg.lineWidth = 1.5
        bg.position = CGPoint(x: 0, y: sceneSize.height / 2 - 20)
        bg.zPosition = 98
        addChild(bg)
    }

    private func buildScoreLabel(x: CGFloat, y: CGFloat) {
        scoreLabel = SKLabelNode(text: "SCORE: 0")
        scoreLabel.fontName = "AvenirNext-Heavy"
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = UIColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: x, y: y)
        scoreLabel.zPosition = 99
        addChild(scoreLabel)
    }

    private func buildLives(x: CGFloat, y: CGFloat) {
        livesContainer = SKNode()
        livesContainer.position = CGPoint(x: x, y: y)
        livesContainer.zPosition = 99
        addChild(livesContainer)
        refreshLives(3)
    }

    private func refreshLives(_ count: Int) {
        livesContainer.removeAllChildren()
        for i in 0..<3 {
            let heart = makeHeartNode(filled: i < count)
            heart.position = CGPoint(x: CGFloat(i) * 22, y: 0)
            livesContainer.addChild(heart)
        }
    }

    private func makeHeartNode(filled: Bool) -> SKNode {
        let container = SKNode()
        // Simple burger icon for lives instead of hearts
        let circle = SKShapeNode(circleOfRadius: 9)
        circle.fillColor = filled
            ? UIColor(red: 0.95, green: 0.7, blue: 0.2, alpha: 1)
            : UIColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1)
        circle.strokeColor = .black
        circle.lineWidth = 2
        container.addChild(circle)

        if filled {
            // Mini burger inside
            let sesame = SKShapeNode(circleOfRadius: 9)
            sesame.fillColor = .clear
            sesame.strokeColor = UIColor(red: 0.7, green: 0.5, blue: 0.15, alpha: 0.5)
            sesame.lineWidth = 3
            container.addChild(sesame)
        }
        return container
    }

    private func buildHealthBar(x: CGFloat, y: CGFloat) {
        let container = SKNode()
        container.position = CGPoint(x: x, y: y)
        container.zPosition = 99
        addChild(container)

        // Label
        let title = SKLabelNode(text: "HEALTH")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 8
        title.fontColor = UIColor(white: 0.7, alpha: 1)
        title.horizontalAlignmentMode = .left
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: 10)
        container.addChild(title)

        // Background
        healthBarBg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight),
                                  cornerRadius: barHeight / 2)
        healthBarBg.fillColor = UIColor(white: 0.2, alpha: 1)
        healthBarBg.strokeColor = UIColor(white: 0.5, alpha: 1)
        healthBarBg.lineWidth = 1.5
        healthBarBg.position = CGPoint(x: barWidth / 2, y: 0)
        container.addChild(healthBarBg)

        // Fill — starts at full width
        healthBarFill = SKShapeNode(rectOf: CGSize(width: barWidth - 2, height: barHeight - 2),
                                    cornerRadius: (barHeight - 2) / 2)
        healthBarFill.fillColor = UIColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 1)
        healthBarFill.strokeColor = .clear
        healthBarFill.position = CGPoint(x: barWidth / 2, y: 0)
        container.addChild(healthBarFill)

        // Value label
        healthLabel = SKLabelNode(text: "100")
        healthLabel.fontName = "AvenirNext-Heavy"
        healthLabel.fontSize = 9
        healthLabel.fontColor = .white
        healthLabel.horizontalAlignmentMode = .center
        healthLabel.verticalAlignmentMode = .center
        healthLabel.position = CGPoint(x: barWidth / 2, y: 0)
        healthLabel.zPosition = 1
        container.addChild(healthLabel)
    }

    private func buildFatMeter(x: CGFloat, y: CGFloat) {
        let container = SKNode()
        container.position = CGPoint(x: x, y: y)
        container.zPosition = 99
        addChild(container)

        let title = SKLabelNode(text: "FAT-O-METER")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 8
        title.fontColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1)
        title.horizontalAlignmentMode = .left
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: 10)
        container.addChild(title)

        let bg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight),
                             cornerRadius: barHeight / 2)
        bg.fillColor = UIColor(white: 0.2, alpha: 1)
        bg.strokeColor = UIColor(white: 0.5, alpha: 1)
        bg.lineWidth = 1.5
        bg.position = CGPoint(x: barWidth / 2, y: 0)
        container.addChild(bg)

        fatMeter = SKShapeNode(rectOf: CGSize(width: 2, height: barHeight - 2),
                               cornerRadius: (barHeight - 2) / 2)
        fatMeter.fillColor = UIColor(red: 0.4, green: 0.85, blue: 0.4, alpha: 1)
        fatMeter.strokeColor = .clear
        fatMeter.position = CGPoint(x: 1, y: 0)  // anchored left
        container.addChild(fatMeter)

        fatLabel = SKLabelNode(text: "SLIM")
        fatLabel.fontName = "AvenirNext-Heavy"
        fatLabel.fontSize = 9
        fatLabel.fontColor = .white
        fatLabel.horizontalAlignmentMode = .center
        fatLabel.verticalAlignmentMode = .center
        fatLabel.position = CGPoint(x: barWidth / 2, y: 0)
        fatLabel.zPosition = 1
        container.addChild(fatLabel)
    }

    private func buildPickupLabel(y: CGFloat) {
        pickupLabel = SKLabelNode(text: "")
        pickupLabel.fontName = "AvenirNext-Heavy"
        pickupLabel.fontSize = 22
        pickupLabel.fontColor = UIColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1)
        pickupLabel.horizontalAlignmentMode = .center
        pickupLabel.verticalAlignmentMode = .center
        pickupLabel.position = CGPoint(x: 0, y: y)
        pickupLabel.zPosition = 99
        pickupLabel.alpha = 0
        addChild(pickupLabel)
    }

    // MARK: - Public update methods

    func updateScore(_ score: Int) {
        scoreLabel.text = "SCORE: \(score)"
        // Score pop
        let pop = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.08)
        ])
        scoreLabel.run(pop)
    }

    func updateLives(_ lives: Int) {
        refreshLives(lives)
    }

    func updateHealth(_ health: Int) {
        let fraction = CGFloat(health) / 100.0
        // Resize fill bar (width trick: scale X from 1)
        let newWidth = max(2, (barWidth - 2) * fraction)
        let newFill = SKShapeNode(rectOf: CGSize(width: newWidth, height: barHeight - 2),
                                  cornerRadius: (barHeight - 2) / 2)
        // Anchor left by offsetting position
        newFill.position = CGPoint(x: 1 + newWidth / 2, y: 0)

        // Color: green → yellow → orange → red
        let color: UIColor
        if fraction > 0.6 {
            color = UIColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 1)
        } else if fraction > 0.35 {
            color = UIColor(red: 0.95, green: 0.78, blue: 0.1, alpha: 1)
        } else if fraction > 0.15 {
            color = UIColor(red: 0.95, green: 0.45, blue: 0.1, alpha: 1)
        } else {
            color = UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1)
        }
        newFill.fillColor = color
        newFill.strokeColor = .clear
        newFill.zPosition = healthBarFill.zPosition

        healthBarFill.removeFromParent()
        healthBarFill.parent?.addChild(newFill)
        healthBarFill = newFill

        healthLabel.text = "\(health)"
    }

    func updateFatStage(_ stage: Int, fraction: CGFloat) {
        let labels = ["SLIM", "CHUBBY", "FAT", "OBESE!!"]
        fatLabel.text = labels[min(stage, 3)]

        let newWidth = max(2, (barWidth - 2) * fraction)
        let newFat = SKShapeNode(rectOf: CGSize(width: newWidth, height: barHeight - 2),
                                 cornerRadius: (barHeight - 2) / 2)
        newFat.position = CGPoint(x: 1 + newWidth / 2, y: 0)

        // Color: green → yellow → orange → red based on stage
        let colors: [UIColor] = [
            UIColor(red: 0.4, green: 0.85, blue: 0.4, alpha: 1),
            UIColor(red: 0.95, green: 0.78, blue: 0.1, alpha: 1),
            UIColor(red: 0.95, green: 0.45, blue: 0.1, alpha: 1),
            UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1)
        ]
        newFat.fillColor = colors[stage]
        newFat.strokeColor = .clear
        newFat.zPosition = fatMeter.zPosition

        fatMeter.removeFromParent()
        fatMeter.parent?.addChild(newFat)
        fatMeter = newFat

        // Shake label on stage change
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -3, y: 0, duration: 0.05),
            SKAction.moveBy(x: 6, y: 0, duration: 0.05),
            SKAction.moveBy(x: -3, y: 0, duration: 0.05)
        ])
        fatLabel.run(shake)
    }

    func showFoodPickup(_ foodType: FoodType, scoreAdded: Int) {
        let text = foodType.isVegetable
            ? "VEGGIE! +\(scoreAdded) ⚡️ SPEED BOOST!"
            : "\(foodType.displayName) +\(scoreAdded)"

        pickupLabel.text = text
        pickupLabel.fontColor = foodType.isVegetable
            ? UIColor(red: 0.2, green: 0.95, blue: 0.35, alpha: 1)
            : (foodType.isHighValue
               ? UIColor(red: 1.0, green: 0.85, blue: 0.1, alpha: 1)
               : UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1))

        pickupLabel.removeAllActions()
        pickupLabel.alpha = 1
        pickupLabel.setScale(0.8)

        let floatUp = SKAction.moveBy(x: 0, y: 30, duration: 1.2)
        let fadeIn  = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        let scale   = SKAction.scale(to: 1.0, duration: 0.1)
        let wait    = SKAction.wait(forDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.6)
        let reset   = SKAction.run { [weak self] in
            self?.pickupLabel.position.y -= 30
        }

        pickupLabel.run(SKAction.sequence([
            SKAction.group([fadeIn, scale]),
            SKAction.group([floatUp, SKAction.sequence([wait, fadeOut])]),
            reset
        ]))
    }

    func showGuardAlert() {
        let alert = SKLabelNode(text: "CAUGHT!")
        alert.fontName = "AvenirNext-Heavy"
        alert.fontSize = 28
        alert.fontColor = UIColor(red: 0.95, green: 0.1, blue: 0.1, alpha: 1)
        alert.horizontalAlignmentMode = .center
        alert.verticalAlignmentMode = .center
        alert.position = CGPoint(x: 0, y: 0)
        alert.zPosition = 100
        addChild(alert)

        alert.setScale(0)
        let appear = SKAction.scale(to: 1.2, duration: 0.15)
        let shrink = SKAction.scale(to: 1.0, duration: 0.1)
        let wait   = SKAction.wait(forDuration: 0.6)
        let fade   = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        alert.run(SKAction.sequence([appear, shrink, wait, fade, remove]))
    }
}
