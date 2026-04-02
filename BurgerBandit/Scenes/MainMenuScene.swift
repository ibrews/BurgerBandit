import SpriteKit

class MainMenuScene: SKScene {

    private var selectedDifficulty: Difficulty = .medium
    private var selectedRestaurant: RestaurantType = .burgerBarn
    private var restaurantCards: [SKNode] = []
    private var difficultyButtons: [SKNode] = []
    private var bouncingBurger: SKNode!

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = UIColor(red: 0.08, green: 0.07, blue: 0.06, alpha: 1)
        buildBackground()
        buildTitle()
        buildBouncingBurger()
        buildRestaurantSelection()
        buildDifficultySelection()
        buildPlayButton()
        buildHighScoreButton()
        buildVersionLabel()

        // Animate in
        alpha = 0
        run(SKAction.fadeIn(withDuration: 0.4))
    }

    // MARK: - Build Methods

    private func buildBackground() {
        // Checkerboard subtle background tiles
        let tileSize: CGFloat = 50
        for col in stride(from: CGFloat(-420), through: 420, by: tileSize) {
            for row in stride(from: CGFloat(-200), through: 200, by: tileSize) {
                let isAlt = (Int(col / tileSize) + Int(row / tileSize)) % 2 == 0
                if isAlt { continue }
                let tile = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize))
                tile.fillColor = UIColor(white: 1.0, alpha: 0.025)
                tile.strokeColor = .clear
                tile.position = CGPoint(x: col + tileSize/2, y: row + tileSize/2)
                tile.zPosition = -1
                addChild(tile)
            }
        }
    }

    private func buildTitle() {
        // Shadow
        let shadow = SKLabelNode(text: "BURGER BANDIT!")
        shadow.fontName = "AvenirNext-Heavy"
        shadow.fontSize = 42
        shadow.fontColor = UIColor(red: 0.4, green: 0.1, blue: 0.0, alpha: 1)
        shadow.position = CGPoint(x: 2, y: 142)
        shadow.zPosition = 5
        addChild(shadow)

        // Main title
        let title = SKLabelNode(text: "BURGER BANDIT!")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 42
        title.fontColor = UIColor(red: 1.0, green: 0.85, blue: 0.15, alpha: 1)
        title.position = CGPoint(x: 0, y: 144)
        title.zPosition = 6
        addChild(title)

        // Outline effect: stroke via multiple copies
        for offset in [CGPoint(x: 2, y: 0), CGPoint(x: -2, y: 0),
                        CGPoint(x: 0, y: 2), CGPoint(x: 0, y: -2)] {
            let outline = SKLabelNode(text: "BURGER BANDIT!")
            outline.fontName = "AvenirNext-Heavy"
            outline.fontSize = 42
            outline.fontColor = .black
            outline.position = CGPoint(x: offset.x, y: 144 + offset.y)
            outline.zPosition = 5
            addChild(outline)
        }
        title.zPosition = 6  // ensure main is on top

        // Subtitle
        let sub = SKLabelNode(text: "🍔 The world's tastiest heist! 🍟")
        sub.fontName = "AvenirNext-Bold"
        sub.fontSize = 14
        sub.fontColor = UIColor(red: 0.95, green: 0.75, blue: 0.4, alpha: 1)
        sub.position = CGPoint(x: 0, y: 120)
        sub.zPosition = 6
        addChild(sub)

        // Wobble animation on title
        let wobble = SKAction.sequence([
            SKAction.rotate(byAngle: 0.03, duration: 0.15),
            SKAction.rotate(byAngle: -0.06, duration: 0.3),
            SKAction.rotate(byAngle: 0.03, duration: 0.15),
            SKAction.wait(forDuration: 2.5)
        ])
        title.run(SKAction.repeatForever(wobble))
    }

    private func buildBouncingBurger() {
        let burger = SKNode()
        burger.position = CGPoint(x: -320, y: 50)
        burger.zPosition = 10
        addChild(burger)
        bouncingBurger = burger

        // Build a big decorative burger
        let bunBottom = SKShapeNode(ellipseOf: CGSize(width: 70, height: 35))
        bunBottom.fillColor = UIColor(red: 0.92, green: 0.72, blue: 0.35, alpha: 1)
        bunBottom.strokeColor = .black
        bunBottom.lineWidth = 3
        bunBottom.position = CGPoint(x: 0, y: -10)
        burger.addChild(bunBottom)

        let patty = SKShapeNode(ellipseOf: CGSize(width: 65, height: 20))
        patty.fillColor = UIColor(red: 0.55, green: 0.28, blue: 0.1, alpha: 1)
        patty.strokeColor = .black
        patty.lineWidth = 2.5
        patty.position = CGPoint(x: 0, y: 0)
        burger.addChild(patty)

        let lettuce = SKShapeNode(ellipseOf: CGSize(width: 72, height: 14))
        lettuce.fillColor = UIColor(red: 0.3, green: 0.82, blue: 0.3, alpha: 1)
        lettuce.strokeColor = .black
        lettuce.lineWidth = 2
        lettuce.position = CGPoint(x: 0, y: 8)
        burger.addChild(lettuce)

        let bunTop = SKShapeNode(ellipseOf: CGSize(width: 68, height: 40))
        bunTop.fillColor = UIColor(red: 0.92, green: 0.72, blue: 0.35, alpha: 1)
        bunTop.strokeColor = .black
        bunTop.lineWidth = 3
        bunTop.position = CGPoint(x: 0, y: 22)
        burger.addChild(bunTop)

        // Sesame seeds
        for i in 0..<5 {
            let angle = CGFloat(i) / 5 * 2 * .pi
            let seed = SKShapeNode(ellipseOf: CGSize(width: 7, height: 4))
            seed.fillColor = UIColor(red: 0.95, green: 0.9, blue: 0.7, alpha: 1)
            seed.strokeColor = .clear
            seed.position = CGPoint(x: cos(angle) * 20, y: 22 + sin(angle) * 10)
            seed.zRotation = angle
            burger.addChild(seed)
        }

        // Bounce animation
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 12, duration: 0.45),
            SKAction.moveBy(x: 0, y: -12, duration: 0.35)
        ])
        bounce.timingMode = .easeInEaseOut
        burger.run(SKAction.repeatForever(bounce))

        // Spin slightly
        let spin = SKAction.rotate(byAngle: 0.1, duration: 1.5)
        burger.run(SKAction.sequence([spin, spin.reversed(), SKAction.wait(forDuration: 0.5)]))
    }

    private func buildRestaurantSelection() {
        let label = makeSectionLabel("CHOOSE YOUR HEIST LOCATION:", y: 82)
        addChild(label)

        let restaurants = RestaurantType.allCases
        let cardW: CGFloat = 135
        let cardH: CGFloat = 55
        let spacing: CGFloat = 148
        let startX = -spacing * 1.5

        for (i, restaurant) in restaurants.enumerated() {
            let card = buildRestaurantCard(restaurant, width: cardW, height: cardH)
            card.position = CGPoint(x: startX + CGFloat(i) * spacing, y: 50)
            card.name = "restaurant_\(restaurant.rawValue)"
            card.zPosition = 8
            addChild(card)
            restaurantCards.append(card)
        }

        // Highlight default selection
        updateRestaurantHighlight()
    }

    private func buildRestaurantCard(_ restaurant: RestaurantType, width: CGFloat, height: CGFloat) -> SKNode {
        let card = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 8)
        bg.fillColor = restaurant.primaryColor.withAlphaComponent(0.25)
        bg.strokeColor = restaurant.primaryColor
        bg.lineWidth = 2.5
        bg.name = "cardBg"
        card.addChild(bg)

        let nameLabel = SKLabelNode(text: restaurant.displayName)
        nameLabel.fontName = "AvenirNext-Heavy"
        nameLabel.fontSize = 12
        nameLabel.fontColor = .white
        nameLabel.horizontalAlignmentMode = .center
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = CGPoint(x: 0, y: 10)
        card.addChild(nameLabel)

        let tagLabel = SKLabelNode(text: restaurant.tagline)
        tagLabel.fontName = "AvenirNext-Medium"
        tagLabel.fontSize = 7
        tagLabel.fontColor = UIColor(white: 0.7, alpha: 1)
        tagLabel.horizontalAlignmentMode = .center
        tagLabel.verticalAlignmentMode = .center
        tagLabel.position = CGPoint(x: 0, y: -10)
        tagLabel.preferredMaxLayoutWidth = width - 10
        tagLabel.numberOfLines = 2
        card.addChild(tagLabel)

        // Color swatch
        let swatch = SKShapeNode(rectOf: CGSize(width: width - 8, height: 5), cornerRadius: 2)
        swatch.fillColor = restaurant.primaryColor
        swatch.strokeColor = .clear
        swatch.position = CGPoint(x: 0, y: -22)
        card.addChild(swatch)

        return card
    }

    private func buildDifficultySelection() {
        let label = makeSectionLabel("DIFFICULTY:", y: -5)
        addChild(label)

        let difficulties = Difficulty.allCases
        let btnW: CGFloat = 90
        let spacing: CGFloat = 105
        let startX = -spacing * 1.0

        let colors: [UIColor] = [
            UIColor(red: 0.2, green: 0.85, blue: 0.35, alpha: 1),
            UIColor(red: 0.95, green: 0.75, blue: 0.1, alpha: 1),
            UIColor(red: 0.95, green: 0.2, blue: 0.15, alpha: 1)
        ]

        for (i, diff) in difficulties.enumerated() {
            let btn = buildDifficultyButton(diff, color: colors[i], width: btnW)
            btn.position = CGPoint(x: startX + CGFloat(i) * spacing, y: -35)
            btn.name = "difficulty_\(diff.rawValue)"
            btn.zPosition = 8
            addChild(btn)
            difficultyButtons.append(btn)
        }

        updateDifficultyHighlight()
    }

    private func buildDifficultyButton(_ diff: Difficulty, color: UIColor, width: CGFloat) -> SKNode {
        let btn = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: width, height: 32), cornerRadius: 8)
        bg.fillColor = color.withAlphaComponent(0.2)
        bg.strokeColor = color
        bg.lineWidth = 2.5
        bg.name = "diffBg"
        btn.addChild(bg)

        let label = SKLabelNode(text: diff.displayName)
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = 13
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        btn.addChild(label)

        return btn
    }

    private func buildHighScoreButton() {
        let btn = SKNode()
        btn.position = CGPoint(x: 280, y: -90)
        btn.name = "highScoreButton"
        btn.zPosition = 9

        let bg = SKShapeNode(rectOf: CGSize(width: 120, height: 34), cornerRadius: 10)
        bg.fillColor = UIColor(red: 0.4, green: 0.5, blue: 0.9, alpha: 0.2)
        bg.strokeColor = UIColor(red: 0.4, green: 0.5, blue: 0.9, alpha: 1)
        bg.lineWidth = 2
        btn.addChild(bg)

        let label = SKLabelNode(text: "🏆 SCORES")
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = 13
        label.fontColor = UIColor(red: 0.5, green: 0.6, blue: 1.0, alpha: 1)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        btn.addChild(label)

        // High score preview
        let hs = HighScoreManager.shared.highScore
        if hs > 0 {
            let hsLabel = SKLabelNode(text: "Best: \(hs)")
            hsLabel.fontName = "AvenirNext-Medium"
            hsLabel.fontSize = 9
            hsLabel.fontColor = UIColor(white: 0.5, alpha: 1)
            hsLabel.horizontalAlignmentMode = .center
            hsLabel.position = CGPoint(x: 0, y: -23)
            btn.addChild(hsLabel)
        }

        addChild(btn)
    }

    private func buildPlayButton() {
        let btn = SKNode()
        btn.position = CGPoint(x: 0, y: -90)
        btn.name = "playButton"
        btn.zPosition = 9

        // Pulsing glow behind button
        let glow = SKShapeNode(rectOf: CGSize(width: 165, height: 48), cornerRadius: 14)
        glow.fillColor = UIColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 0.15)
        glow.strokeColor = .clear
        glow.name = "glow"
        btn.addChild(glow)

        let bg = SKShapeNode(rectOf: CGSize(width: 160, height: 44), cornerRadius: 12)
        bg.fillColor = UIColor(red: 1.0, green: 0.15, blue: 0.1, alpha: 1)
        bg.strokeColor = .black
        bg.lineWidth = 3.5
        btn.addChild(bg)

        // Inner highlight
        let highlight = SKShapeNode(rectOf: CGSize(width: 154, height: 18), cornerRadius: 8)
        highlight.fillColor = UIColor(white: 1.0, alpha: 0.12)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: 0, y: 8)
        btn.addChild(highlight)

        let label = SKLabelNode(text: "🍔  STEAL FOOD!  🍔")
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = 18
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        btn.addChild(label)

        addChild(btn)

        // Pulse animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        btn.run(SKAction.repeatForever(pulse))
    }

    private func buildVersionLabel() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        let vLabel = SKLabelNode(text: "v\(version) (\(build))")
        vLabel.fontName = "AvenirNext-Regular"
        vLabel.fontSize = 10
        vLabel.fontColor = UIColor(white: 0.4, alpha: 1)
        vLabel.horizontalAlignmentMode = .right
        vLabel.verticalAlignmentMode = .bottom
        vLabel.position = CGPoint(x: size.width / 2 - 10, y: -size.height / 2 + 4)
        vLabel.zPosition = 5
        addChild(vLabel)
    }

    private func makeSectionLabel(_ text: String, y: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = 11
        label.fontColor = UIColor(white: 0.6, alpha: 1)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: -80, y: y)
        label.zPosition = 7
        return label
    }

    // MARK: - Selection Highlighting

    private func updateRestaurantHighlight() {
        for card in restaurantCards {
            guard let rawValue = card.name?.replacingOccurrences(of: "restaurant_", with: ""),
                  let restaurant = RestaurantType(rawValue: rawValue) else { continue }
            let isSelected = restaurant == selectedRestaurant
            if let bg = card.childNode(withName: "cardBg") as? SKShapeNode {
                bg.fillColor = isSelected
                    ? restaurant.primaryColor.withAlphaComponent(0.55)
                    : restaurant.primaryColor.withAlphaComponent(0.2)
                bg.lineWidth = isSelected ? 4 : 2
            }
            card.setScale(isSelected ? 1.06 : 1.0)
        }
    }

    private func updateDifficultyHighlight() {
        let colors: [Difficulty: UIColor] = [
            .easy:   UIColor(red: 0.2, green: 0.85, blue: 0.35, alpha: 1),
            .medium: UIColor(red: 0.95, green: 0.75, blue: 0.1, alpha: 1),
            .hard:   UIColor(red: 0.95, green: 0.2, blue: 0.15, alpha: 1)
        ]
        for btn in difficultyButtons {
            guard let rawValue = btn.name?.replacingOccurrences(of: "difficulty_", with: ""),
                  let diff = Difficulty(rawValue: rawValue) else { continue }
            let isSelected = diff == selectedDifficulty
            let color = colors[diff]!
            if let bg = btn.childNode(withName: "diffBg") as? SKShapeNode {
                bg.fillColor = isSelected ? color.withAlphaComponent(0.5) : color.withAlphaComponent(0.15)
                bg.lineWidth = isSelected ? 3.5 : 2
            }
            btn.setScale(isSelected ? 1.08 : 1.0)
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let nodes = self.nodes(at: loc)

        for node in nodes {
            let name = node.name ?? node.parent?.name ?? ""

            if name == "playButton" || node.parent?.name == "playButton" {
                tapPlayButton()
                return
            }

            if name == "highScoreButton" || node.parent?.name == "highScoreButton" {
                let hs = HighScoreScene(size: size)
                hs.scaleMode = scaleMode
                view?.presentScene(hs, transition: SKTransition.push(with: .left, duration: 0.35))
                return
            }

            if name.hasPrefix("restaurant_") {
                let rawValue = name.replacingOccurrences(of: "restaurant_", with: "")
                if let r = RestaurantType(rawValue: rawValue) {
                    selectedRestaurant = r
                    updateRestaurantHighlight()
                    playSelectSound()
                }
                return
            }

            if name.hasPrefix("difficulty_") {
                let rawValue = name.replacingOccurrences(of: "difficulty_", with: "")
                if let d = Difficulty(rawValue: rawValue) {
                    selectedDifficulty = d
                    updateDifficultyHighlight()
                    playSelectSound()
                }
                return
            }
        }
    }

    private func tapPlayButton() {
        // Save selections
        GameState.shared.difficulty = selectedDifficulty
        GameState.shared.selectedRestaurant = selectedRestaurant
        GameState.shared.reset()

        // Button press effect
        if let btn = childNode(withName: "playButton") {
            let press = SKAction.sequence([
                SKAction.scale(to: 0.92, duration: 0.08),
                SKAction.scale(to: 1.0, duration: 0.08)
            ])
            btn.run(press) { [weak self] in
                self?.transitionToGame()
            }
        } else {
            transitionToGame()
        }
    }

    private func transitionToGame() {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        let transition = SKTransition.push(with: .left, duration: 0.4)
        view?.presentScene(gameScene, transition: transition)
    }

    private func playSelectSound() {
        // Gentle scale pop feedback
        run(SKAction.sequence([
            SKAction.scale(to: 1.02, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.05)
        ]))
    }
}

