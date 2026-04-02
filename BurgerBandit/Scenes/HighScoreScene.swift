import SpriteKit

class HighScoreScene: SKScene {

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = UIColor(red: 0.06, green: 0.05, blue: 0.04, alpha: 1)

        buildTitle()
        buildScoreList()
        buildBackButton()

        alpha = 0
        run(SKAction.fadeIn(withDuration: 0.35))
    }

    private func buildTitle() {
        let title = SKLabelNode(text: "🏆 HIGH SCORES 🏆")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 32
        title.fontColor = UIColor(red: 1.0, green: 0.85, blue: 0.15, alpha: 1)
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: size.height / 2 - 45)
        title.zPosition = 10
        addChild(title)
    }

    private func buildScoreList() {
        let scores = HighScoreManager.shared.scores
        let startY: CGFloat = size.height / 2 - 80
        let rowH: CGFloat = 28

        if scores.isEmpty {
            let empty = SKLabelNode(text: "No scores yet! Go steal some food!")
            empty.fontName = "AvenirNext-Medium"
            empty.fontSize = 16
            empty.fontColor = UIColor(white: 0.5, alpha: 1)
            empty.horizontalAlignmentMode = .center
            empty.position = CGPoint(x: 0, y: 0)
            empty.zPosition = 10
            addChild(empty)
            return
        }

        let maxVisible = min(scores.count, 10)
        for i in 0..<maxVisible {
            let entry = scores[i]
            let y = startY - CGFloat(i) * rowH

            // Rank
            let rankColors: [UIColor] = [
                UIColor(red: 1.0, green: 0.85, blue: 0.15, alpha: 1),  // gold
                UIColor(red: 0.8, green: 0.8, blue: 0.85, alpha: 1),   // silver
                UIColor(red: 0.85, green: 0.55, blue: 0.2, alpha: 1),  // bronze
            ]
            let color = i < 3 ? rankColors[i] : UIColor(white: 0.6, alpha: 1)

            let rank = SKLabelNode(text: "#\(i + 1)")
            rank.fontName = "AvenirNext-Heavy"
            rank.fontSize = 14
            rank.fontColor = color
            rank.horizontalAlignmentMode = .right
            rank.position = CGPoint(x: -200, y: y)
            rank.zPosition = 10
            addChild(rank)

            // Score
            let scoreLabel = SKLabelNode(text: "\(entry.score)")
            scoreLabel.fontName = "AvenirNext-Heavy"
            scoreLabel.fontSize = 16
            scoreLabel.fontColor = color
            scoreLabel.horizontalAlignmentMode = .left
            scoreLabel.position = CGPoint(x: -170, y: y)
            scoreLabel.zPosition = 10
            addChild(scoreLabel)

            // Details
            let detail = SKLabelNode(text: "\(entry.restaurant) · \(entry.difficulty)")
            detail.fontName = "AvenirNext-Medium"
            detail.fontSize = 11
            detail.fontColor = UIColor(white: 0.5, alpha: 1)
            detail.horizontalAlignmentMode = .left
            detail.position = CGPoint(x: -50, y: y)
            detail.zPosition = 10
            addChild(detail)

            // Fat stage indicator
            let fatLabels = ["SLIM", "CHUBBY", "FAT", "OBESE"]
            let fatText = fatLabels[min(entry.fatStage, 3)]
            let fatLabel = SKLabelNode(text: fatText)
            fatLabel.fontName = "AvenirNext-Bold"
            fatLabel.fontSize = 10
            fatLabel.fontColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.8)
            fatLabel.horizontalAlignmentMode = .left
            fatLabel.position = CGPoint(x: 150, y: y)
            fatLabel.zPosition = 10
            addChild(fatLabel)
        }
    }

    private func buildBackButton() {
        let btn = SKNode()
        btn.name = "backButton"
        btn.position = CGPoint(x: 0, y: -size.height / 2 + 35)
        btn.zPosition = 10

        let bg = SKShapeNode(rectOf: CGSize(width: 180, height: 36), cornerRadius: 10)
        bg.fillColor = UIColor(red: 0.4, green: 0.5, blue: 0.9, alpha: 0.25)
        bg.strokeColor = UIColor(red: 0.4, green: 0.5, blue: 0.9, alpha: 1)
        bg.lineWidth = 2.5
        btn.addChild(bg)

        let label = SKLabelNode(text: "BACK TO MENU")
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = 15
        label.fontColor = UIColor(red: 0.4, green: 0.5, blue: 0.9, alpha: 1)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        btn.addChild(label)

        addChild(btn)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hits = nodes(at: loc).compactMap { $0.name ?? $0.parent?.name }

        if hits.contains("backButton") {
            let menu = MainMenuScene(size: size)
            menu.scaleMode = scaleMode
            view?.presentScene(menu, transition: SKTransition.fade(withDuration: 0.35))
        }
    }
}
