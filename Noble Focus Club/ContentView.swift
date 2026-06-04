import SwiftUI

struct ContentView: View {
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false

    var body: some View {
        ZStack {
            LuxeBackdrop()
                .ignoresSafeArea()

            if didCompleteOnboarding {
                ClubReleaseShell()
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                OnboardingDeck {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        didCompleteOnboarding = true
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Theme

enum Luxe {
    static let bgTop = Color(red: 0.09, green: 0.08, blue: 0.11)
    static let bgBottom = Color(red: 0.02, green: 0.02, blue: 0.03)

    static let card = Color(red: 0.16, green: 0.13, blue: 0.16)
    static let cardDeep = Color(red: 0.11, green: 0.09, blue: 0.12)
    static let cardSoft = Color(red: 0.23, green: 0.18, blue: 0.22)

    static let accent = Color(red: 0.97, green: 0.76, blue: 0.33)
    static let accentSoft = Color(red: 0.78, green: 0.53, blue: 0.20)

    static let textMain = Color.white
    static let textMuted = Color(red: 0.82, green: 0.79, blue: 0.74)
    static let success = Color(red: 0.38, green: 0.91, blue: 0.58)
    static let danger = Color(red: 0.96, green: 0.40, blue: 0.36)
}

struct LuxeBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Luxe.bgTop, Luxe.bgBottom], startPoint: .topLeading, endPoint: .bottomTrailing)

            Circle()
                .fill(Luxe.accent.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 44)
                .offset(x: 150, y: -290)

            Circle()
                .fill(Color.red.opacity(0.09))
                .frame(width: 320, height: 320)
                .blur(radius: 48)
                .offset(x: -170, y: 340)

            RoundedRectangle(cornerRadius: 0)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.025), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }
}

struct LuxeCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Luxe.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func luxeCard() -> some View {
        modifier(LuxeCardModifier())
    }
}

// MARK: - Onboarding

struct OnboardingSlide {
    let title: String
    let subtitle: String
    let detail: String
    let bullets: [String]
}

struct OnboardingDeck: View {
    @State private var step = 0
    let onFinish: () -> Void

    private let slides: [OnboardingSlide] = [
        .init(
            title: "Welcome to Noble Focus Club",
            subtitle: "Enter a private focus arcade.",
            detail: "Play skill games, earn Focus Points, and unlock rare noble rewards.",
            bullets: ["Skill-based challenges", "No cash mechanics", "Private club progression"]
        ),
        .init(
            title: "Train Your Focus",
            subtitle: "Complete short precision challenges.",
            detail: "Every game tests timing, reflexes, control, or attention. Better performance gives better rewards.",
            bullets: ["Fast sessions", "Score-based rewards", "Daily focus goals"]
        ),
        .init(
            title: "Collect Noble Relics",
            subtitle: "Unlock rare club items through progress.",
            detail: "Relics are earned by completing games, building streaks, and reaching score milestones.",
            bullets: ["Golden Crest", "Silver Seal", "Crystal Pin", "Velvet Crown"]
        ),
        .init(
            title: "Your First Session Awaits",
            subtitle: "Complete your first focus session.",
            detail: "Start with 2 skill games and claim your first club reward.",
            bullets: []
        )
    ]

    var body: some View {
        let slide = slides[step]

        VStack(spacing: 18) {
            HStack {
                Text("Noble Focus Club")
                    .font(.system(size: 25, weight: .black, design: .serif))
                Spacer()
                Text("\(step + 1)/4")
                    .font(.headline)
                    .foregroundStyle(Luxe.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Luxe.cardSoft))
            }

            VStack(alignment: .leading, spacing: 14) {
                Text(slide.title)
                    .font(.system(size: 30, weight: .heavy, design: .serif))
                Text(slide.subtitle)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Luxe.accent)
                Text(slide.detail)
                    .foregroundStyle(Luxe.textMuted)

                if step == 2 {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(slide.bullets, id: \.self) { item in
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(Luxe.accent)
                                Text(item)
                                    .font(.subheadline.weight(.semibold))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Luxe.cardSoft))
                        }
                    }
                } else if step == 3 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Starter Focus Session")
                            .font(.headline)
                        Text("Goal: 0/2 games")
                            .foregroundStyle(Luxe.textMuted)
                        Text("Reward: +900 Focus Points")
                            .fontWeight(.semibold)
                            .foregroundStyle(Luxe.accent)
                    }
                    .luxeCard()
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(slide.bullets, id: \.self) { item in
                            Label(item, systemImage: "diamond.fill")
                                .foregroundStyle(Luxe.textMain)
                                .tint(Luxe.accent)
                        }
                    }
                }
            }
            .luxeCard()

            Button {
                if step < slides.count - 1 {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        step += 1
                    }
                } else {
                    onFinish()
                }
            } label: {
                Text(step == slides.count - 1 ? "Enter Club" : "Next")
                    .headlineCTA()
            }
            .buttonStyle(.plain)

            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { idx in
                    Capsule()
                        .fill(idx == step ? Luxe.accent : Color.white.opacity(0.2))
                        .frame(width: idx == step ? 34 : 10, height: 8)
                        .animation(.spring(response: 0.24, dampingFraction: 0.8), value: step)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(20)
    }
}

// MARK: - Release Shell

enum ClubTab: CaseIterable {
    case lounge
    case arena
    case vault
    case missions
    case member

    var title: String {
        switch self {
        case .lounge: return "Lounge"
        case .arena: return "Arena"
        case .vault: return "Vault"
        case .missions: return "Missions"
        case .member: return "Member"
        }
    }

    var icon: String {
        switch self {
        case .lounge: return "house.fill"
        case .arena: return "scope"
        case .vault: return "sparkle.magnifyingglass"
        case .missions: return "checklist"
        case .member: return "person.crop.circle.fill"
        }
    }
}

struct ClubReleaseShell: View {
    @State private var selected: ClubTab = .lounge
    @Namespace private var tabAnimation

    var body: some View {
        ZStack {
            NavigationStack { ClubHomeReleaseView() }
                .opacity(selected == .lounge ? 1 : 0)
                .allowsHitTesting(selected == .lounge)

            NavigationStack { ArenaGamesReleaseView() }
                .opacity(selected == .arena ? 1 : 0)
                .allowsHitTesting(selected == .arena)

            NavigationStack { VaultReleaseView() }
                .opacity(selected == .vault ? 1 : 0)
                .allowsHitTesting(selected == .vault)

            NavigationStack { MissionsReleaseView() }
                .opacity(selected == .missions ? 1 : 0)
                .allowsHitTesting(selected == .missions)

            NavigationStack { MemberReleaseView() }
                .opacity(selected == .member ? 1 : 0)
                .allowsHitTesting(selected == .member)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomTabs
        }
    }

    private var bottomTabs: some View {
        HStack(spacing: 6) {
            ForEach(ClubTab.allCases, id: \.title) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                        selected = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 15, weight: .bold))
                        Text(tab.title)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(selected == tab ? Color.black.opacity(0.86) : Luxe.textMuted)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 58)
                    .background {
                        if selected == tab {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Luxe.accent)
                                .matchedGeometryEffect(id: "tab", in: tabAnimation)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Luxe.cardDeep.opacity(0.98))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Luxe.bgBottom.opacity(0.92))
    }
}

// MARK: - Shared UI

struct ScreenHeading: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 30, weight: .black, design: .serif))
            Text(subtitle)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Luxe.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct LabelPill: View {
    let text: String
    let accent: Bool

    var body: some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(accent ? Color.black.opacity(0.86) : Luxe.textMain)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(accent ? Luxe.accent : Luxe.cardSoft))
    }
}

struct KeyValueRow: View {
    let key: String
    let value: String
    var accent = false

    var body: some View {
        HStack {
            Text(key)
                .foregroundStyle(Luxe.textMuted)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(accent ? Luxe.accent : Luxe.textMain)
        }
    }
}

// MARK: - Lounge

struct ClubHomeReleaseView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ScreenHeading(title: "Noble Focus Club", subtitle: "Private Focus Arcade")

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("12 800")
                            .font(.title.bold())
                            .foregroundStyle(Luxe.accent)
                        Text("Focus Points")
                            .font(.caption)
                            .foregroundStyle(Luxe.textMuted)
                    }
                    Spacer()
                    LabelPill(text: "Guest Noble", accent: false)
                }
                .luxeCard()

                HStack(spacing: 12) {
                    SessionProgressOrb(progress: 0.0)
                        .frame(width: 90, height: 90)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tonight's Focus")
                            .font(.headline)
                        Text("Complete 3 skill games and claim your session reward.")
                            .font(.subheadline)
                            .foregroundStyle(Luxe.textMuted)
                        HStack {
                            LabelPill(text: "0/3 games", accent: false)
                            LabelPill(text: "+1 500", accent: true)
                        }
                    }
                }
                .luxeCard()

                NavigationLink {
                    ActiveSessionReleaseView()
                } label: {
                    Text("Start Session")
                        .headlineCTA()
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Club Notes")
                        .font(.title3.bold())
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            MiniInsightCard(title: "Daily Circuit Open", detail: "Complete 3 games today to earn extra points.")
                            MiniInsightCard(title: "Precision Bonus", detail: "Finish any game with 90%+ accuracy for a bonus.")
                            MiniInsightCard(title: "New Relic", detail: "Golden Crest unlocks after your first full session.")
                        }
                        .padding(.vertical, 2)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Featured Challenge")
                        .font(.headline)
                    Text("Spotlight Session")
                        .font(.title3.bold())
                    Text("Complete any focus game in Spotlight Session to unlock a fixed bonus reward.")
                        .foregroundStyle(Luxe.textMuted)
                    HStack {
                        LabelPill(text: "+900 fixed bonus", accent: true)
                        Spacer()
                        NavigationLink("Join") {
                            ArenaGamesReleaseView()
                        }
                        .font(.headline)
                        .foregroundStyle(Luxe.textMain)
                    }
                }
                .luxeCard()
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            .padding(.bottom, 150)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct SessionProgressOrb: View {
    let progress: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 10)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(colors: [Luxe.accent, Luxe.accentSoft], center: .center),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.headline)
                Text("Session")
                    .font(.caption2)
                    .foregroundStyle(Luxe.textMuted)
            }
        }
    }
}

struct MiniInsightCard: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.caption)
                .foregroundStyle(Luxe.textMuted)
                .lineLimit(3)
        }
        .padding(12)
        .frame(width: 180, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Luxe.cardSoft)
        )
    }
}

// MARK: - Arena / Games

struct GameItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let tags: [String]
    let reward: Int
    let difficulty: String
}

struct ArenaGamesReleaseView: View {
    private let games: [GameItem] = [
        .init(title: "Ember Gate", description: "Hold and release charge as the ember crosses twin gates.", tags: ["Rhythm", "Control"], reward: 420, difficulty: "Easy"),
        .init(title: "Prism Brake", description: "Brake a spinning prism inside the mirror window.", tags: ["Precision", "Timing"], reward: 540, difficulty: "Medium"),
        .init(title: "Vector Drift", description: "Nudge a drift node through shifting checkpoints.", tags: ["Control", "Focus"], reward: 500, difficulty: "Medium"),
        .init(title: "Sigil Sort", description: "Tap only sigils matching the active rule each wave.", tags: ["Attention", "Speed"], reward: 570, difficulty: "Medium"),
        .init(title: "Thread Runner", description: "Guide a drift core through unstable current lanes.", tags: ["Control", "Accuracy"], reward: 620, difficulty: "Medium"),
        .init(title: "Flux Dash", description: "Swipe chains that may invert direction mid-sequence.", tags: ["Reflex", "Speed"], reward: 460, difficulty: "Easy"),
        .init(title: "Echo Match", description: "Align echo phases before rings collapse.", tags: ["Precision", "Rhythm"], reward: 550, difficulty: "Medium"),
        .init(title: "Quiet Count", description: "Memorize silent pulse groups and rebuild the pattern.", tags: ["Focus", "Memory"], reward: 510, difficulty: "Easy"),
        .init(title: "Balance Forge", description: "Balance dual channels and prevent overload spikes.", tags: ["Control", "Stability"], reward: 640, difficulty: "Hard"),
        .init(title: "Gold Signal", description: "React only to valid dual-tone signal combinations.", tags: ["Reaction", "Focus"], reward: 440, difficulty: "Easy")
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ScreenHeading(title: "Arena", subtitle: "Challenge reflexes, timing, control, and focus")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Circuit")
                        .font(.headline)
                    Text("Complete 3 different games to finish today's circuit.")
                        .foregroundStyle(Luxe.textMuted)
                    HStack {
                        LabelPill(text: "0/3", accent: false)
                        Spacer()
                        LabelPill(text: "In Progress", accent: false)
                    }
                    Text("Bonus: +1 500 Focus Points")
                        .fontWeight(.semibold)
                        .foregroundStyle(Luxe.accent)
                }
                .luxeCard()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        LabelPill(text: "All", accent: true)
                        LabelPill(text: "Timing", accent: false)
                        LabelPill(text: "Precision", accent: false)
                        LabelPill(text: "Control", accent: false)
                        LabelPill(text: "Reaction", accent: false)
                    }
                    .padding(.vertical, 1)
                }

                ForEach(games) { game in
                    NavigationLink {
                        gameDestination(for: game)
                    } label: {
                        ArenaGameCard(game: game)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            .padding(.bottom, 150)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func gameDestination(for game: GameItem) -> some View {
        switch game.title {
        case "Ember Gate":
            PulseTapDetailReleaseView()
        case "Prism Brake":
            CrownLockDetailReleaseView()
        case "Thread Runner":
            VelvetTraceDetailReleaseView()
        default:
            GenericGameDetailReleaseView(game: game)
        }
    }
}

struct ArenaGameCard: View {
    let game: GameItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(game.title)
                        .font(.headline)
                    Text(game.difficulty)
                        .font(.caption)
                        .foregroundStyle(Luxe.textMuted)
                }
                Spacer()
                Text("+\(game.reward)")
                    .font(.headline)
                    .foregroundStyle(Luxe.accent)
            }

            Text(game.description)
                .font(.subheadline)
                .foregroundStyle(Luxe.textMuted)

            HStack {
                ForEach(game.tags, id: \.self) { tag in
                    LabelPill(text: tag, accent: false)
                }
                Spacer()
                Text("Best: —")
                    .font(.caption)
                    .foregroundStyle(Luxe.textMuted)
            }
        }
        .luxeCard()
    }
}

struct RulePoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "diamond.fill")
                .font(.caption2)
                .padding(.top, 5)
                .foregroundStyle(Luxe.accent)
            Text(text)
                .foregroundStyle(Luxe.textMain)
        }
    }
}

struct InfoGridCard: View {
    let key: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(key)
                .font(.caption)
                .foregroundStyle(Luxe.textMuted)
            Text(value)
                .font(.subheadline.bold())
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Luxe.cardSoft))
    }
}

struct PulseTapDetailReleaseView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ScreenHeading(title: "Ember Gate", subtitle: "Charge Timing Challenge")
                Text("Hold charge and release as the ember passes through twin gates.")
                    .foregroundStyle(Luxe.textMuted)
                    .luxeCard()

                HStack(spacing: 8) {
                    InfoGridCard(key: "Difficulty", value: "Easy")
                    InfoGridCard(key: "Best Score", value: "—")
                }
                HStack(spacing: 8) {
                    InfoGridCard(key: "Reward", value: "+420")
                    InfoGridCard(key: "Average Time", value: "45 sec")
                }

                HStack(spacing: 8) {
                    LabelPill(text: "Rhythm", accent: false)
                    LabelPill(text: "Control", accent: false)
                    LabelPill(text: "Focus", accent: false)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 8) {
                    RulePoint(text: "The ember travels between gate rails.")
                    RulePoint(text: "Release charge while ember is inside both gates.")
                    RulePoint(text: "Centered release grants perfect heat score.")
                    RulePoint(text: "Early or late release collapses your chain.")
                }
                .luxeCard()

                NavigationLink {
                    PulseTapLiveReleaseView()
                } label: {
                    Text("Play")
                        .headlineCTA()
                }
                .buttonStyle(.plain)

                NavigationLink {
                    PulseTapLiveReleaseView(practiceMode: true)
                } label: {
                    Text("Practice")
                        .secondaryCTA()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            .padding(.bottom, 150)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PulseTapLiveReleaseView: View {
    let practiceMode: Bool

    @State private var marker: CGFloat = 0
    @State private var direction: CGFloat = 1
    @State private var remaining = 45
    @State private var tick = 0
    @State private var running = true

    @State private var score = 0
    @State private var combo = 0
    @State private var bestCombo = 0
    @State private var perfectHits = 0
    @State private var attempts = 0
    @State private var accuracy: CGFloat = 1
    @State private var stateLabel = "Charge Ready"

    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    init(practiceMode: Bool = false) {
        self.practiceMode = practiceMode
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                topBadge(title: "Time", value: "\(remaining)")
                topBadge(title: "Score", value: "\(score)")
                topBadge(title: "Combo", value: "\(combo)")
            }

            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Luxe.card)
                VStack(spacing: 16) {
                    GeometryReader { geo in
                        let width = geo.size.width
                        let zoneStart = width * 0.42
                        let zoneWidth = width * 0.16
                        let markerX = width * marker

                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 12)
                            Capsule()
                                .fill(Luxe.accent.opacity(0.6))
                                .frame(width: zoneWidth, height: 14)
                                .offset(x: zoneStart)
                            Circle()
                                .fill(Luxe.accent)
                                .frame(width: 18, height: 18)
                                .offset(x: markerX - 9)
                        }
                    }
                    .frame(height: 24)
                    .padding(.horizontal, 22)

                    Text(stateLabel)
                        .font(.headline)
                        .foregroundStyle(stateColor)

                    Button("Release Charge") {
                        judgeTap()
                    }
                    .font(.headline)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Luxe.cardSoft))
                    .disabled(!running)
                }
            }
            .frame(height: 250)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Accuracy")
                    Spacer()
                    Text("\(Int(accuracy * 100))%")
                }
                .font(.subheadline)
                .foregroundStyle(Luxe.textMuted)

                ProgressView(value: accuracy)
                    .tint(Luxe.accent)

                HStack {
                    LabelPill(text: "Perfect", accent: false)
                    LabelPill(text: "Good", accent: false)
                    LabelPill(text: "Miss", accent: false)
                }
            }
            .luxeCard()

            if !running {
                NavigationLink {
                    GameResultReleaseView(
                        gameTitle: "Ember Gate",
                        score: score,
                        accuracy: Int(accuracy * 100),
                        bestCombo: bestCombo,
                        perfectHits: perfectHits,
                        baseReward: 420,
                        comboBonus: max(bestCombo * 8, 40),
                        focusBonus: Int(CGFloat(score) * 0.08)
                    )
                } label: {
                    Text(practiceMode ? "Finish Practice" : "View Result")
                        .headlineCTA()
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .padding(.bottom, 120)
        .navigationTitle(practiceMode ? "Ember Gate Practice" : "Ember Gate")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            guard running else { return }
            marker += 0.02 * direction
            if marker >= 1 {
                marker = 1
                direction = -1
            } else if marker <= 0 {
                marker = 0
                direction = 1
            }

            tick += 1
            if tick % 20 == 0 {
                remaining -= 1
                if remaining <= 0 {
                    running = false
                    stateLabel = "Session Complete"
                }
            }
        }
    }

    private var stateColor: Color {
        switch stateLabel {
        case "Perfect": return Luxe.success
        case "Good": return Luxe.accent
        case "Miss": return Luxe.danger
        default: return Luxe.textMuted
        }
    }

    private func judgeTap() {
        guard running else { return }

        attempts += 1
        let center: CGFloat = 0.5
        let delta = abs(marker - center)

        if delta <= 0.03 {
            stateLabel = "Perfect"
            perfectHits += 1
            combo += 1
            bestCombo = max(bestCombo, combo)
            score += 14 + combo * 2
        } else if delta <= 0.08 {
            stateLabel = "Good"
            combo += 1
            bestCombo = max(bestCombo, combo)
            score += 8 + combo
        } else {
            stateLabel = "Miss"
            combo = 0
            score = max(0, score - 4)
        }

        let successful = CGFloat(perfectHits + max(0, attempts - perfectHits - (combo == 0 ? 1 : 0)))
        accuracy = max(0, min(1, successful / CGFloat(max(attempts, 1))))
    }

    private func topBadge(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Luxe.textMuted)
            Text(value)
                .font(.headline)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Luxe.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

struct CrownLockDetailReleaseView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ScreenHeading(title: "Prism Brake", subtitle: "Rotational Brake Challenge")
                Text("Brake a spinning prism inside the mirror window.")
                    .foregroundStyle(Luxe.textMuted)
                    .luxeCard()

                HStack(spacing: 8) {
                    InfoGridCard(key: "Difficulty", value: "Medium")
                    InfoGridCard(key: "Best Score", value: "—")
                }
                InfoGridCard(key: "Reward", value: "+540")

                VStack(alignment: .leading, spacing: 8) {
                    RulePoint(text: "The prism spins around a steel ring.")
                    RulePoint(text: "Brake only when prism enters mirror window.")
                    RulePoint(text: "The window narrows after each round.")
                    RulePoint(text: "Perfect brakes increase your multiplier.")
                }
                .luxeCard()

                NavigationLink {
                    CrownLockLiveReleaseView()
                } label: {
                    Text("Play")
                        .headlineCTA()
                }
                .buttonStyle(.plain)

                NavigationLink {
                    CrownLockLiveReleaseView(practiceMode: true)
                } label: {
                    Text("Practice")
                        .secondaryCTA()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            .padding(.bottom, 150)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CrownLockLiveReleaseView: View {
    let practiceMode: Bool

    @State private var angle: Double = 0
    @State private var targetCenter: Double = 30
    @State private var targetWidth: Double = 52
    @State private var speed: Double = 3.0

    @State private var round = 1
    @State private var multiplier: Double = 1
    @State private var score = 0
    @State private var status = "Ready"
    @State private var finished = false

    private let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()

    init(practiceMode: Bool = false) {
        self.practiceMode = practiceMode
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                stat(title: "Round", value: "\(round)")
                stat(title: "Score", value: "\(score)")
                stat(title: "Multiplier", value: "x\(String(format: "%.1f", multiplier))")
            }

            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Luxe.card)

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 14)
                        .frame(width: 230, height: 230)

                    ArcSegment(start: targetCenter - targetWidth / 2, end: targetCenter + targetWidth / 2)
                        .stroke(Luxe.accent, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .frame(width: 230, height: 230)

                    Image(systemName: "hexagon.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Luxe.accent)
                        .offset(y: -107)
                        .rotationEffect(.degrees(angle))
                }
            }
            .frame(height: 310)

            Text(status)
                .font(.headline)
                .foregroundStyle(status == "Miss" ? Luxe.danger : Luxe.accent)

            Button("Tap to Brake") {
                lockAttempt()
            }
            .headlineCTA()
            .buttonStyle(.plain)
            .disabled(finished)

            if finished {
                NavigationLink {
                    GameResultReleaseView(
                        gameTitle: "Prism Brake",
                        score: score,
                        accuracy: max(65, min(98, 65 + score / 4)),
                        bestCombo: max(1, Int(multiplier * 3)),
                        perfectHits: max(1, score / 30),
                        baseReward: 540,
                        comboBonus: Int(multiplier * 70),
                        focusBonus: max(40, score / 3)
                    )
                } label: {
                    Text(practiceMode ? "Finish Practice" : "View Result")
                        .secondaryCTA()
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .padding(.bottom, 120)
        .navigationTitle(practiceMode ? "Prism Brake Practice" : "Prism Brake")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            guard !finished else { return }
            angle = (angle + speed).truncatingRemainder(dividingBy: 360)
        }
    }

    private func lockAttempt() {
        guard !finished else { return }

        let diff = angularDistance(angle, targetCenter)
        let allowed = targetWidth / 2

        if diff <= allowed * 0.45 {
            status = "Perfect Brake"
            score += Int(32 * multiplier)
            multiplier += 0.25
        } else if diff <= allowed {
            status = "Good Brake"
            score += Int(20 * multiplier)
            multiplier += 0.12
        } else {
            status = "Miss"
            multiplier = 1
            score = max(0, score - 12)
        }

        round += 1
        speed += 0.30
        targetWidth = max(14, targetWidth * 0.9)
        targetCenter = Double.random(in: 0...359)

        if round > 10 {
            finished = true
            status = "Run Complete"
        }
    }

    private func angularDistance(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b).truncatingRemainder(dividingBy: 360)
        return min(diff, 360 - diff)
    }

    private func stat(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Luxe.textMuted)
            Text(value)
                .font(.headline)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Luxe.card)
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
        )
    }
}

struct ArcSegment: Shape {
    let start: Double
    let end: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(start - 90),
            endAngle: .degrees(end - 90),
            clockwise: false
        )

        return path
    }
}

struct VelvetTraceDetailReleaseView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ScreenHeading(title: "Thread Runner", subtitle: "Drift Control Challenge")
                Text("Guide a drift core through unstable current lanes.")
                    .foregroundStyle(Luxe.textMuted)
                    .luxeCard()

                HStack(spacing: 8) {
                    InfoGridCard(key: "Difficulty", value: "Medium")
                    InfoGridCard(key: "Best Score", value: "—")
                }
                InfoGridCard(key: "Reward", value: "+620")

                VStack(alignment: .leading, spacing: 8) {
                    RulePoint(text: "Drag the core along moving current lanes.")
                    RulePoint(text: "Oversteering outside the lane reduces stability.")
                    RulePoint(text: "Long clean control boosts drift score.")
                    RulePoint(text: "Finish quickly for burst bonus.")
                }
                .luxeCard()

                NavigationLink {
                    VelvetTraceLiveReleaseView()
                } label: {
                    Text("Play")
                        .headlineCTA()
                }
                .buttonStyle(.plain)

                NavigationLink {
                    VelvetTraceLiveReleaseView(practiceMode: true)
                } label: {
                    Text("Practice")
                        .secondaryCTA()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            .padding(.bottom, 150)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct VelvetTraceLiveReleaseView: View {
    let practiceMode: Bool

    @State private var progress: CGFloat = 0
    @State private var accuracy: CGFloat = 1
    @State private var outsideTouches = 0
    @State private var didStart = false
    @State private var remaining = 60
    @State private var complete = false
    @State private var status = "Drag to stabilize"
    @State private var knobPosition = CGPoint(x: 20, y: 210)

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(practiceMode: Bool = false) {
        self.practiceMode = practiceMode
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                badge(title: "Progress", value: "\(Int(progress * 100))%")
                badge(title: "Accuracy", value: "\(Int(accuracy * 100))%")
                badge(title: "Time", value: "\(remaining)")
            }

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Luxe.card)

                    Path { path in
                        path.move(to: CGPoint(x: 20, y: laneY(x: 20, width: w, height: h)))
                        var x: CGFloat = 20
                        while x <= w - 20 {
                            path.addLine(to: CGPoint(x: x, y: laneY(x: x, width: w, height: h)))
                            x += 5
                        }
                    }
                    .stroke(Luxe.accent.opacity(0.65), style: StrokeStyle(lineWidth: 22, lineCap: .round, lineJoin: .round))

                    Path { path in
                        path.move(to: CGPoint(x: 20, y: laneY(x: 20, width: w, height: h)))
                        var x: CGFloat = 20
                        while x <= w - 20 {
                            path.addLine(to: CGPoint(x: x, y: laneY(x: x, width: w, height: h)))
                            x += 5
                        }
                    }
                    .stroke(Color.white.opacity(0.22), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                    Circle()
                        .fill(Luxe.accent)
                        .frame(width: 24, height: 24)
                        .position(knobPosition)
                        .shadow(color: Luxe.accent.opacity(0.6), radius: 10)

                    VStack {
                        HStack {
                            Text(status)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Luxe.textMain)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Luxe.cardSoft.opacity(0.9)))
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(10)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard !complete, remaining > 0 else { return }

                            if !didStart {
                                didStart = true
                                status = "Stabilizing"
                            }

                            let x = min(max(value.location.x, 20), w - 20)
                            let idealY = laneY(x: x, width: w, height: h)
                            let delta = abs(value.location.y - idealY)
                            let tolerance: CGFloat = 22

                            knobPosition = CGPoint(x: x, y: value.location.y)

                            if delta > tolerance {
                                outsideTouches += 1
                                status = "Oversteer"
                            } else {
                                status = "Stable Line"
                            }

                            progress = max(progress, (x - 20) / (w - 40))
                            let penalty = CGFloat(outsideTouches) * 0.02
                            accuracy = max(0.5, 1 - penalty)

                            if progress >= 1 {
                                complete = true
                                status = "Finish Burst"
                            }
                        }
                )
            }
            .frame(height: 300)

            if complete || remaining == 0 {
                NavigationLink {
                    GameResultReleaseView(
                        gameTitle: "Thread Runner",
                        score: Int(accuracy * 100) + Int(progress * 100),
                        accuracy: Int(accuracy * 100),
                        bestCombo: 1,
                        perfectHits: Int(progress * 10),
                        baseReward: 620,
                        comboBonus: Int(progress * 80),
                        focusBonus: Int(accuracy * 120)
                    )
                } label: {
                    Text(practiceMode ? "Finish Practice" : "View Result")
                        .headlineCTA()
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .padding(.bottom, 120)
        .navigationTitle(practiceMode ? "Thread Runner Practice" : "Thread Runner")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            guard didStart, !complete, remaining > 0 else { return }
            remaining -= 1
            if remaining == 0 && !complete {
                status = "Time Up"
            }
        }
    }

    private func laneY(x: CGFloat, width: CGFloat, height: CGFloat) -> CGFloat {
        let normalized = x / max(width, 1)
        let wave1 = sin(normalized * .pi * 1.45) * height * 0.26
        let wave2 = cos(normalized * .pi * 2.1) * height * 0.08
        return height * 0.62 - wave1 + wave2
    }

    private func badge(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Luxe.textMuted)
            Text(value)
                .font(.headline)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Luxe.card)
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
        )
    }
}

struct GenericGameDetailReleaseView: View {
    let game: GameItem
    @State private var showHint = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ScreenHeading(title: game.title, subtitle: "Skill Challenge")
                Text(game.description)
                    .foregroundStyle(Luxe.textMuted)
                    .luxeCard()

                HStack(spacing: 8) {
                    ForEach(game.tags, id: \.self) { tag in
                        LabelPill(text: tag, accent: false)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 8) {
                    InfoGridCard(key: "Difficulty", value: game.difficulty)
                    InfoGridCard(key: "Reward", value: "+\(game.reward)")
                }

                Button {
                    showHint = true
                } label: {
                    Text("Play")
                        .headlineCTA()
                }
                .buttonStyle(.plain)

                Button {
                    showHint = true
                } label: {
                    Text("Practice")
                        .secondaryCTA()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            .padding(.bottom, 150)
        }
        .alert("Playable Soon", isPresented: $showHint) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This game card is ready. Full interactive gameplay is enabled for Ember Gate, Prism Brake, and Thread Runner.")
        }
    }
}

struct GameResultReleaseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showContinueMessage = false
    let gameTitle: String
    let score: Int
    let accuracy: Int
    let bestCombo: Int
    let perfectHits: Int
    let baseReward: Int
    let comboBonus: Int
    let focusBonus: Int

    private var total: Int {
        baseReward + comboBonus + focusBonus
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ScreenHeading(title: "Session Complete", subtitle: gameTitle)

                VStack(alignment: .leading, spacing: 8) {
                    KeyValueRow(key: "Score", value: "\(score)")
                    KeyValueRow(key: "Accuracy", value: "\(accuracy)%")
                    KeyValueRow(key: "Best Combo", value: "\(bestCombo)")
                    KeyValueRow(key: "Perfect Hits", value: "\(perfectHits)")
                }
                .luxeCard()

                VStack(alignment: .leading, spacing: 8) {
                    KeyValueRow(key: "Base Reward", value: "+\(baseReward)")
                    KeyValueRow(key: "Combo Bonus", value: "+\(comboBonus)")
                    KeyValueRow(key: "Focus Bonus", value: "+\(focusBonus)")
                    Divider().overlay(Color.white.opacity(0.2))
                    KeyValueRow(key: "Total", value: "+\(total) Focus Points", accent: true)
                }
                .luxeCard()

                Button {
                    dismiss()
                } label: {
                    Text("Play Again")
                        .secondaryCTA()
                }
                .buttonStyle(.plain)

                Button {
                    showContinueMessage = true
                } label: {
                    Text("Continue Session")
                        .headlineCTA()
                }
                .buttonStyle(.plain)

                Button {
                    dismiss()
                } label: {
                    Text("Back to Arena")
                        .secondaryCTA()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            .padding(.bottom, 150)
        }
        .navigationTitle("Result")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Session Progress Updated", isPresented: $showContinueMessage) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your game result has been added to the active focus session.")
        }
    }
}

// MARK: - Session

struct ActiveSessionReleaseView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ScreenHeading(title: "Focus Session", subtitle: "Complete 3 games to claim your reward")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Session Goal")
                        .font(.headline)
                    Text("1/3 games")
                        .font(.title.bold())
                        .foregroundStyle(Luxe.accent)
                }
                .luxeCard()

                VStack(alignment: .leading, spacing: 8) {
                    sessionGameRow(name: "Ember Gate", status: "Done", color: Luxe.success)
                    sessionGameRow(name: "Prism Brake", status: "Next", color: Luxe.accent)
                    sessionGameRow(name: "Vector Drift", status: "Locked", color: Luxe.textMuted)
                }
                .luxeCard()

                Text("Finish session to claim +1 500 Focus Points")
                    .foregroundStyle(Luxe.accent)
                    .luxeCard()

                NavigationLink {
                    SessionCompleteReleaseView()
                } label: {
                    Text("Continue")
                        .headlineCTA()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            .padding(.bottom, 150)
        }
    }

    private func sessionGameRow(name: String, status: String, color: Color) -> some View {
        HStack {
            Text(name)
            Spacer()
            Text(status)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(color.opacity(0.16)))
        }
    }
}

struct SessionCompleteReleaseView: View {
    @State private var didClaimReward = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ScreenHeading(title: "Focus Session Complete", subtitle: "You completed today's focus session")

                VStack(alignment: .leading, spacing: 8) {
                    KeyValueRow(key: "Games Completed", value: "3")
                    KeyValueRow(key: "Average Accuracy", value: "86%")
                    KeyValueRow(key: "Best Combo", value: "14")
                    KeyValueRow(key: "Total Score", value: "218")
                }
                .luxeCard()

                VStack(alignment: .leading, spacing: 8) {
                    KeyValueRow(key: "Session Reward", value: "+1 500")
                    KeyValueRow(key: "Game Rewards", value: "+1 370")
                    KeyValueRow(key: "Accuracy Bonus", value: "+250")
                    Divider().overlay(Color.white.opacity(0.2))
                    KeyValueRow(key: "Total", value: "+3 120 Focus Points", accent: true)
                }
                .luxeCard()

                Text("Unlocked: Golden Crest progress updated")
                    .foregroundStyle(Luxe.textMuted)
                    .luxeCard()

                Button {
                    didClaimReward = true
                } label: {
                    Text(didClaimReward ? "Reward Claimed" : "Claim Reward")
                        .headlineCTA()
                }
                .buttonStyle(.plain)

                NavigationLink {
                    VaultReleaseView()
                } label: {
                    Text("View Vault")
                        .secondaryCTA()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            .padding(.bottom, 150)
        }
    }
}

// MARK: - Vault

struct RelicItem: Identifiable {
    let id = UUID()
    let title: String
    let requirement: String
    let description: String
    let locked: Bool
}

struct VaultReleaseView: View {
    private let relics: [RelicItem] = [
        .init(title: "Golden Crest", requirement: "Complete 3 games", description: "A first mark of focus inside the Noble Club.", locked: true),
        .init(title: "Crystal Crown", requirement: "Reach 80+ in Ember Gate", description: "Awarded for controlled charge timing under pressure.", locked: true),
        .init(title: "Ruby Dice", requirement: "Reach 3-day streak", description: "A relic for members who return with discipline.", locked: true),
        .init(title: "Emerald Token", requirement: "Earn 20 000 Focus Points", description: "A rare token for consistent club progress.", locked: true),
        .init(title: "Silver Hourglass", requirement: "Complete 10 rhythm games", description: "A symbol of cadence, patience, and precision.", locked: true),
        .init(title: "Velvet Seal", requirement: "Finish Thread Runner with 90% stability", description: "Unlocked by calm steering and clean lane control.", locked: true),
        .init(title: "Obsidian Crown", requirement: "Reach Bronze Noble rank", description: "A dark crown reserved for proven members.", locked: true),
        .init(title: "Noble Compass", requirement: "Complete 5 daily circuits", description: "A compass for members who keep steady progress.", locked: true)
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ScreenHeading(title: "Vault", subtitle: "Your private rewards archive")

                VStack(alignment: .leading, spacing: 6) {
                    Text("Club Balance")
                        .foregroundStyle(Luxe.textMuted)
                    Text("12 800")
                        .font(.title.bold())
                        .foregroundStyle(Luxe.accent)
                    Text("available Focus Points")
                        .font(.caption)
                        .foregroundStyle(Luxe.textMuted)
                }
                .luxeCard()

                ForEach(relics) { relic in
                    NavigationLink {
                        RelicDetailReleaseView(relic: relic)
                    } label: {
                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                Text(relic.title)
                                    .font(.headline)
                                Spacer()
                                LabelPill(text: relic.locked ? "Locked" : "Unlocked", accent: false)
                            }
                            Text(relic.requirement)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Luxe.accent)
                            Text(relic.description)
                                .font(.subheadline)
                                .foregroundStyle(Luxe.textMuted)
                        }
                        .luxeCard()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            .padding(.bottom, 150)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct RelicDetailReleaseView: View {
    let relic: RelicItem

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ScreenHeading(title: relic.title, subtitle: relic.locked ? "Locked" : "Unlocked")

                Text("A rare club relic awarded for fast timing and high accuracy.")
                    .foregroundStyle(Luxe.textMuted)
                    .luxeCard()

                VStack(alignment: .leading, spacing: 8) {
                    KeyValueRow(key: "Requirement", value: "Reach 80+ score in Ember Gate")
                    KeyValueRow(key: "Progress", value: "71 / 80")
                    KeyValueRow(key: "Reward after unlock", value: "+100 Prestige Points", accent: true)
                }
                .luxeCard()

                NavigationLink {
                    PulseTapDetailReleaseView()
                } label: {
                    Text("Play Ember Gate")
                        .headlineCTA()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            .padding(.bottom, 150)
        }
    }
}

// MARK: - Missions

struct MissionsReleaseView: View {
    @State private var dailyClaimed = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ScreenHeading(title: "Missions", subtitle: "Daily and weekly progression rewards")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Focus Task")
                        .font(.headline)
                    Text("Complete 3 skill games and claim your club reward.")
                        .foregroundStyle(Luxe.textMuted)
                    HStack {
                        LabelPill(text: "0/3", accent: false)
                        Spacer()
                        LabelPill(text: "+1 500", accent: true)
                    }
                    NavigationLink("Open Arena") {
                        ArenaGamesReleaseView()
                    }
                    .font(.headline)
                    .foregroundStyle(Luxe.textMain)
                }
                .luxeCard()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Royal Streak")
                        .font(.headline)
                    Text("Return every day to unlock bigger rewards.")
                        .foregroundStyle(Luxe.textMuted)
                    Text("Day 1 — +500")
                    Text("Day 2 — +800")
                    Text("Day 3 — +1 100")
                    Text("Day 4 — +1 500")
                    Text("Day 5 — +2 000")
                    Text("Day 6 — +2 600")
                    Text("Day 7 — +3 500")
                    Button {
                        dailyClaimed = true
                    } label: {
                        Text(dailyClaimed ? "Reward Claimed" : "Claim Daily Reward")
                            .secondaryCTA()
                    }
                    .buttonStyle(.plain)
                }
                .luxeCard()

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Focus Boost")
                            .font(.headline)
                        Spacer()
                        LabelPill(text: "Ready", accent: false)
                    }
                    Text("Activate a temporary boost before your next game.")
                        .foregroundStyle(Luxe.textMuted)
                    HStack {
                        LabelPill(text: "Precision", accent: false)
                        LabelPill(text: "Focus", accent: false)
                        LabelPill(text: "Reward", accent: false)
                    }
                    NavigationLink {
                        BoostInventoryReleaseView()
                    } label: {
                        Text("Claim Boost")
                            .headlineCTA()
                    }
                    .buttonStyle(.plain)
                }
                .luxeCard()

                WeeklyMissionBoard()
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            .padding(.bottom, 150)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct WeeklyMissionBoard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weekly Tasks")
                .font(.title3.bold())
            Text("Bigger goals for active club members")
                .font(.caption)
                .foregroundStyle(Luxe.textMuted)

            WeeklyMissionCard(title: "Precision Week", detail: "Complete 15 skill games", progress: "3/15", reward: "+5 000")
            WeeklyMissionCard(title: "Clean Timing", detail: "Get 90%+ accuracy in any rhythm game", progress: "0/1", reward: "+1 200")
            WeeklyMissionCard(title: "Combo Builder", detail: "Reach combo x15 in any game", progress: "0/1", reward: "+1 500")
            WeeklyMissionCard(title: "Lane Master", detail: "Finish Thread Runner above 90% stability", progress: "0/1", reward: "Velvet Seal Fragment")
            WeeklyMissionCard(title: "Focus Loyal", detail: "Play 5 days this week", progress: "1/5", reward: "+6 000")
        }
    }
}

struct WeeklyMissionCard: View {
    let title: String
    let detail: String
    let progress: String
    let reward: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(Luxe.textMuted)
            HStack {
                Text("Progress: \(progress)")
                    .font(.caption)
                Spacer()
                Text("Reward: \(reward)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Luxe.accent)
            }
        }
        .luxeCard()
    }
}

struct BoostInventoryReleaseView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ScreenHeading(title: "Boosts", subtitle: "Use boosts before your next skill game")

                BoostEntryCard(title: "Precision Boost", detail: "Makes target zones slightly larger for one game.", status: "Available", action: "Activate")
                BoostEntryCard(title: "Combo Shield", detail: "Protects your combo from one mistake.", status: "Available", action: "Activate")
                BoostEntryCard(title: "Reward Boost", detail: "Adds +20% Focus Points after one game.", status: "Locked", action: "Unlock at 3-day streak")
                BoostEntryCard(title: "Time Boost", detail: "Adds +10 seconds to timed games.", status: "Available", action: "Activate")
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            .padding(.bottom, 150)
        }
    }
}

struct BoostEntryCard: View {
    let title: String
    let detail: String
    let status: String
    let action: String
    @State private var activated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                LabelPill(text: status, accent: false)
            }
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(Luxe.textMuted)
            Button {
                if status == "Available" {
                    activated = true
                }
            } label: {
                Text(activated ? "Activated" : action)
                    .secondaryCTA()
            }
            .buttonStyle(.plain)
            .disabled(status != "Available")
        }
        .luxeCard()
    }
}

// MARK: - Member

struct MemberReleaseView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ScreenHeading(title: "Member", subtitle: "Club profile and progression")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Guest Noble")
                        .font(.title3.bold())
                    Text("Prestige: 0 total points")
                        .foregroundStyle(Luxe.textMuted)
                    Text("Next Rank: Bronze Noble")
                        .foregroundStyle(Luxe.accent)
                    ProgressView(value: 0)
                        .tint(Luxe.accent)

                    NavigationLink {
                        RanksReleaseView()
                    } label: {
                        Text("View Ranks")
                            .headlineCTA()
                    }
                    .buttonStyle(.plain)
                }
                .luxeCard()

                VStack(alignment: .leading, spacing: 8) {
                    KeyValueRow(key: "Games Played", value: "0")
                    KeyValueRow(key: "Club Balance", value: "12 800")
                    KeyValueRow(key: "Daily Task", value: "0/3")
                    KeyValueRow(key: "Current Streak", value: "1 Day")
                    KeyValueRow(key: "Relics Found", value: "0")
                    KeyValueRow(key: "Best Game", value: "—")
                    KeyValueRow(key: "Favorite Session", value: "Spotlight Session")
                    KeyValueRow(key: "Highest Combo", value: "—")
                    KeyValueRow(key: "Best Accuracy", value: "—")
                }
                .luxeCard()

                NavigationLink {
                    SettingsReleaseView()
                } label: {
                    Text("Settings")
                        .secondaryCTA()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            .padding(.bottom, 150)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct RanksReleaseView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ScreenHeading(title: "Club Ranks", subtitle: "Progress through Noble Focus Club")

                rankRow(name: "Guest Noble", detail: "Current rank", current: true)
                rankRow(name: "Bronze Noble", detail: "500 prestige points", current: false)
                rankRow(name: "Silver Noble", detail: "1 500 prestige points", current: false)
                rankRow(name: "Golden Noble", detail: "4 000 prestige points", current: false)
                rankRow(name: "Royal Noble", detail: "9 000 prestige points", current: false)
                rankRow(name: "Crown Master", detail: "15 000 prestige points", current: false)
                rankRow(name: "Grand Focus Master", detail: "25 000 prestige points", current: false)

                Text("Prestige grows by completing sessions, unlocking relics, finishing weekly tasks, and reaching high scores.")
                    .foregroundStyle(Luxe.textMuted)
                    .luxeCard()
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            .padding(.bottom, 150)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func rankRow(name: String, detail: String, current: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(current ? Luxe.accent : Luxe.textMuted)
            }
            Spacer()
            if current {
                LabelPill(text: "Current", accent: true)
            }
        }
        .luxeCard()
    }
}

struct SettingsReleaseView: View {
    @AppStorage("settings.sound") private var sound = true
    @AppStorage("settings.haptics") private var haptics = true
    @AppStorage("settings.reminder") private var reminder = true
    @AppStorage("settings.reducedMotion") private var reducedMotion = false
    @AppStorage("settings.difficultyAssist") private var difficultyAssist = false
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false

    @State private var activeAlert: SettingsAlert?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ScreenHeading(title: "Settings", subtitle: "Club preferences")

                settingToggle(title: "Sound Effects", value: $sound)
                settingToggle(title: "Haptics", value: $haptics)
                settingToggle(title: "Daily Reminder", value: $reminder)
                settingToggle(title: "Reduced Motion", value: $reducedMotion)
                settingToggle(title: "Difficulty Assist", value: $difficultyAssist)

                Link(destination: URL(string: "https://www.apple.com/legal/privacy/")!) {
                    Text("Privacy Policy")
                        .secondaryCTA()
                }

                Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                    Text("Terms of Use")
                        .secondaryCTA()
                }

                Button {
                    activeAlert = .reset
                } label: {
                    Text("Reset Progress")
                        .secondaryCTA()
                }
                .buttonStyle(.plain)

                Button {
                    activeAlert = .saved
                } label: {
                    Text("Save Settings")
                        .headlineCTA()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            .padding(.bottom, 150)
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .saved:
                return Alert(
                    title: Text("Settings Saved"),
                    message: Text("Your preferences were saved successfully."),
                    dismissButton: .cancel(Text("OK"))
                )
            case .reset:
                return Alert(
                    title: Text("Reset Progress?"),
                    message: Text("This will reopen onboarding on next launch."),
                    primaryButton: .destructive(Text("Reset")) {
                        didCompleteOnboarding = false
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
        }
    }

    private func settingToggle(title: String, value: Binding<Bool>) -> some View {
        HStack {
            Text(title)
            Spacer()
            Toggle("", isOn: value)
                .labelsHidden()
                .tint(Luxe.accent)
        }
        .luxeCard()
    }
}

enum SettingsAlert: Identifiable {
    case saved
    case reset

    var id: String {
        switch self {
        case .saved: return "saved"
        case .reset: return "reset"
        }
    }
}

// MARK: - CTAs

extension View {
    func headlineCTA() -> some View {
        self
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Luxe.accent, Luxe.accentSoft],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .foregroundStyle(Color.black.opacity(0.86))
    }

    func secondaryCTA() -> some View {
        self
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Luxe.cardSoft)
            )
            .foregroundStyle(Luxe.textMain)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
