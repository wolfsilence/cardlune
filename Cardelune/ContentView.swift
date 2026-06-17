

import SwiftUI
import UIKit
import Combine

struct RiddleCard: Identifiable, Equatable {
    let id = UUID()
    let rank: String
    let suit: String
    let color: Color

    var isRevealed = false
    var isSolved = false

    var displaySymbol: String { "\(rank)\(suit)" }

    static func == (lhs: RiddleCard, rhs: RiddleCard) -> Bool {
        lhs.id == rhs.id
    }
}

struct RiddleDie: Identifiable, Equatable {
    let id = UUID()
    let number: Int
    let color: Color
    let dots: [Bool]

    static func == (lhs: RiddleDie, rhs: RiddleDie) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - GAME MODES

enum GameModeType: String, CaseIterable, Equatable {
    case timed = "Timed"
    case relaxed = "Relaxed"
    case challenge = "Challenge"
    case zen = "Zen"

    var icon: String {
        switch self {
        case .timed: return "timer"
        case .relaxed: return "leaf"
        case .challenge: return "bolt"
        case .zen: return "moon"
        }
    }

    var description: String {
        switch self {
        case .timed: return "Beat the clock"
        case .relaxed: return "No pressure"
        case .challenge: return "Hardcore mode"
        case .zen: return "Infinite calm"
        }
    }

    var color: Color {
        switch self {
        case .timed: return .orange
        case .relaxed: return .green
        case .challenge: return .red
        case .zen: return .purple
        }
    }
}

// MARK: - THEME

struct AppColors {
    // Almond / premium warm palette
    static let bgGradient: [Color] = [
        Color(red: 0.18, green: 0.10, blue: 0.06),
        Color(red: 0.43, green: 0.25, blue: 0.14),
        Color(red: 0.82, green: 0.63, blue: 0.40)
    ]

    static let accent = Color(red: 0.98, green: 0.78, blue: 0.42)      // warm almond gold
    static let cream = Color(red: 1.00, green: 0.91, blue: 0.76)       // soft cream
    static let cocoa = Color(red: 0.28, green: 0.14, blue: 0.08)       // deep cocoa
    static let caramel = Color(red: 0.72, green: 0.43, blue: 0.20)     // caramel
    static let almond = Color(red: 0.93, green: 0.72, blue: 0.48)      // almond
    static let bronze = Color(red: 0.58, green: 0.34, blue: 0.17)      // bronze
    static let glass = Color.white.opacity(0.16)

    static let cardCream = Color.white
    static let cardStroke = Color.black.opacity(0.78)
    static let cardBack = Color.white
    static let ink = Color.black
    static let softShadow = Color.black.opacity(0.18)
}

// MARK: - BOARD SHAPES

enum BoardShape: String, CaseIterable, Equatable {
    case constellation, vortex, crescent, fibonacci, lotus, echo, helix, ripple, compass

    var emoji: String {
        switch self {
        case .constellation: return "✨"
        case .vortex: return "🌀"
        case .crescent: return "🌙"
        case .fibonacci: return "🐚"
        case .lotus: return "🪷"
        case .echo: return "📡"
        case .helix: return "🧬"
        case .ripple: return "💧"
        case .compass: return "🧭"
        }
    }

    func position(for index: Int, total: Int, in size: CGSize) -> CGPoint {
        let cx = size.width / 2
        let cy = size.height / 2
        let r = min(size.width, size.height) * 0.32

        switch self {
        case .constellation:
            let ga = Double(index) * 2.399963
            let radius = Double(r) * (0.4 + 0.6 * Double(index % 3) / 3.0)
            return CGPoint(
                x: cx + CGFloat(radius) * CGFloat(cos(ga)),
                y: cy + CGFloat(radius) * CGFloat(sin(ga))
            )

        case .vortex:
            let t = Double(index) / Double(max(total - 1, 1))
            let angle = 6 * Double.pi * t
            let radius = r * CGFloat(1 - t * 0.7)
            return CGPoint(
                x: cx + radius * CGFloat(cos(angle)),
                y: cy + radius * CGFloat(sin(angle))
            )

        case .crescent:
            let angle = (Double.pi * Double(index)) / Double(max(total - 1, 1)) + Double.pi / 4
            let moonR = r * 0.8
            return CGPoint(
                x: cx + moonR * CGFloat(cos(angle)),
                y: cy + moonR * CGFloat(sin(angle)) - r * 0.3
            )

        case .fibonacci:
            let phi: CGFloat = 1.618034
            let a = CGFloat(index) * 0.8
            let fibR = r * pow(phi, CGFloat(index) * 0.15) * 0.25
            return CGPoint(
                x: cx + fibR * cos(a),
                y: cy + fibR * sin(a)
            )

        case .lotus:
            let petalIndex = index % 6
            let layer = index / 6
            let baseAngle = (2 * Double.pi * Double(petalIndex)) / 6.0
            let petalRadius = r * (0.3 + CGFloat(layer) * 0.2)
            let offset = layer % 2 == 0 ? 0.15 : -0.15
            return CGPoint(
                x: cx + petalRadius * CGFloat(cos(baseAngle + offset)),
                y: cy + petalRadius * CGFloat(sin(baseAngle + offset))
            )

        case .echo:
            let ring = index / 4
            let posInRing = index % 4
            let ringR = r * (0.2 + CGFloat(ring) * 0.2)
            let a = (2 * Double.pi * Double(posInRing)) / 4.0 + Double(ring) * 0.5
            return CGPoint(
                x: cx + ringR * CGFloat(cos(a)),
                y: cy + ringR * CGFloat(sin(a))
            )

        case .helix:
            let strand = index % 2
            let pairIndex = index / 2
            let totalPairs = max(total / 2, 1)
            let progress = Double(pairIndex) / Double(max(totalPairs - 1, 1))
            let a = progress * 4 * Double.pi
            let xPos = (CGFloat(progress) - 0.5) * r * 1.6
            let yOff: CGFloat = strand == 0 ? r * 0.2 : -r * 0.2
            return CGPoint(
                x: cx + xPos,
                y: cy + CGFloat(sin(a)) * r * 0.6 + yOff
            )

        case .ripple:
            let ring = index / 6
            let posInRing = index % 6
            let maxRings = max(total / 6, 1)
            let ringR = r * (0.15 + CGFloat(ring) * (0.7 / CGFloat(maxRings)))
            let a = (2 * Double.pi * Double(posInRing)) / 6.0
            let waveOff = CGFloat(sin(Double(ring) * 2.0)) * 10
            return CGPoint(
                x: cx + ringR * CGFloat(cos(a)),
                y: cy + ringR * CGFloat(sin(a)) + waveOff
            )

        case .compass:
            let dirIndex = index % 8
            let distance = index / 8
            let baseAngle = (2 * Double.pi * Double(dirIndex)) / 8.0 - Double.pi / 2
            let dist = r * (0.4 + CGFloat(distance) * 0.25)
            let finalDist = dirIndex % 2 == 0 ? dist * 1.3 : dist * 0.8
            return CGPoint(
                x: cx + finalDist * CGFloat(cos(baseAngle)),
                y: cy + finalDist * CGFloat(sin(baseAngle))
            )
        }
    }
}

// MARK: - GAME TYPE

enum GameType: String, CaseIterable, Equatable {
    case cards, dice
    var title: String { self == .cards ? "Card Riddles" : "Dice Rolls" }
    var icon: String { self == .cards ? "🃏" : "🎲" }
}

// MARK: - LEVEL

struct GameLevel: Identifiable, Equatable {
    let id: Int
    let name: String
    let shape: BoardShape
    let itemCount: Int
    let timeLimit: Int
    let gameType: GameType
}

// MARK: - ACHIEVEMENT

struct Achievement: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    var isUnlocked = false
}

// MARK: - VIEW MODEL

final class CardeluneGame: ObservableObject {
    @Published var cards: [RiddleCard] = []
    @Published var dice: [RiddleDie] = []
    @Published var targetCard: RiddleCard?
    @Published var targetNumber: Int?
    @Published var selectedIndex: Int?
    @Published var score = 0
    @Published var highScore = 0
    @Published var timeRemaining = 0
    @Published var gamePhase: GamePhase = .memorize
    @Published var message = ""
    @Published var swapOffsets: [CGFloat] = []
    @Published var currentSwapStep = 0
    @Published var showGameComplete = false
    @Published var selectedGameType: GameType = .cards
    @Published var currentLevel: GameLevel?
    @Published var gameState: GameState = .menu
    @Published var streak = 0
    @Published var levelIndex = 0
    @Published var bounceCard: Int?
    @Published var gameMode: GameModeType = .timed
    @Published var totalCorrect = 0
    @Published var totalAttempts = 0
    @Published var comboMultiplier = 1.0
    @Published var achievements: [Achievement] = []
    @Published var showAchievement = false
    @Published var latestAchievement: Achievement?
    @Published var confettiParticles: [(id: Int, x: CGFloat, y: CGFloat, color: Color)] = []
    @Published var showConfetti = false
    @Published var lastAction: LastAction?
    @Published var canUndo = false
    @Published var showHowToPlay = false
    @Published var floatingEmojis: [(emoji: String, x: CGFloat, y: CGFloat, scale: CGFloat, opacity: Double)] = []
    @Published var shakeOffset: CGFloat = 0
    @Published var powerUps: Int = 6
    @Published var lives: Int = 3
    @Published var almondCoins: Int = 0
    @Published var perfectLevel = true
    @Published var shieldActive = false
    @Published var revealFlashActive = false
    @Published var eliminatedIndices: Set<Int> = []
    @Published var oracleHintIndex: Int?
    @Published var timeShardUsed = false
    @Published var shieldUsed = false
    @Published var revealUsed = false
    @Published var focusLensActive = false
    @Published var focusLensUsed = false
    @Published var doubleScoreActive = false
    @Published var doubleScoreUsed = false
    @Published var isTimeFrozen = false
    @Published var isXRayActive = false
    @Published var isVortexing = false
    @Published var vortexRotation: Double = 0

    var guessingStartTime: Date?

    struct LastAction {
        let selectedIndex: Int?
        let phase: GamePhase
    }

    enum GameState {
        case menu, playing, levelComplete, gameOver
    }

    enum GamePhase {
        case memorize, swapping, guessing, result
    }

    let suits = ["♠️", "♥️", "♦️", "♣️"]
    let ranks = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

    let cardLevels = [
        GameLevel(id: 1, name: "Constellation", shape: .constellation, itemCount: 8, timeLimit: 55, gameType: .cards),
        GameLevel(id: 2, name: "Vortex", shape: .vortex, itemCount: 10, timeLimit: 50, gameType: .cards),
        GameLevel(id: 3, name: "Fibonacci", shape: .fibonacci, itemCount: 12, timeLimit: 45, gameType: .cards),
        GameLevel(id: 4, name: "Lotus", shape: .lotus, itemCount: 14, timeLimit: 40, gameType: .cards),
        GameLevel(id: 5, name: "Helix", shape: .helix, itemCount: 16, timeLimit: 35, gameType: .cards)
    ]

    let diceLevels = [
        GameLevel(id: 1, name: "Crescent", shape: .crescent, itemCount: 9, timeLimit: 60, gameType: .dice),
        GameLevel(id: 2, name: "Echo", shape: .echo, itemCount: 12, timeLimit: 50, gameType: .dice),
        GameLevel(id: 3, name: "Ripple", shape: .ripple, itemCount: 14, timeLimit: 45, gameType: .dice),
        GameLevel(id: 4, name: "Compass", shape: .compass, itemCount: 16, timeLimit: 40, gameType: .dice)
    ]

    init() {
        highScore = UserDefaults.standard.integer(forKey: "cardelune_highscore")
        achievements = [
            Achievement(title: "First Steps", description: "Complete first level", icon: "🌟"),
            Achievement(title: "Sharp Mind", description: "5 streak", icon: "💎"),
            Achievement(title: "Perfect Round", description: "No mistakes", icon: "👑"),
            Achievement(title: "Speed Demon", description: "Under 10s", icon: "⚡"),
            Achievement(title: "Centurion", description: "500 points", icon: "🏆"),
            Achievement(title: "Marathon", description: "20 rounds", icon: "🎯")
        ]
        setupFloatingEmojis()
    }

    func setupFloatingEmojis() {
        var list: [(String, CGFloat, CGFloat, CGFloat, Double)] = []
        let items = ["✨", "💫", "🌟", "⚡️", "💎", "☄️", "🔥"]
        for i in 0..<20 {
            let x = CGFloat.random(in: 0...UIScreen.main.bounds.width)
            let y = CGFloat.random(in: 0...UIScreen.main.bounds.height)
            let s = CGFloat.random(in: 0.5...1.5)
            let o = Double.random(in: 0.15...0.35)
            list.append((items[i % items.count], x, y, s, o))
        }
        floatingEmojis = list
    }

    func startGame(type: GameType) {
        selectedGameType = type
        score = 0
        streak = 0
        totalCorrect = 0
        totalAttempts = 0
        comboMultiplier = 1.0
        levelIndex = 0
        powerUps = 6
        lives = 3
        almondCoins = 0
        lastAction = nil
        canUndo = false
        startNextLevel()
    }

    func startNextLevel() {
        let levels = selectedGameType == .cards ? cardLevels : diceLevels
        guard levelIndex < levels.count else {
            showGameComplete = true
            saveHighScore()
            checkAchievements()
            return
        }

        currentLevel = levels[levelIndex]
        guard let level = currentLevel else { return }

        gameState = .playing
        gamePhase = .memorize
        selectedIndex = nil
        bounceCard = nil
        message = "Study the pattern..."
        timeRemaining = gameMode == .zen ? 999 : (gameMode == .challenge ? level.timeLimit / 2 : level.timeLimit)
        perfectLevel = true
        shieldActive = false
        shieldUsed = false
        revealUsed = false
        focusLensActive = false
        focusLensUsed = false
        doubleScoreActive = false
        doubleScoreUsed = false
        currentSwapStep = 0
        lastAction = nil
        canUndo = false
        isVortexing = false
        isXRayActive = false
        isTimeFrozen = false
        revealFlashActive = false
        eliminatedIndices.removeAll()
        oracleHintIndex = nil
        timeShardUsed = false

        if level.gameType == .cards {
            setupCards()
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            withAnimation(Animation.linear(duration: 0.08).repeatCount(5, autoreverses: true)) {
                shakeOffset = 10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.shakeOffset = 0
            }
            setupDice()
        }

        if gameMode != .zen {
            startTimer()
        }
    }

    private func setupCards() {
        guard let level = currentLevel else { return }
        cards = []
        var used = Set<String>()

        for i in 0..<level.itemCount {
            var suit = suits[i % 4]
            var rank = ranks[i % 13]
            var symbol = "\(rank)\(suit)"
            var attempts = 0

            while used.contains(symbol) && attempts < 50 {
                suit = suits.randomElement() ?? "♠️"
                rank = ranks.randomElement() ?? "A"
                symbol = "\(rank)\(suit)"
                attempts += 1
            }

            used.insert(symbol)
            let cardColor: Color = (suit == "♥️" || suit == "♦️") ? .red : .black
            cards.append(RiddleCard(rank: rank, suit: suit, color: cardColor))
        }

        targetCard = cards.randomElement()
        swapOffsets = Array(repeating: 0, count: cards.count)
    }

    private func setupDice() {
        guard let level = currentLevel else { return }
        dice = []
        let colors: [Color] = [.red, .blue, .green, .orange, .purple, .pink]

        for i in 0..<level.itemCount {
            let number = Int.random(in: 1...6)
            dice.append(RiddleDie(number: number, color: colors[i % colors.count], dots: dotsFor(number)))
        }

        targetNumber = dice.randomElement()?.number ?? 1
        swapOffsets = Array(repeating: 0, count: dice.count)
    }

    private func dotsFor(_ n: Int) -> [Bool] {
        switch n {
        case 1: return [false, false, false, false, true, false, false, false, false]
        case 2: return [true, false, false, false, false, false, false, false, true]
        case 3: return [true, false, false, false, true, false, false, false, true]
        case 4: return [true, false, true, false, false, false, true, false, true]
        case 5: return [true, false, true, false, true, false, true, false, true]
        case 6: return [true, false, true, true, false, true, true, false, true]
        default: return Array(repeating: false, count: 9)
        }
    }

    func startSwapping() {
        gamePhase = .swapping
        message = "Vortex Shuffle!"

        withAnimation(.easeInOut(duration: 0.5)) {
            isVortexing = true
        }

        withAnimation(.linear(duration: 1.5)) {
            vortexRotation += 1440
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            if self.currentLevel?.gameType == .cards {
                self.cards.shuffle()
            } else {
                self.dice.shuffle()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                self.isVortexing = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.gamePhase = .guessing
                    self.guessingStartTime = Date()
                    if self.currentLevel?.gameType == .cards, let target = self.targetCard {
                        self.message = "Find \(target.displaySymbol)"
                    } else if let target = self.targetNumber {
                        self.message = "Find number \(target)"
                    }
                }
            }
        }
    }

    func selectItem(at index: Int) {
        guard let level = currentLevel else { return }
        guard gamePhase == .guessing else { return }
        guard !eliminatedIndices.contains(index) else {
            message = "This one was removed by Almond Oracle."
            return
        }

        lastAction = LastAction(selectedIndex: selectedIndex, phase: gamePhase)
        canUndo = true
        selectedIndex = index
        bounceCard = index
        totalAttempts += 1

        let isCorrect: Bool
        if level.gameType == .cards {
            guard cards.indices.contains(index) else { return }
            isCorrect = targetCard?.displaySymbol == cards[index].displaySymbol
        } else {
            guard dice.indices.contains(index) else { return }
            isCorrect = targetNumber == dice[index].number
        }

        if isCorrect {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            streak += 1
            totalCorrect += 1
            comboMultiplier = min(1.0 + Double(streak) * 0.5, 5.0)
            let perfectBonus = perfectLevel ? 15 : 0
            let speedBonus = max(0, timeRemaining / 5)
            let rawBonus = Int(Double((10 + streak * 5 + perfectBonus + speedBonus) * level.id) * comboMultiplier)
            let bonus = doubleScoreActive ? rawBonus * 2 : rawBonus
            doubleScoreActive = false
            score += bonus
            almondCoins += max(1, level.id + streak)
            message = perfectLevel ? "✦ Perfect memory! +\(bonus)" : "✦ Correct! +\(bonus)"
            gamePhase = .result
            spawnConfetti()
            checkAchievements()
        } else {
            perfectLevel = false
            if shieldActive {
                shieldActive = false
                message = "🛡 Shield saved your combo!"
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.selectedIndex = nil
                    self.bounceCard = nil
                    self.message = "Try again — shield protected you."
                }
                return
            }
            lives = max(0, lives - 1)
            streak = 0
            comboMultiplier = 1.0
            score = max(0, score - 5)
            message = lives == 0 ? "No lives left!" : "✧ Not that one... Lives: \(lives)"

            if lives == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.gameState = .gameOver
                    self.saveHighScore()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.selectedIndex = nil
                        self.bounceCard = nil
                        self.message = "Try again!"
                    }
                }
            }
        }
    }

    func undo() {
        guard canUndo, let last = lastAction else { return }
        selectedIndex = last.selectedIndex
        bounceCard = nil
        canUndo = false
        lastAction = nil
        message = "↩ Undo!"
    }

    func useOracleHint() {
        guard powerUps > 0, gamePhase == .guessing, let level = currentLevel else { return }
        powerUps -= 1

        if level.gameType == .cards {
            oracleHintIndex = cards.firstIndex { $0.displaySymbol == targetCard?.displaySymbol }
        } else {
            oracleHintIndex = dice.firstIndex { $0.number == targetNumber }
        }

        if oracleHintIndex != nil {
            message = "✨ Hint active! The correct item is glowing."
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        } else {
            message = "Hint could not find the target."
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            self.oracleHintIndex = nil
        }
    }

    func eliminateWrongOption() {
        guard powerUps > 0, gamePhase == .guessing, let level = currentLevel else { return }
        powerUps -= 1

        let wrongIndices: [Int]
        if level.gameType == .cards {
            wrongIndices = cards.indices.filter { cards[$0].displaySymbol != targetCard?.displaySymbol && !eliminatedIndices.contains($0) }
        } else {
            wrongIndices = dice.indices.filter { dice[$0].number != targetNumber && !eliminatedIndices.contains($0) }
        }

        if let removeIndex = wrongIndices.randomElement() {
            eliminatedIndices.insert(removeIndex)
            message = "🌰 Almond Oracle removed one wrong choice."
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    func useTimeShard() {
        guard powerUps > 0, gamePhase == .guessing, gameMode != .zen, !timeShardUsed else { return }
        powerUps -= 1
        timeShardUsed = true
        timeRemaining += 10
        message = "⏳ Time Shard added +10 seconds."
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    func useRevealFlash() {
        guard powerUps > 0, gamePhase == .guessing, !revealUsed else { return }
        powerUps -= 1
        revealUsed = true
        revealFlashActive = true
        message = "👁 Reveal Flash shows all faces briefly."
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            self.revealFlashActive = false
        }
    }

    func useShield() {
        guard powerUps > 0, gamePhase == .guessing, !shieldUsed else { return }
        powerUps -= 1
        shieldUsed = true
        shieldActive = true
        message = "🛡 Shield armed. Your next mistake is protected."
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func useShuffleSense() {
        guard powerUps > 0, gamePhase == .guessing else { return }
        powerUps -= 1
        let count = currentLevel?.gameType == .cards ? cards.count : dice.count
        let correctIndex: Int?
        if currentLevel?.gameType == .cards {
            correctIndex = cards.firstIndex { $0.displaySymbol == targetCard?.displaySymbol }
        } else {
            correctIndex = dice.firstIndex { $0.number == targetNumber }
        }
        guard let correctIndex else { return }
        let near = [correctIndex - 1, correctIndex, correctIndex + 1].filter { $0 >= 0 && $0 < count }
        oracleHintIndex = near.randomElement() ?? correctIndex
        message = "🧭 Shuffle Sense points near the answer."
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.oracleHintIndex = nil
        }
    }

    func useFocusLens() {
        guard powerUps > 0, gamePhase == .guessing, !focusLensUsed else { return }
        powerUps -= 1
        focusLensUsed = true
        focusLensActive = true
        message = "🔎 Focus Lens dims the board and highlights useful zones."
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            self.focusLensActive = false
        }
    }

    func useDoubleScoreCharm() {
        guard powerUps > 0, gamePhase == .guessing, !doubleScoreUsed else { return }
        powerUps -= 1
        doubleScoreUsed = true
        doubleScoreActive = true
        message = "💫 Double Charm armed. Next correct score is doubled."
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func spawnConfetti() {
        var particles: [(Int, CGFloat, CGFloat, Color)] = []
        let colors: [Color] = [.yellow, .pink, .purple, .blue, .green, .orange, .red]

        for i in 0..<40 {
            let x = CGFloat.random(in: -150...150)
            let y = CGFloat.random(in: -300...0)
            let color = colors.randomElement() ?? .yellow
            particles.append((i, x, y, color))
        }

        confettiParticles = particles
        showConfetti = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showConfetti = false
        }
    }

    func checkAchievements() {
        if levelIndex == 1 && !achievements[0].isUnlocked { unlockAchievement(0) }
        if streak >= 5 && !achievements[1].isUnlocked { unlockAchievement(1) }
        if totalAttempts > 0 && totalCorrect == totalAttempts && !achievements[2].isUnlocked { unlockAchievement(2) }
        if score >= 500 && !achievements[4].isUnlocked { unlockAchievement(4) }
        if totalAttempts >= 20 && !achievements[5].isUnlocked { unlockAchievement(5) }
    }

    func unlockAchievement(_ index: Int) {
        guard achievements.indices.contains(index) else { return }
        achievements[index].isUnlocked = true
        latestAchievement = achievements[index]
        showAchievement = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showAchievement = false
        }
    }

    func advanceLevel() {
        levelIndex += 1
        startNextLevel()
    }

    func saveHighScore() {
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "cardelune_highscore")
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            if self.gameState == .playing {
                if self.isTimeFrozen { return }

                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    timer.invalidate()
                    self.gameState = .gameOver
                    self.saveHighScore()
                }
            } else {
                timer.invalidate()
            }
        }
    }
}

enum HelpTab: String, CaseIterable {
    case overview = "Overview"
    case powers = "Powers"
    case strategy = "Strategy"
    case scoring = "Scoring"

    var icon: String {
        switch self {
        case .overview: return "sparkles"
        case .powers: return "wand.and.stars"
        case .strategy: return "brain.head.profile"
        case .scoring: return "trophy.fill"
        }
    }
}

// MARK: - CONTENT VIEW

struct ContentView: View {
    @StateObject private var game = CardeluneGame()
    @State private var pulseAnim = false
    @State private var showModeSheet = false
    @State private var selectedHelpTab: HelpTab = .overview

    var body: some View {
        ZStack {
            LinearGradient(colors: AppColors.bgGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1), value: game.gameMode)

            GeometryReader { _ in
                ForEach(Array(game.floatingEmojis.enumerated()), id: \.offset) { _, item in
                    Text(item.emoji)
                        .font(.system(size: 24 * item.scale))
                        .opacity(item.opacity)
                        .position(x: item.x, y: item.y)
                }
            }
            .ignoresSafeArea()

            if game.gameState == .menu {
                menuView
            } else {
                gameView
            }

            if game.showConfetti {
                confettiView
            }

            if game.showAchievement, let achievement = game.latestAchievement {
                achievementBanner(achievement)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseAnim = true
            }
        }
        .alert("🎉 Journey Complete!", isPresented: $game.showGameComplete) {
            Button("New Journey") {
                game.gameState = .menu
            }
        } message: {
            let accuracy = game.totalAttempts > 0 ? Int(Double(game.totalCorrect) / Double(game.totalAttempts) * 100) : 0
            Text("Score: \(game.score)\nHigh Score: \(game.highScore)\nAccuracy: \(accuracy)%")
        }
    }

    // MARK: - MENU

    var menuView: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer().frame(height: 55)

                VStack(spacing: 10) {
                    Text("CARDELUNE")
                        .font(.system(size: 48, weight: .black, design: .serif))
                        .foregroundStyle(
                            LinearGradient(colors: [AppColors.cream, AppColors.accent, AppColors.almond], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .tracking(7)
                        .shadow(color: AppColors.accent.opacity(0.38), radius: 18, y: 8)

                    Text("MEMORY • CARDS • DICE")
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white.opacity(0.62))
                        .tracking(4)
                }
                .offset(y: pulseAnim ? -4 : 4)

                if game.highScore > 0 {
                    BeautifulCard(gradient: [AppColors.accent.opacity(0.25), AppColors.caramel.opacity(0.18)], cornerRadius: 22, padding: 12) {
                        HStack(spacing: 8) {
                            Text("🏆")
                            Text("Best Score: \(game.highScore)")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 18)
                }

                Spacer()

                VStack(spacing: 18) {
                    BigMenuPlayButton(
                        title: "PLAY CARDS",
                        subtitle: "Find the hidden moon card",
                        icon: "suit.spade.fill",
                        emoji: "🃏",
                        gradient: [AppColors.caramel, AppColors.bronze, AppColors.accent]
                    ) {
                        game.startGame(type: .cards)
                    }

                    BigMenuPlayButton(
                        title: "PLAY DICE",
                        subtitle: "Memorize numbers after shuffle",
                        icon: "dice.fill",
                        emoji: "🎲",
                        gradient: [AppColors.cream, AppColors.bronze, AppColors.almond]
                    ) {
                        game.startGame(type: .dice)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                HStack(spacing: 14) {
                    Button {
                        showModeSheet = true
                    } label: {
                        SmallGlassMenuButton(
                            title: game.gameMode.rawValue,
                            subtitle: "Mode",
                            systemIcon: game.gameMode.icon,
                            color: game.gameMode.color
                        )
                    }

                    Button {
                        game.showHowToPlay = true
                    } label: {
                        SmallGlassMenuButton(
                            title: "Guide",
                            subtitle: "How to Play",
                            systemIcon: "questionmark.circle.fill",
                            color: AppColors.accent
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 38)
            }
        }
        .sheet(isPresented: $showModeSheet) {
            modeSheet
        }
        .sheet(isPresented: $game.showHowToPlay) {
            howToPlayView
        }
    }

    var howToPlayView: some View {
        HelpCenterView(selectedTab: $selectedHelpTab) {
            game.showHowToPlay = false
        }
    }

    func instructionRow(icon: String, title: String, text: String) -> some View {
        BeautifulCard(gradient: [Color.white.opacity(0.8), Color.white.opacity(0.5)], cornerRadius: 20, padding: 15) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(AppColors.accent)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black.opacity(0.8))
                    Text(text)
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
        }
    }

    var modeSheet: some View {
        ZStack {
            LinearGradient(colors: [AppColors.cocoa, AppColors.bronze, AppColors.almond], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Capsule()
                    .fill(AppColors.cream.opacity(0.35))
                    .frame(width: 52, height: 5)
                    .padding(.top, 14)

                VStack(spacing: 8) {
                    Text("CHOOSE YOUR MOOD")
                        .font(.system(size: 20, weight: .black, design: .serif))
                        .foregroundStyle(LinearGradient(colors: [AppColors.cream, AppColors.accent], startPoint: .leading, endPoint: .trailing))
                        .tracking(2)

                    Text("Each mode changes pressure, pacing, and score feeling.")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.cream.opacity(0.72))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                VStack(spacing: 10) {
                    ForEach(GameModeType.allCases, id: \.rawValue) { mode in
                        ModeMoodCard(mode: mode, isSelected: game.gameMode == mode) {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                                game.gameMode = mode
                                showModeSheet = false
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                Button {
                    showModeSheet = false
                } label: {
                    Text("Close")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(AppColors.cocoa)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(AppColors.cream)
                        )
                        .padding(.horizontal, 28)
                }
                .padding(.bottom, 24)
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - GAME VIEW

    var gameView: some View {
        VStack(spacing: 4) {
            gameHeader
            targetDisplay
            gameBoard
            messageBubble
            actionButtons
            Spacer()
        }
    }

    var gameHeader: some View {
        VStack(spacing: 15) {
            HStack(spacing: 8) {
                Button {
                    withAnimation {
                        game.gameState = .menu
                    }
                } label: {
                    BeautifulCard(gradient: [Color.white.opacity(0.8), Color.white.opacity(0.5)], cornerRadius: 16, padding: 8) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black.opacity(0.5))
                    }
                }

                Spacer()

                BeautifulCard(gradient: [Color.white.opacity(0.86), AppColors.cream.opacity(0.66)], cornerRadius: 12, padding: 7) {
                    HStack(spacing: 4) {
                        Text("⭐").font(.system(size: 9))
                        Text("\(game.score)")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(.black.opacity(0.8))
                    }
                }

                BeautifulCard(gradient: [AppColors.accent.opacity(0.85), AppColors.almond.opacity(0.65)], cornerRadius: 12, padding: 7) {
                    HStack(spacing: 4) {
                        Text("🌰").font(.system(size: 9))
                        Text("\(game.almondCoins)")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(AppColors.cocoa)
                    }
                }

                BeautifulCard(gradient: [Color.white.opacity(0.86), AppColors.cream.opacity(0.66)], cornerRadius: 12, padding: 7) {
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < game.lives ? "heart.fill" : "heart")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(i < game.lives ? .red : .black.opacity(0.25))
                        }
                    }
                }

                if game.gameMode != .zen {
                    let urgent = game.timeRemaining <= 10
                    BeautifulCard(
                        gradient: [urgent ? Color.red.opacity(0.2) : Color.white.opacity(0.8), urgent ? Color.red.opacity(0.1) : Color.white.opacity(0.5)],
                        cornerRadius: 12,
                        padding: 7
                    ) {
                        HStack(spacing: 4) {
                            Text("⏱").font(.system(size: 9))
                            Text("\(game.timeRemaining)s")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundColor(urgent ? .red : .black.opacity(0.8))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 55)

            VStack(spacing: 4) {
                HStack {
                    Text("COMBO")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(.white.opacity(0.45))
                    Spacer()
                    Text("\(String(format: "%.1f", game.comboMultiplier))x")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(game.streak >= 5 ? .orange : AppColors.accent)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 8)

                        let progress = min(CGFloat(game.streak) / 5.0, 1.0)
                        Capsule()
                            .fill(game.streak >= 5 ? LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [AppColors.accent.opacity(0.5), AppColors.accent], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * progress, height: 8)
                            .shadow(color: game.streak >= 5 ? .orange.opacity(0.6) : .clear, radius: 5)
                            .animation(.spring(), value: progress)
                    }
                }
                .frame(height: 8)

                if game.streak >= 5 {
                    Text("🔥 ON FIRE!")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.orange)
                        .animation(.bouncy, value: game.streak)
                }
            }
            .padding(.horizontal, 30)
        }
    }

    @ViewBuilder
    var targetDisplay: some View {
        if game.gamePhase == .memorize || game.gamePhase == .guessing {
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .shadow(color: AppColors.accent.opacity(0.3), radius: 15)

                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 80, height: 80)

                if game.selectedGameType == .cards, let target = game.targetCard {
                    VStack(spacing: -2) {
                        Text(target.suit)
                            .font(.system(size: 32))
                            .foregroundColor(target.color)
                            .shadow(color: target.color.opacity(0.5), radius: 5)
                        Text(target.rank)
                            .font(.system(size: 18, weight: .heavy, design: .serif))
                            .foregroundColor(target.color)
                    }
                } else if let target = game.targetNumber {
                    Text("\(target)")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.green)
                        .shadow(color: .green.opacity(0.5), radius: 5)
                }
            }
            .padding(.top, 10)
        }
    }

    @ViewBuilder
    var gameBoard: some View {
        if let level = game.currentLevel {
            GeometryReader { geo in
                ZStack {
                    if level.gameType == .cards {
                        ForEach(Array(game.cards.enumerated()), id: \.offset) { index, _ in
                            let pos = level.shape.position(for: index, total: level.itemCount, in: geo.size)

                            GameCardView(
                                card: game.cards[index],
                                isRevealed: game.gamePhase == .memorize || game.revealFlashActive || game.oracleHintIndex == index || (game.gamePhase == .result && game.selectedIndex == index) || (game.gamePhase == .guessing && game.selectedIndex == index),
                                isSwapping: game.gamePhase == .swapping,
                                offset: game.swapOffsets.indices.contains(index) ? game.swapOffsets[index] : 0,
                                isSelected: game.selectedIndex == index,
                                isBouncing: game.bounceCard == index || game.oracleHintIndex == index,
                                accent: AppColors.accent,
                                isXRay: game.isXRayActive || game.oracleHintIndex == index,
                                isHinted: game.oracleHintIndex == index
                            )
                            .position(game.isVortexing ? CGPoint(x: geo.size.width / 2, y: geo.size.height / 2) : CGPoint(x: pos.x + 25, y: pos.y + 25))
                            .rotationEffect(.degrees(game.isVortexing ? game.vortexRotation + Double(index * 45) : 0))
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                                    if game.gamePhase == .guessing,
                                       game.targetCard?.displaySymbol == game.cards[index].displaySymbol {
                                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                    }
                                }
                            )
                            .opacity(game.eliminatedIndices.contains(index) ? 0.18 : (game.focusLensActive && game.oracleHintIndex != index ? 0.42 : 1))
                            .scaleEffect(game.eliminatedIndices.contains(index) ? 0.78 : (game.focusLensActive && game.oracleHintIndex == index ? 1.16 : 1))
                            .onTapGesture {
                                if game.gamePhase == .guessing {
                                    game.selectItem(at: index)
                                }
                            }
                        }
                    } else {
                        ForEach(Array(game.dice.enumerated()), id: \.offset) { index, _ in
                            let pos = level.shape.position(for: index, total: level.itemCount, in: geo.size)

                            GameDieView(
                                die: game.dice[index],
                                isRevealed: game.gamePhase == .memorize || game.revealFlashActive || game.oracleHintIndex == index || (game.gamePhase == .result && game.selectedIndex == index) || (game.gamePhase == .guessing && game.selectedIndex == index),
                                isSwapping: game.gamePhase == .swapping,
                                offset: game.swapOffsets.indices.contains(index) ? game.swapOffsets[index] : 0,
                                isSelected: game.selectedIndex == index,
                                isBouncing: game.bounceCard == index,
                                accent: AppColors.accent,
                                isXRay: game.isXRayActive
                            )
                            .position(game.isVortexing ? CGPoint(x: geo.size.width / 2, y: geo.size.height / 2) : CGPoint(x: pos.x + 25, y: pos.y + 25))
                            .rotationEffect(.degrees(game.isVortexing ? game.vortexRotation + Double(index * 45) : 0))
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                                    if game.gamePhase == .guessing,
                                       game.targetNumber == game.dice[index].number {
                                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                    }
                                }
                            )
                            .opacity(game.eliminatedIndices.contains(index) ? 0.18 : (game.focusLensActive && game.oracleHintIndex != index ? 0.42 : 1))
                            .scaleEffect(game.eliminatedIndices.contains(index) ? 0.78 : (game.focusLensActive && game.oracleHintIndex == index ? 1.16 : 1))
                            .onTapGesture {
                                if game.gamePhase == .guessing {
                                    game.selectItem(at: index)
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: 370)
            .padding(.horizontal, 4)
            .offset(x: game.shakeOffset)
        }
    }

    var messageBubble: some View {
        BeautifulCard(gradient: [AppColors.accent.opacity(0.15), AppColors.accent.opacity(0.08)], cornerRadius: 12, padding: 8) {
            Text(game.message)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(.horizontal, 40)
    }

    @ViewBuilder
    var actionButtons: some View {
        HStack(spacing: 10) {
            if game.canUndo && game.gamePhase == .guessing {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        game.undo()
                    }
                } label: {
                    BeautifulCard(gradient: [Color.white.opacity(0.5), Color.white.opacity(0.3)], cornerRadius: 20, padding: 10) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 12))
                            .foregroundColor(.black.opacity(0.5))
                    }
                }
            }

            if game.gamePhase == .guessing && game.powerUps > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 9) {
                        PowerButton(title: "Hint", icon: "✨", color1: AppColors.accent, color2: AppColors.caramel) { game.useOracleHint() }
                        PowerButton(title: "Remove", icon: "🌰", color1: AppColors.bronze, color2: AppColors.cocoa) { game.eliminateWrongOption() }
                        if game.gameMode != .zen && !game.timeShardUsed {
                            PowerButton(title: "+10s", icon: "⏳", color1: AppColors.cream, color2: AppColors.almond, darkText: true) { game.useTimeShard() }
                        }
                        if !game.revealUsed {
                            PowerButton(title: "Flash", icon: "👁", color1: Color.white, color2: AppColors.cream, darkText: true) { game.useRevealFlash() }
                        }
                        if !game.shieldUsed {
                            PowerButton(title: "Shield", icon: "🛡", color1: AppColors.almond, color2: AppColors.bronze) { game.useShield() }
                        }
                        PowerButton(title: "Sense", icon: "🧭", color1: AppColors.caramel, color2: AppColors.accent) { game.useShuffleSense() }
                        if !game.focusLensUsed {
                            PowerButton(title: "Lens", icon: "🔎", color1: AppColors.cream, color2: AppColors.caramel, darkText: true) { game.useFocusLens() }
                        }
                        if !game.doubleScoreUsed {
                            PowerButton(title: "2x", icon: "💫", color1: AppColors.accent, color2: AppColors.bronze) { game.useDoubleScoreCharm() }
                        }
                    }
                    .padding(.horizontal, 35)
                }
            }

            if game.gamePhase == .memorize {
                Button {
                    game.startSwapping()
                } label: {
                    BeautifulCard(gradient: [AppColors.accent, AppColors.accent.opacity(0.85)], cornerRadius: 22, padding: 14) {
                        HStack(spacing: 6) {
                            Text("🔀").font(.system(size: 12))
                            Text("SHUFFLE & GUESS")
                                .font(.system(size: 13, weight: .semibold, design: .serif))
                                .tracking(2)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    }
                }
            } else if game.gamePhase == .result {
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        game.advanceLevel()
                    }
                } label: {
                    BeautifulCard(gradient: [AppColors.accent, AppColors.accent.opacity(0.85)], cornerRadius: 22, padding: 14) {
                        HStack(spacing: 6) {
                            Text("CONTINUE")
                                .font(.system(size: 13, weight: .semibold, design: .serif))
                                .tracking(2)
                            Text("→").font(.system(size: 14))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, 35)
    }

    // MARK: - CONFETTI

    var confettiView: some View {
        GeometryReader { geo in
            ForEach(game.confettiParticles, id: \.id) { particle in
                Text(["✨", "💫", "🌟", "⚡️", "💎", "☄️", "🔥"].randomElement() ?? "✨")
                    .font(.system(size: CGFloat.random(in: 10...20)))
                    .foregroundColor(particle.color)
                    .position(x: geo.size.width / 2 + particle.x, y: geo.size.height / 2 + particle.y)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // MARK: - ACHIEVEMENT BANNER

    func achievementBanner(_ achievement: Achievement) -> some View {
        VStack {
            Spacer()
            BeautifulCard(gradient: [Color.yellow.opacity(0.2), Color.orange.opacity(0.15)], cornerRadius: 18, padding: 15) {
                HStack(spacing: 12) {
                    Text(achievement.icon)
                        .font(.system(size: 32))

                    VStack(alignment: .leading) {
                        Text("Achievement!")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.orange)
                        Text(achievement.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                        Text(achievement.description)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.65))
                    }

                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: game.showAchievement)
    }
}

// MARK: - REUSABLE COMPONENTS

struct BeautifulCard<Content: View>: View {
    let gradient: [Color]
    let cornerRadius: CGFloat
    let padding: CGFloat
    @ViewBuilder let content: () -> Content
    @State private var isAnimating = false

    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: isAnimating ? .topLeading : .bottomTrailing,
                            endPoint: isAnimating ? .bottomTrailing : .topLeading
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.06), radius: 10, y: 3)
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

struct PrettyButton: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            BeautifulCard(gradient: [color.opacity(0.15), color.opacity(0.08)], cornerRadius: 16, padding: 12) {
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.black.opacity(0.4))
                        .tracking(2)
                    HStack(spacing: 5) {
                        Image(systemName: icon)
                            .font(.system(size: 11))
                            .foregroundColor(color)
                        Text(value)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct GameTypeCard: View {
    let type: GameType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                action()
            }
        } label: {
            BeautifulCard(
                gradient: isSelected ? [AppColors.accent.opacity(0.3), AppColors.accent.opacity(0.2)] : [Color.white.opacity(0.4), Color.white.opacity(0.25)],
                cornerRadius: 22,
                padding: 20
            ) {
                VStack(spacing: 10) {
                    Text(type.icon)
                        .font(.system(size: 42))
                        .scaleEffect(isSelected ? 1.15 : 0.95)
                    Text(type == .cards ? "CARDS" : "DICE")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.black.opacity(0.7))
                        .tracking(2)
                    Text(type.title)
                        .font(.system(size: 10, weight: .light, design: .serif))
                        .foregroundColor(.black.opacity(0.5))
                }
                .frame(width: 110)
            }
        }
        .buttonStyle(.plain)
    }
}

struct BigMenuPlayButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let emoji: String
    let gradient: [Color]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 34)
                    .fill(
                        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: gradient.first?.opacity(0.45) ?? .black.opacity(0.3), radius: 20, y: 10)

                RoundedRectangle(cornerRadius: 34)
                    .stroke(Color.white.opacity(0.45), lineWidth: 1.5)

                HStack(spacing: 18) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.24))
                            .frame(width: 76, height: 76)
                        Text(emoji)
                            .font(.system(size: 42))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(1.5)

                        Text(subtitle)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.78))
                    }

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white.opacity(0.88))
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 118)
        }
        .buttonStyle(.plain)
    }
}

struct SmallGlassMenuButton: View {
    let title: String
    let subtitle: String
    let systemIcon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemIcon)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(color)
                .frame(width: 24, height: 24)
                .background(Circle().fill(color.opacity(0.16)))

            VStack(alignment: .leading, spacing: 2) {
                Text(subtitle)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.55))
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.13))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        )
    }
}

struct PowerButton: View {
    let title: String
    let icon: String
    let color1: Color
    let color2: Color
    var darkText: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(icon)
                Text(title)
                    .font(.system(size: 11, weight: .black, design: .rounded))
            }
            .foregroundColor(darkText ? AppColors.cocoa : .white)
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(LinearGradient(colors: [color1, color2], startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))
            .shadow(color: color1.opacity(0.25), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct ModeMoodCard: View {
    let mode: GameModeType
    let isSelected: Bool
    let action: () -> Void
    @State private var shimmer = false
    @State private var float = false

    var modeGradient: [Color] {
        switch mode {
        case .timed: return [AppColors.accent, AppColors.caramel]
        case .relaxed: return [AppColors.cream, AppColors.almond]
        case .challenge: return [AppColors.bronze, AppColors.cocoa]
        case .zen: return [AppColors.almond, AppColors.caramel]
        }
    }

    var moodPower: Int {
        switch mode {
        case .timed: return 2
        case .relaxed: return 1
        case .challenge: return 3
        case .zen: return 0
        }
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: isSelected ? modeGradient : [Color.white.opacity(0.13), Color.white.opacity(0.07)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(shimmer ? 0.22 : 0.04), Color.clear, Color.white.opacity(shimmer ? 0.06 : 0.18)],
                            startPoint: shimmer ? .topLeading : .bottomTrailing,
                            endPoint: shimmer ? .bottomTrailing : .topLeading
                        )
                    )
                    .blendMode(.screen)

                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(isSelected ? 0.26 : 0.13))
                            .frame(width: 66, height: 66)
                            .shadow(color: isSelected ? AppColors.accent.opacity(0.28) : .clear, radius: 12)

                        Circle()
                            .stroke(Color.white.opacity(0.38), lineWidth: 1)
                            .frame(width: 54, height: 54)

                        Image(systemName: mode.icon)
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(isSelected ? .white : mode.color)
                            .offset(y: float ? -2 : 2)
                    }

                    VStack(alignment: .leading, spacing: 7) {
                        HStack(spacing: 4) {
                            Text(mode.rawValue.uppercased())
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundColor(isSelected ? .white : AppColors.cream)

                            if isSelected {
                                Text("ACTIVE")
                                    .font(.system(size: 6, weight: .black, design: .monospaced))
                                    .foregroundColor(AppColors.cocoa)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(AppColors.cream))
                            }
                        }

                        Text(mode.description)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(isSelected ? .white.opacity(0.82) : AppColors.cream.opacity(0.66))

                        HStack(spacing: 4) {
                            ForEach(0..<4, id: \.self) { i in
                                Capsule()
                                    .fill((isSelected ? Color.white : AppColors.accent).opacity(i <= moodPower ? 0.95 : 0.22))
                                    .frame(width: 22, height: 5)
                            }
                        }
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(isSelected ? 0.24 : 0.08))
                            .frame(width: 30, height: 30)
                        Image(systemName: isSelected ? "checkmark" : "chevron.right")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(isSelected ? .white : AppColors.cream.opacity(0.7))
                    }
                }
                .padding(14)
            }
            .frame(height: 104)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(isSelected ? Color.white.opacity(0.55) : AppColors.cream.opacity(0.18), lineWidth: isSelected ? 1.8 : 1)
            )
            .shadow(color: isSelected ? (modeGradient.first ?? AppColors.accent).opacity(0.38) : .black.opacity(0.10), radius: isSelected ? 22 : 10, y: isSelected ? 12 : 6)
            .scaleEffect(isSelected ? 1.025 : 1)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: true)) {
                shimmer = true
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                float = true
            }
        }
    }
}

struct HelpCenterView: View {
    @Binding var selectedTab: HelpTab
    let close: () -> Void
    @State private var animateCards = false
    @State private var glow = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [AppColors.cocoa, AppColors.bronze, AppColors.almond], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("HELP CENTER")
                            .font(.system(size: 28, weight: .black, design: .serif))
                            .foregroundStyle(LinearGradient(colors: [AppColors.cream, AppColors.accent], startPoint: .leading, endPoint: .trailing))
                            .tracking(2)
                            .shadow(color: AppColors.accent.opacity(glow ? 0.45 : 0.15), radius: glow ? 16 : 6)

                        Text("Master Cardelune like a premium puzzle game.")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.cream.opacity(0.65))
                    }

                    Spacer()

                    Button(action: close) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(AppColors.cream.opacity(0.88))
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 22)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(HelpTab.allCases, id: \.rawValue) { tab in
                            Button {
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                                    selectedTab = tab
                                }
                            } label: {
                                HStack(spacing: 7) {
                                    Image(systemName: tab.icon)
                                    Text(tab.rawValue)
                                }
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundColor(selectedTab == tab ? AppColors.cocoa : AppColors.cream.opacity(0.72))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(selectedTab == tab ? AppColors.cream : Color.white.opacity(0.12))
                                        .shadow(color: selectedTab == tab ? AppColors.accent.opacity(0.30) : .clear, radius: 12, y: 6)
                                )
                                .scaleEffect(selectedTab == tab ? 1.06 : 1)
                                .overlay(
                                    Capsule()
                                        .stroke(AppColors.cream.opacity(0.18), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case .overview:
                            helpCard(icon: "moon.stars.fill", title: "Core Loop", text: "Memorize the card or dice positions, survive the vortex shuffle, then find the target using memory and power-ups.")
                            helpCard(icon: "square.grid.3x3.fill", title: "Unique Boards", text: "Levels use constellation, vortex, lotus, ripple, helix, compass, and other shaped layouts.")
                            helpCard(icon: "sparkles", title: "Premium Feel", text: "Animated shuffles, haptics, combos, achievements, lives, coins, and almond-themed visuals make it feel professional.")

                        case .powers:
                            helpCard(icon: "wand.and.stars", title: "Oracle Hint", text: "Briefly glows near the correct answer.")
                            helpCard(icon: "scissors", title: "Remove Wrong", text: "Removes one wrong card or die from the board.")
                            helpCard(icon: "hourglass", title: "Time Shard", text: "Adds 10 seconds in timed modes.")
                            helpCard(icon: "shield.fill", title: "Shield", text: "Protects your next wrong tap and saves your combo once.")
                            helpCard(icon: "eye.fill", title: "Reveal Flash", text: "Shows every card or die face for a very short moment.")
                            helpCard(icon: "viewfinder", title: "Focus Lens", text: "Dims the board and emphasizes the most useful zone.")
                            helpCard(icon: "sparkle.magnifyingglass", title: "Double Charm", text: "Doubles your next correct answer score.")

                        case .strategy:
                            helpCard(icon: "brain.head.profile", title: "Memorize Clusters", text: "Remember top, bottom, left, right, and center instead of memorizing every item one by one.")
                            helpCard(icon: "bolt.fill", title: "Save Powers", text: "Try memory first, then use powers only on risky targets.")
                            helpCard(icon: "location.north.line.fill", title: "Track Motion", text: "Watch the target region during the vortex shuffle for better recall.")

                        case .scoring:
                            helpCard(icon: "flame.fill", title: "Combo Multiplier", text: "Correct answers build streaks and increase score.")
                            helpCard(icon: "heart.fill", title: "Lives", text: "Wrong taps cost lives unless shield is active.")
                            helpCard(icon: "trophy.fill", title: "Achievements", text: "Complete levels, score higher, keep streaks, and play longer to unlock achievements.")
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 4)
                    .padding(.bottom, 35)
                    .offset(y: animateCards ? 0 : 20)
                    .opacity(animateCards ? 1 : 0)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.65, dampingFraction: 0.8)) {
                animateCards = true
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
        .onChange(of: selectedTab) { _ in
            animateCards = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                    animateCards = true
                }
            }
        }
    }

    func helpCard(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppColors.cream.opacity(0.18))
                    .frame(width: 54, height: 54)

                Image(systemName: icon)
                    .font(.system(size: 23, weight: .black))
                    .foregroundColor(AppColors.accent)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(title)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundColor(AppColors.cream)

                Text(text)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.cream.opacity(0.68))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.11))
                RoundedRectangle(cornerRadius: 28)
                    .fill(LinearGradient(colors: [AppColors.cream.opacity(0.08), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(AppColors.cream.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.10), radius: 14, y: 8)
    }
}

// MARK: - GAME CARD VIEW

struct GameCardView: View {
    let card: RiddleCard
    let isRevealed: Bool
    let isSwapping: Bool
    let offset: CGFloat
    let isSelected: Bool
    let isBouncing: Bool
    let accent: Color
    var isXRay: Bool = false
    var isHinted: Bool = false

    @State private var isFloating = false
    @State private var hintPulse = false

    var flipped: Bool {
        isRevealed || isSwapping || isXRay || isHinted
    }

    var body: some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
                    .shadow(color: isHinted ? AppColors.accent.opacity(0.95) : (isSelected ? accent.opacity(0.8) : .clear), radius: isHinted ? 24 : 12)
                    .shadow(color: isBouncing ? accent.opacity(0.5) : .clear, radius: 18)

                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.6), Color.clear, Color.white.opacity(0.3)],
                            startPoint: isFloating ? .topLeading : .bottomTrailing,
                            endPoint: isFloating ? .bottomTrailing : .topLeading
                        )
                    )
                    .frame(width: 64, height: 64)
                    .blendMode(.overlay)

                RoundedRectangle(cornerRadius: 12)
                    .stroke(isHinted ? AppColors.accent : (isSelected ? accent : AppColors.cardStroke.opacity(0.55)), lineWidth: isHinted ? 5 : (isSelected ? 3 : 2))
                    .frame(width: 64, height: 64)

                if isHinted {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(colors: [.yellow, .orange, .white, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 4
                        )
                        .frame(width: 78, height: 78)
                        .scaleEffect(hintPulse ? 1.18 : 0.92)
                        .opacity(hintPulse ? 0.15 : 0.95)
                }

                VStack(spacing: 0) {
                    Text(card.suit).font(.system(size: 26))
                    Text(card.rank).font(.system(size: 16, weight: .heavy, design: .serif))
                }
                .foregroundColor(card.color)
            }
            .opacity(flipped ? 1 : 0)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.cardBack)
                    .frame(width: 64, height: 64)
                    .shadow(color: AppColors.softShadow, radius: 5, y: 3)

                RealCardBackPattern()
                    .frame(width: 54, height: 54)

                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.78), lineWidth: 2)
                    .frame(width: 64, height: 64)
            }
            .opacity(flipped ? 0 : 1)
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .scaleEffect(isHinted ? (hintPulse ? 1.28 : 1.14) : (isBouncing ? 1.3 : (isSelected ? 1.15 : 1.0)))
        .offset(x: offset, y: isFloating ? -4 : 4)
        .rotation3DEffect(.degrees(flipped ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: offset)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: flipped)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isSelected)
        .animation(.spring(response: 0.3, dampingFraction: 0.4), value: isBouncing)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isFloating = true
            }
            withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                hintPulse = true
            }
        }
    }
}

// MARK: - GAME DIE VIEW

struct GameDieView: View {
    let die: RiddleDie
    let isRevealed: Bool
    let isSwapping: Bool
    let offset: CGFloat
    let isSelected: Bool
    let isBouncing: Bool
    let accent: Color
    var isXRay: Bool = false
    var isHinted: Bool = false

    @State private var isFloating = false
    @State private var hintPulse = false

    var flipped: Bool {
        isRevealed || isSwapping || isXRay || isHinted
    }

    var body: some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
                    .shadow(color: isHinted ? AppColors.accent.opacity(0.95) : (isSelected ? accent.opacity(0.8) : .black.opacity(0.18)), radius: isHinted ? 24 : 10, y: 3)

                RoundedRectangle(cornerRadius: 12)
                    .stroke(isHinted ? AppColors.accent : (isSelected ? accent : Color.white.opacity(0.85)), lineWidth: isHinted ? 5 : (isSelected ? 3 : 2))
                    .frame(width: 64, height: 64)

                DieFace(number: die.number, color: die.color)
                    .frame(width: 50, height: 50)

                if isHinted {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(colors: [.yellow, .orange, .white, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 4
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(hintPulse ? 1.18 : 0.92)
                        .opacity(hintPulse ? 0.15 : 0.95)
                }
            }
            .opacity(flipped ? 1 : 0)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
                    .shadow(color: AppColors.softShadow, radius: 5, y: 3)

                RealDiceBackPattern()
                    .frame(width: 54, height: 54)

                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.78), lineWidth: 2)
                    .frame(width: 64, height: 64)
            }
            .opacity(flipped ? 0 : 1)
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .scaleEffect(isHinted ? (hintPulse ? 1.28 : 1.14) : (isBouncing ? 1.3 : (isSelected ? 1.15 : 1.0)))
        .offset(x: offset, y: isFloating ? -4 : 4)
        .rotation3DEffect(.degrees(flipped ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: offset)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: flipped)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isSelected)
        .animation(.spring(response: 0.3, dampingFraction: 0.4), value: isBouncing)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isFloating = true
            }
            withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                hintPulse = true
            }
        }
    }
}

struct RealCardBackPattern: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.85), lineWidth: 1.4)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))

            VStack(spacing: 5) {
                ForEach(0..<5, id: \.self) { row in
                    HStack(spacing: 5) {
                        ForEach(0..<5, id: \.self) { col in
                            Circle()
                                .fill(Color.black.opacity((row + col) % 2 == 0 ? 0.82 : 0.38))
                                .frame(width: 4.6, height: 4.6)
                        }
                    }
                }
            }

            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.black.opacity(0.25), lineWidth: 1)
                .padding(7)
        }
    }
}

struct RealDiceBackPattern: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.10), radius: 2, y: 1)

            VStack(spacing: 7) {
                HStack(spacing: 7) {
                    Circle().fill(Color.black).frame(width: 7, height: 7)
                    Circle().fill(Color.black).frame(width: 7, height: 7)
                }
                HStack(spacing: 7) {
                    Circle().fill(Color.black).frame(width: 7, height: 7)
                    Circle().fill(Color.black).frame(width: 7, height: 7)
                }
            }
        }
    }
}

// MARK: - DIE FACE

struct DieFace: View {
    let number: Int
    let color: Color
    let positions: [(Int, Int)] = [
        (0, 0), (0, 1), (0, 2),
        (1, 0), (1, 1), (1, 2),
        (2, 0), (2, 1), (2, 2)
    ]

    func showDot(_ index: Int) -> Bool {
        switch number {
        case 1: return index == 4
        case 2: return index == 0 || index == 8
        case 3: return index == 0 || index == 4 || index == 8
        case 4: return index == 0 || index == 2 || index == 6 || index == 8
        case 5: return index == 0 || index == 2 || index == 4 || index == 6 || index == 8
        case 6: return index == 0 || index == 2 || index == 3 || index == 5 || index == 6 || index == 8
        default: return false
        }
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height) / 4

            ZStack {
                ForEach(0..<9, id: \.self) { index in
                    if showDot(index) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: size * 1.5))
                            .foregroundColor(color)
                            .shadow(color: color.opacity(0.8), radius: 3)
                            .position(
                                x: CGFloat(positions[index].1) * geo.size.width / 3 + geo.size.width / 6,
                                y: CGFloat(positions[index].0) * geo.size.height / 3 + geo.size.height / 6
                            )
                    }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}

