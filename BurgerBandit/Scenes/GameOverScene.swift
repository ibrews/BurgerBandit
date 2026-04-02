import SpriteKit

class GameOverScene: SKScene {

    private let finalScore: Int
    private let finalFatStage: Int

    init(size: CGSize, score: Int, fatStage: Int) {
        self.finalScore = score
        self.finalFatStage = fatStage
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = UIColor(red: 0.06, green: 0.05, blue: 0.04, alpha: 1)
        buildBackground()
        buildCharacterDisplay()
        buildTitle()
        buildScoreDisplay()
        buildButtons()

        alpha = 0
        run(SKAction.fadeIn(withDuration: 0.5))
    }

    private func buildBackground() {
        // Scattered food items as decoration
        let foodEmojis = ["🍔", "🍟", "🍗", "🥤", "🧅"]
        for i in 0..<20 {
            let label = SKLabelNode(text: foodEmojis[i % foodEmojis.count])
            label.fontSize = CGFloat.random(in: 18...35)
            label.alpha = CGFloat.random(in: 0.08...0.18)
            label.position = CGPoint(
                x: CGFloat.random(in: -380...380),
                y: CGFloat.random(in: -170...170)
            )
            label.zPosition = -1
            label.zRotation = CGFloat.random(in: -1.0...1.0)
            addChild(label)
        }
    }

    private func buildCharacterDisplay() {
        // Show the fat burglar based on final stage
        let player = PlayerNode()
        player.updateFatStage(min(finalFatStage, 3), animated: false)
        player.position = CGPoint(x: -280, y: 20)
        player.setScale(2.0)
        player.zPosition = 5
        addChild(player)

        // Sad expression — tilt
        player.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.rotate(byAngle: 0.08, duration: 0.5),
            SKAction.rotate(byAngle: -0.16, duration: 1.0),
            SKAction.rotate(byAngle: 0.08, duration: 0.5)
        ])))

        // Fat stage label
        let fatLabels = ["SLIM & SPEEDY", "A BIT CHUBBY", "VERY FAT", "ABSOLUTELY HUGE!!"]
        let fatLabel = SKLabelNode(text: fatLabels[min(finalFatStage, 3)])
        fatLabel.fontName = "AvenirNext-Heavy"
        fatLabel.fontSize = 11
        fatLabel.fontColor = UIColor(red: 1.0, green: 0.65, blue: 0.15, alpha: 1)
        fatLabel.horizontalAlignmentMode = .center
        fatLabel.position = CGPoint(x: -280, y: -40)
        fatLabel.zPosition = 5
        addChild(fatLabel)

        let stageLabel = SKLabelNode(text: "Fat Stage: \(finalFatStage)/3")
        stageLabel.fontName = "AvenirNext-Medium"
        stageLabel.fontSize = 9
        stageLabel.fontColor = UIColor(white: 0.6, alpha: 1)
        stageLabel.horizontalAlignmentMode = .center
        stageLabel.position = CGPoint(x: -280, y: -56)
        stageLabel.zPosition = 5
        addChild(stageLabel)
    }

    private func buildTitle() {
        // Main outcome text
        let title = SKLabelNode(text: finalScore > 0 ? "BUSTED!" : "GAME OVER!")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 48
        title.fontColor = UIColor(red: 1.0, green: 0.12, blue: 0.08, alpha: 1)
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: 50, y: 120)
        title.zPosition = 8

        // Appear with bounce
        title.setScale(0.3)
        addChild(title)
        title.run(SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.25),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))

        // Funny subtitle based on score
        let subtitles: [(Int, String)] = [
            (200, "You absolute legend! The guards are still crying."),
            (100, "Not bad for a hungry thief!"),
            (50, "You call that a heist? Rookie numbers."),
            (0, "You barely stole a cracker. Pathetic.")
        ]
        let subtitle = subtitles.first(where: { finalScore >= $0.0 })?.1
            ?? "You barely stole a cracker. Pathetic."

        let subLabel = SKLabelNode(text: subtitle)
        subLabel.fontName = "AvenirNext-Medium"
        subLabel.fontSize = 11
        subLabel.fontColor = UIColor(white: 0.7, alpha: 1)
        subLabel.horizontalAlignmentMode = .center
        subLabel.position = CGPoint(x: 50, y: 98)
        subLabel.numberOfLines = 2
        subLabel.preferredMaxLayoutWidth = 380
        subLabel.zPosition = 8
        addChild(subLabel)
    }

    private func buildScoreDisplay() {
        // Score card
        let card = SKShapeNode(rectOf: CGSize(width: 280, height: 85), cornerRadius: 12)
        card.fillColor = UIColor(white: 1.0, alpha: 0.07)
        card.strokeColor = UIColor(red: 1.0, green: 0.85, blue: 0.15, alpha: 0.6)
        card.lineWidth = 2
        card.position = CGPoint(x: 50, y: 25)
        card.zPosition = 7
        addChild(card)

        let finalLabel = SKLabelNode(text: "FINAL SCORE")
        finalLabel.fontName = "AvenirNext-Bold"
        finalLabel.fontSize = 12
        finalLabel.fontColor = UIColor(white: 0.6, alpha: 1)
        finalLabel.horizontalAlignmentMode = .center
        finalLabel.position = CGPoint(x: 50, y: 50)
        finalLabel.zPosition = 8
        addChild(finalLabel)

        let scoreNum = SKLabelNode(text: "\(finalScore)")
        scoreNum.fontName = "AvenirNext-Heavy"
        scoreNum.fontSize = 44
        scoreNum.fontColor = UIColor(red: 1.0, green: 0.88, blue: 0.15, alpha: 1)
        scoreNum.horizontalAlignmentMode = .center
        scoreNum.position = CGPoint(x: 50, y: 10)
        scoreNum.zPosition = 8
        addChild(scoreNum)

        // Animate number counting up
        var displayScore = 0
        let increment = max(1, finalScore / 30)
        let countUp = SKAction.repeat(SKAction.sequence([
            SKAction.run { [weak self] in
                displayScore = min(displayScore + increment, self?.finalScore ?? 0)
                scoreNum.text = "\(displayScore)"
            },
            SKAction.wait(forDuration: 0.03)
        ]), count: 31)
        scoreNum.run(countUp)

        // Difficulty badge
        let diff = GameState.shared.difficulty
        let diffColors: [Difficulty: UIColor] = [
            .easy:   UIColor(red: 0.2, green: 0.85, blue: 0.35, alpha: 1),
            .medium: UIColor(red: 0.95, green: 0.75, blue: 0.1, alpha: 1),
            .hard:   UIColor(red: 0.95, green: 0.2, blue: 0.15, alpha: 1)
        ]
        let diffBadge = SKShapeNode(rectOf: CGSize(width: 70, height: 20), cornerRadius: 5)
        diffBadge.fillColor = (diffColors[diff] ?? .white).withAlphaComponent(0.25)
        diffBadge.strokeColor = diffColors[diff] ?? .white
        diffBadge.lineWidth = 1.5
        diffBadge.position = CGPoint(x: 50, y: -18)
        diffBadge.zPosition = 8
        addChild(diffBadge)

        let diffLabel = SKLabelNode(text: diff.displayName)
        diffLabel.fontName = "AvenirNext-Heavy"
        diffLabel.fontSize = 10
        diffLabel.fontColor = diffColors[diff] ?? .white
        diffLabel.horizontalAlignmentMode = .center
        diffLabel.verticalAlignmentMode = .center
        diffLabel.position = CGPoint(x: 50, y: -18)
        diffLabel.zPosition = 9
        addChild(diffLabel)
    }

    private func buildButtons() {
        // Play Again
        addButton(text: "PLAY AGAIN", color: UIColor(red: 0.2, green: 0.75, blue: 0.3, alpha: 1),
                  position: CGPoint(x: 50, y: -75), name: "playAgain")

        // Main Menu
        addButton(text: "MAIN MENU", color: UIColor(red: 0.4, green: 0.5, blue: 0.9, alpha: 1),
                  position: CGPoint(x: 50, y: -118), name: "mainMenu")
    }

    private func addButton(text: String, color: UIColor, position: CGPoint, name: String) {
        let btn = SKNode()
        btn.position = position
        btn.name = name
        btn.zPosition = 9

        let bg = SKShapeNode(rectOf: CGSize(width: 190, height: 36), cornerRadius: 10)
        bg.fillColor = color.withAlphaComponent(0.25)
        bg.strokeColor = color
        bg.lineWidth = 2.5
        btn.addChild(bg)

        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = 15
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        btn.addChild(label)

        addChild(btn)
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hit = nodes(at: loc).compactMap { $0.name ?? $0.parent?.name }

        if hit.contains("playAgain") {
            GameState.shared.reset()
            let game = GameScene(size: size)
            game.scaleMode = scaleMode
            view?.presentScene(game, transition: SKTransition.push(with: .right, duration: 0.35))
        } else if hit.contains("mainMenu") {
            let menu = MainMenuScene(size: size)
            menu.scaleMode = scaleMode
            view?.presentScene(menu, transition: SKTransition.fade(withDuration: 0.4))
        }
    }
}
