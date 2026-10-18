
import SwiftUI

enum AppTab: String, CaseIterable {
    case home = "Home"
    case effects = "Effetti"
    case settings = "Impostazioni"

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .effects: return "sparkles"
        case .settings: return "slider.horizontal.3"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var glassEnabled = true
    @State private var animationEnabled = true

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.18, blue: 0.65),
                    Color(red: 0.40, green: 0.12, blue: 0.70),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(.cyan.opacity(0.22))
                .frame(width: 220, height: 220)
                .blur(radius: 65)
                .offset(x: -130, y: -220)
                .allowsHitTesting(false)

            Circle()
                .fill(.purple.opacity(0.35))
                .frame(width: 250, height: 250)
                .blur(radius: 70)
                .offset(x: 140, y: 160)
                .allowsHitTesting(false)

            Group {
                switch selectedTab {
                case .home:
                    homeView
                case .effects:
                    effectsView
                case .settings:
                    settingsView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(
                animationEnabled
                ? .opacity.combined(with: .offset(y: 8))
                : .identity
            )
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            tabBar
                .padding(.horizontal, 22)
                .padding(.top, 8)
                .padding(.bottom, 6)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Home

    private var homeView: some View {
        VStack(spacing: 22) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 52, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)

            VStack(spacing: 8) {
                Text("Liquid Glass")
                    .font(.system(size: 34, weight: .bold))

                Text("La mia app di prova")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.72))
            }

            Button {
                withAnimation(.spring(response: 0.35)) {
                    selectedTab = .effects
                }
            } label: {
                Label("Esplora gli effetti", systemImage: "wand.and.stars")
                    .font(.headline)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: Capsule())
            .padding(.horizontal, 24)

            Text("Realizzato con SwiftUI")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))

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
                VStack(alignment: .leading, spacing: 8) {
                    Text("Effetti")
                        .font(.system(size: 34, weight: .bold))

                    Text("Sperimenta con il vetro di iOS.")
                        .foregroundStyle(.white.opacity(0.7))
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Liquid Glass")
                        .font(.title3.bold())

                    Text("Una superficie traslucida che interagisce con ciò che si trova dietro.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))

                    HStack(spacing: 12) {
                        Image(systemName: "circle.hexagongrid.fill")
                            .font(.system(size: 30))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Superficie in vetro")
                                .font(.headline)

                            Text(glassEnabled ? "Effetto attivo" : "Effetto disattivato")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        Spacer()

                        Toggle("Liquid Glass", isOn: $glassEnabled)
                            .labelsHidden()
                    }
                    .padding(18)
                    .background {
                        if glassEnabled {
                            RoundedRectangle(cornerRadius: 26)
                                .fill(.clear)
                                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 26))
                        } else {
                            RoundedRectangle(cornerRadius: 26)
                                .fill(.white.opacity(0.08))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Stili di vetro")
                        .font(.title3.bold())

                    HStack(spacing: 12) {
                        glassSample("Regular", style: .regular)
                        glassSample("Clear", style: .clear)
                    }

                    Text("Prova a osservare come cambia il vetro sullo sfondo colorato.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                }
            }
            .foregroundStyle(.white)
            .padding(24)
            .padding(.bottom, 12)
        }
    }

    private func glassSample(
        _ title: String,
        style: Glass
    ) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 30))

            Text(title)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .glassEffect(style, in: RoundedRectangle(cornerRadius: 26))
    }

    // MARK: - Settings

    private var settingsView: some View {
        VStack(alignment: .leading, spacing: 26) {
            Text("Impostazioni")
                .font(.system(size: 34, weight: .bold))

            Text("Personalizza il comportamento dell'app.")
                .foregroundStyle(.white.opacity(0.7))

            VStack(spacing: 0) {
                Toggle(isOn: $glassEnabled) {
                    Label("Liquid Glass", systemImage: "circle.lefthalf.filled")
                }
                .padding(18)

                Divider()
                    .overlay(.white.opacity(0.15))
                    .padding(.horizontal, 18)

                Toggle(isOn: $animationEnabled) {
                    Label("Animazioni", systemImage: "wind")
                }
                .padding(18)
            }
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 26))

            Spacer()
        }
        .foregroundStyle(.white)
        .padding(24)
        .padding(.top, 24)
    }

    // MARK: - Bottom navigation

    private var tabBar: some View {
        HStack(spacing: 6) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    if animationEnabled {
                        withAnimation(.spring(
                            response: 0.36,
                            dampingFraction: 0.78
                        )) {
                            selectedTab = tab
                        }
                    } else {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 20, weight: .medium))
                            .symbolEffect(
                                .bounce,
                                value: selectedTab == tab
                            )

                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .contentShape(Capsule())
                    .background {
                        if selectedTab == tab {
                            Capsule()
                                .fill(.white.opacity(0.13))
                                .glassEffect(
                                    .regular,
                                    in: Capsule()
                                )
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.rawValue)
                .accessibilityAddTraits(
                    selectedTab == tab ? .isSelected : []
                )
            }
        }
        .padding(7)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .glassEffect(.regular, in: Capsule())
        }
        .overlay {
            Capsule()
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.2), radius: 20, y: 8)
    }
}
