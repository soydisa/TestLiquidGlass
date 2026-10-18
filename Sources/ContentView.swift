
import SwiftUI

enum AppTab: String, CaseIterable {
    case home = "Home"
    case effects = "Effetti"
    case settings = "Impostazioni"
    case colors = "Colori"
    case about = "Info"

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .effects: return "sparkles"
        case .settings: return "slider.horizontal.3"
        case .colors: return "paintpalette.fill"
        case .about: return "info.circle.fill"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var glassEnabled = true
    @State private var animationsEnabled = true

    var body: some View {
        ZStack(alignment: .bottom) {
            background
                .ignoresSafeArea()

            Group {
                switch selectedTab {
                case .home:
                    homeView
                case .effects:
                    effectsView
                case .settings:
                    settingsView
                case .colors:
                    colorsView
                case .about:
                    aboutView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(
                animationsEnabled
                ? .opacity.combined(with: .offset(y: 8))
                : .identity
            )
            .animation(
                animationsEnabled
                ? .spring(response: 0.35, dampingFraction: 0.85)
                : nil,
                value: selectedTab
            )

            bottomBar
                .padding(.bottom, 8)
                .zIndex(1)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .preferredColorScheme(.dark)
    }

    // MARK: - Background

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.16, blue: 0.52),
                    Color(red: 0.35, green: 0.10, blue: 0.68),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.cyan.opacity(0.3))
                .frame(width: 240, height: 240)
                .blur(radius: 75)
                .offset(x: -140, y: -230)

            Circle()
                .fill(.purple.opacity(0.4))
                .frame(width: 270, height: 270)
                .blur(radius: 85)
                .offset(x: 150, y: 180)
        }
    }

    // MARK: - Home

    private var homeView: some View {
        VStack(spacing: 22) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 56, weight: .medium))

            Text("Liquid Glass")
                .font(.system(size: 36, weight: .bold))

            Text("La mia app di prova")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.7))

            Button {
                select(.effects)
            } label: {
                Label("Esplora gli effetti", systemImage: "wand.and.stars")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: Capsule())
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(24)
    }

    // MARK: - Effects

    private var effectsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                pageTitle(
                    "Effetti",
                    subtitle: "Prova il vetro originale di iOS."
                )

                VStack(alignment: .leading, spacing: 18) {
                    Text("Liquid Glass")
                        .font(.title2.bold())

                    Text("Una superficie traslucida che interagisce con lo sfondo.")
                        .foregroundStyle(.white.opacity(0.75))

                    Toggle("Effetto vetro", isOn: $glassEnabled)
                        .tint(.purple)

                    RoundedRectangle(cornerRadius: 30)
                        .fill(.clear)
                        .frame(height: 150)
                        .overlay {
                            VStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 38))
                                Text(glassEnabled ? "Glass attivo" : "Glass disattivato")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                        }
                        .modifier(GlassPreview(enabled: glassEnabled))
                }
                .padding(22)
                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 30))
                .overlay {
                    RoundedRectangle(cornerRadius: 30)
                        .strokeBorder(.white.opacity(0.1))
                }

                HStack(spacing: 14) {
                    sampleCard("Regular", style: .regular)
                    sampleCard("Clear", style: .clear)
                }
            }
            .foregroundStyle(.white)
            .padding(24)
            .padding(.top, 45)
            .padding(.bottom, 120)
        }
    }

    private struct GlassPreview: ViewModifier {
        let enabled: Bool

        func body(content: Content) -> some View {
            if enabled {
                content.glassEffect(
                    .regular,
                    in: RoundedRectangle(cornerRadius: 30)
                )
            } else {
                content.background(
                    .white.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 30)
                )
            }
        }
    }

    private func sampleCard(_ title: String, style: Glass) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "circle.hexagongrid.fill")
                .font(.system(size: 30))
            Text(title)
                .font(.headline)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .glassEffect(style, in: RoundedRectangle(cornerRadius: 26))
    }

    // MARK: - Settings

    private var settingsView: some View {
        VStack(alignment: .leading, spacing: 24) {
            pageTitle(
                "Impostazioni",
                subtitle: "Personalizza la tua esperienza."
            )

            VStack(spacing: 0) {
                Toggle("Effetto Liquid Glass", isOn: $glassEnabled)
                    .padding(18)

                Divider().overlay(.white.opacity(0.15))

                Toggle("Animazioni", isOn: $animationsEnabled)
                    .padding(18)
            }
            .tint(.purple)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 26))

            Spacer()
        }
        .foregroundStyle(.white)
        .padding(24)
        .padding(.top, 60)
    }

    // MARK: - Colors

    private var colorsView: some View {
        VStack(spacing: 28) {
            pageTitle(
                "Colori",
                subtitle: "Il vetro cambia con ciò che si trova dietro."
            )

            HStack(spacing: 12) {
                colorCircle(.blue)
                colorCircle(.purple)
                colorCircle(.cyan)
                colorCircle(.pink)
                colorCircle(.indigo)
            }

            Text("Sperimenta con sfondi luminosi e scuri per osservare le trasparenze.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.75))

            Spacer()
        }
        .foregroundStyle(.white)
        .padding(24)
        .padding(.top, 65)
    }

    private func colorCircle(_ color: Color) -> some View {
        Circle()
            .fill(color.gradient)
            .frame(width: 48, height: 48)
            .overlay {
                Circle().strokeBorder(.white.opacity(0.5), lineWidth: 1)
            }
            .glassEffect(.regular, in: Circle())
    }

    // MARK: - About

    private var aboutView: some View {
        VStack(spacing: 22) {
            Spacer()

            Image(systemName: "iphone.gen3")
                .font(.system(size: 56))

            Text("LiquidGlassTest")
                .font(.system(size: 30, weight: .bold))

            Text("Un piccolo laboratorio per sperimentare SwiftUI e Liquid Glass.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.75))

            Text("iOS 26+")
                .font(.caption)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .glassEffect(.regular, in: Capsule())

            Spacer()
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(30)
    }

    // MARK: - Shared elements

    private func pageTitle(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 34, weight: .bold))

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private func select(_ tab: AppTab) {
        if animationsEnabled {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        } else {
            selectedTab = tab
        }
    }

    // MARK: - Scrollable Liquid Glass navigation

    private var bottomBar: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(AppTab.allCases, id: \.self) { tab in
                        Button {
                            select(tab)

                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                proxy.scrollTo(tab, anchor: .center)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: tab.symbol)
                                    .font(.system(size: 17, weight: .semibold))

                                Text(tab.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .fixedSize()
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 17)
                            .frame(height: 48)
                            .background {
                                if selectedTab == tab {
                                    Capsule()
                                        .fill(.white.opacity(0.16))
                                        .glassEffect(.regular, in: Capsule())
                                }
                            }
                            .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .id(tab)
                        .accessibilityAddTraits(
                            selectedTab == tab ? .isSelected : []
                        )
                    }
                }
                .padding(7)
            }
            .scrollClipDisabled()
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .glassEffect(.regular, in: Capsule())
            }
            .overlay {
                Capsule()
                    .strokeBorder(.white.opacity(0.16), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.25), radius: 20, y: 8)
            .padding(.horizontal, 18)
            .onChange(of: selectedTab) { _, tab in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    proxy.scrollTo(tab, anchor: .center)
                }
            }
        }
    }
}
