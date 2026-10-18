
import SwiftUI
import Combine

enum AppTab: String, CaseIterable {
    case tasks = "Attività"
    case notes = "Note"
    case focus = "Focus"
    case summary = "Riepilogo"
    case settings = "Impostazioni"

    var symbol: String {
        switch self {
        case .tasks: return "checkmark.circle.fill"
        case .notes: return "note.text"
        case .focus: return "timer"
        case .summary: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct TodoItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var completed = false
}

struct ContentView: View {
    @AppStorage("flow_tasks") private var tasksJSON = "[]"
    @AppStorage("flow_notes") private var notes = ""
    @AppStorage("flow_animations") private var animationsEnabled = true
    @AppStorage("flow_glass") private var glassEnabled = true
    @AppStorage("flow_accent") private var accentName = "Viola"

    @State private var selectedTab: AppTab = .tasks
    @State private var newTask = ""
    @State private var remainingSeconds = 25 * 60
    @State private var timerRunning = false
    @State private var dragPosition: CGFloat? = nil
    @State private var dragDidMove = false

    private let clock = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    private var tasks: [TodoItem] {
        guard let data = tasksJSON.data(using: .utf8),
              let items = try? JSONDecoder().decode(
                [TodoItem].self,
                from: data
              ) else {
            return []
        }
        return items
    }

    private var selectedIndex: Int {
        AppTab.allCases.firstIndex(of: selectedTab) ?? 0
    }

    private var accent: Color {
        switch accentName {
        case "Blu": return .blue
        case "Ciano": return .cyan
        case "Rosa": return .pink
        case "Verde": return .green
        default: return .purple
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            background
                .ignoresSafeArea(.container, edges: .bottom)

            VStack(spacing: 0) {
                header
                    .padding(.top, 54)

                Group {
                    switch selectedTab {
                    case .tasks: tasksView
                    case .notes: notesView
                    case .focus: focusView
                    case .summary: summaryView
                    case .settings: settingsView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .id(selectedTab)
                .transition(
                    animationsEnabled ? .opacity : .identity
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 95)

            bottomBar
                .padding(.horizontal, 14)
                .padding(.bottom, 28)
                .zIndex(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .statusBarHidden(false)
        .preferredColorScheme(.dark)
        .onReceive(clock) { _ in
            guard timerRunning else { return }

            if remainingSeconds <= 1 {
                remainingSeconds = 0
                timerRunning = false
            } else {
                remainingSeconds -= 1
            }
        }
    }

    // MARK: - Fullscreen background

    private var background: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.10, blue: 0.32),
                        Color(red: 0.25, green: 0.08, blue: 0.48),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(accent.opacity(0.35))
                    .frame(width: 270, height: 270)
                    .blur(radius: 85)
                    .position(
                        x: geo.size.width * 0.12,
                        y: geo.size.height * 0.20
                    )

                Circle()
                    .fill(.cyan.opacity(0.17))
                    .frame(width: 240, height: 240)
                    .blur(radius: 80)
                    .position(
                        x: geo.size.width * 0.92,
                        y: geo.size.height * 0.65
                    )
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("FLOW")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(4)
                    .foregroundStyle(.white.opacity(0.55))

                Text(selectedTab.rawValue)
                    .font(.system(size: 30, weight: .bold))
                    .contentTransition(.opacity)
            }

            Spacer()

            Image(systemName: selectedTab.symbol)
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(accent.opacity(0.18), in: Circle())
                .glassEffect(.regular, in: Circle())
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 23)
        .padding(.bottom, 18)
    }

    // MARK: - Tasks

    private var tasksView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(spacing: 12) {
                    statCard(
                        "Da fare",
                        value: "\(tasks.filter { !$0.completed }.count)",
                        icon: "circle"
                    )

                    statCard(
                        "Completate",
                        value: "\(tasks.filter { $0.completed }.count)",
                        icon: "checkmark.circle.fill"
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Nuova attività")
                        .font(.headline)

                    HStack(spacing: 10) {
                        TextField("Cosa devi fare?", text: $newTask)
                            .submitLabel(.done)
                            .onSubmit(addTask)
                            .padding(15)
                            .background(
                                .white.opacity(0.08),
                                in: RoundedRectangle(cornerRadius: 18)
                            )

                        Button(action: addTask) {
                            Image(systemName: "plus")
                                .font(.system(size: 19, weight: .bold))
                                .frame(width: 50, height: 50)
                                .glassEffect(
                                    .regular.interactive(),
                                    in: Circle()
                                )
                        }
                        .disabled(
                            newTask.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("La tua lista")
                        .font(.headline)

                    if tasks.isEmpty {
                        emptyState(
                            "Nessuna attività",
                            subtitle: "Aggiungi qui quello che vuoi ricordare.",
                            icon: "checkmark.circle"
                        )
                    }

                    ForEach(tasks) { task in
                        HStack(spacing: 12) {
                            Button {
                                toggleTask(task)
                            } label: {
                                Image(
                                    systemName: task.completed
                                    ? "checkmark.circle.fill"
                                    : "circle"
                                )
                                .font(.system(size: 23))
                                .foregroundStyle(
                                    task.completed ? .green : .white.opacity(0.65)
                                )
                            }
                            .buttonStyle(.plain)

                            Text(task.title)
                                .strikethrough(task.completed)
                                .foregroundStyle(
                                    task.completed
                                    ? .white.opacity(0.45)
                                    : .white
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button(role: .destructive) {
                                saveTasks(tasks.filter { $0.id != task.id })
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.white.opacity(0.55))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(15)
                        .background(
                            .white.opacity(0.065),
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                    }
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .padding(.bottom, 22)
        }
        .scrollIndicators(.hidden)
    }

    private func addTask() {
        let title = newTask.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !title.isEmpty else { return }

        var updated = tasks
        updated.insert(TodoItem(title: title), at: 0)
        saveTasks(updated)
        newTask = ""
    }

    private func toggleTask(_ task: TodoItem) {
        var updated = tasks
        guard let index = updated.firstIndex(
            where: { $0.id == task.id }
        ) else { return }

        updated[index].completed.toggle()
        saveTasks(updated)
    }

    private func saveTasks(_ items: [TodoItem]) {
        guard let data = try? JSONEncoder().encode(items),
              let string = String(data: data, encoding: .utf8) else {
            return
        }
        tasksJSON = string
    }

    // MARK: - Notes

    private var notesView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Appunti personali")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.65))

            TextEditor(text: $notes)
                .scrollContentBackground(.hidden)
                .font(.system(size: 17))
                .foregroundStyle(.white)
                .padding(12)
                .background(
                    .white.opacity(0.07),
                    in: RoundedRectangle(cornerRadius: 25)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 25)
                        .strokeBorder(.white.opacity(0.12))
                        .allowsHitTesting(false)
                }

            Label("Salvataggio automatico", systemImage: "checkmark.circle")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 15)
    }

    // MARK: - Focus

    private var focusView: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Dedica 25 minuti a una cosa alla volta.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)

                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.10), lineWidth: 12)

                    Circle()
                        .trim(
                            from: 0,
                            to: max(0, min(1, Double(remainingSeconds) / 1500))
                        )
                        .stroke(
                            accent.gradient,
                            style: StrokeStyle(
                                lineWidth: 12,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 8) {
                        Text(timeString)
                            .font(
                                .system(
                                    size: 47,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .monospacedDigit()

                        Text(timerRunning ? "IN CORSO" : "FOCUS")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .frame(width: 245, height: 245)
                .padding(.vertical, 12)

                HStack(spacing: 12) {
                    Button {
                        if remainingSeconds == 0 {
                            remainingSeconds = 25 * 60
                        }
                        timerRunning.toggle()
                    } label: {
                        Label(
                            timerRunning ? "Pausa" : "Inizia",
                            systemImage: timerRunning ? "pause.fill" : "play.fill"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive(), in: Capsule())

                    Button {
                        timerRunning = false
                        remainingSeconds = 25 * 60
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.headline)
                            .frame(width: 56, height: 56)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular, in: Circle())
                }

                Text("Quando il timer finisce, prenditi una pausa.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .foregroundStyle(.white)
            .padding(24)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
    }

    private var timeString: String {
        String(
            format: "%02d:%02d",
            remainingSeconds / 60,
            remainingSeconds % 60
        )
    }

    // MARK: - Summary

    private var summaryView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("I tuoi progressi")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))

                statCard(
                    "Attività totali",
                    value: "\(tasks.count)",
                    icon: "list.bullet"
                )

                statCard(
                    "Completate",
                    value: "\(tasks.filter { $0.completed }.count)",
                    icon: "checkmark.circle.fill"
                )

                statCard(
                    "Da completare",
                    value: "\(tasks.filter { !$0.completed }.count)",
                    icon: "hourglass"
                )

                if tasks.contains(where: { $0.completed }) {
                    Button {
                        saveTasks(tasks.filter { !$0.completed })
                    } label: {
                        Label(
                            "Rimuovi attività completate",
                            systemImage: "trash"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive(), in: Capsule())
                }

                if tasks.isEmpty {
                    emptyState(
                        "Nessun dato ancora",
                        subtitle: "Le statistiche appariranno quando aggiungi attività.",
                        icon: "chart.bar"
                    )
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .padding(.bottom, 22)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Settings

    private var settingsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Personalizza Flow")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))

                VStack(spacing: 0) {
                    Toggle("Effetti Liquid Glass", isOn: $glassEnabled)
                        .tint(accent)
                        .padding(17)

                    Divider().overlay(.white.opacity(0.12))

                    Toggle("Animazioni", isOn: $animationsEnabled)
                        .tint(accent)
                        .padding(17)
                }
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))

                VStack(alignment: .leading, spacing: 14) {
                    Text("Colore principale")
                        .font(.headline)

                    HStack(spacing: 10) {
                        ForEach(
                            ["Viola", "Blu", "Ciano", "Rosa", "Verde"],
                            id: \.self
                        ) { name in
                            Button {
                                accentName = name
                            } label: {
                                Circle()
                                    .fill(colorFor(name))
                                    .frame(width: 39, height: 39)
                                    .overlay {
                                        if accentName == name {
                                            Circle()
                                                .strokeBorder(
                                                    .white,
                                                    lineWidth: 3
                                                )
                                                .padding(4)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(name)
                        }
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Dati locali")
                        .font(.headline)

                    Text("Attività e appunti vengono salvati su questo dispositivo. Non vengono sincronizzati con altri dispositivi.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.65))
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))

                Button(role: .destructive) {
                    timerRunning = false
                    remainingSeconds = 25 * 60
                    notes = ""
                    saveTasks([])
                } label: {
                    Label(
                        "Cancella tutti i dati",
                        systemImage: "trash"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(17)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular, in: Capsule())
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .padding(.bottom, 25)
        }
        .scrollIndicators(.hidden)
    }

    private func colorFor(_ name: String) -> Color {
        switch name {
        case "Blu": return .blue
        case "Ciano": return .cyan
        case "Rosa": return .pink
        case "Verde": return .green
        default: return .purple
        }
    }

    // MARK: - Shared components

    private func statCard(
        _ title: String,
        value: String,
        icon: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(accent)
                .frame(width: 45, height: 45)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 15))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                Text(value)
                    .font(.system(size: 26, weight: .bold))
            }

            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            .white.opacity(0.055),
            in: RoundedRectangle(cornerRadius: 23)
        )
    }

    private func emptyState(
        _ title: String,
        subtitle: String,
        icon: String
    ) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 34))
                .foregroundStyle(accent)

            Text(title)
                .font(.headline)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(25)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 25))
    }

    // MARK: - Draggable Liquid Glass tab bar


    private var bottomBar: some View {
        GeometryReader { geometry in
            let count = CGFloat(AppTab.allCases.count)
            let tabWidth = geometry.size.width / count
    
            let visualIndex = min(
                max(dragPosition ?? CGFloat(selectedIndex), 0),
                count - 1
            )
    
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .glassEffect(.regular, in: Capsule())
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                .white.opacity(0.16),
                                lineWidth: 1
                            )
                    }
    
                Capsule()
                    .fill(.clear)
                    .frame(width: tabWidth - 6, height: 60)
                    .glassEffect(
                        glassEnabled
                            ? .regular.interactive()
                            : .clear,
                        in: Capsule()
                    )
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                .white.opacity(0.20),
                                lineWidth: 1
                            )
                    }
                    .offset(x: visualIndex * tabWidth + 3)
                    .allowsHitTesting(false)
    
                HStack(spacing: 0) {
                    ForEach(
                        Array(AppTab.allCases.enumerated()),
                        id: \.element
                    ) { index, tab in
                        VStack(spacing: 5) {
                            Image(systemName: tab.symbol)
                                .font(
                                    .system(
                                        size: 18,
                                        weight: .semibold
                                    )
                                )
    
                            Text(tab.rawValue)
                                .font(
                                    .system(
                                        size: 9,
                                        weight: .semibold
                                    )
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .foregroundStyle(.white)
                        .frame(width: tabWidth, height: 64)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            select(tab)
                        }
                        .simultaneousGesture(
                            DragGesture(
                                minimumDistance: 0,
                                coordinateSpace: .named("flowTabBar")
                            )
                            .onChanged { value in
                                guard abs(value.translation.width) > 6 else {
                                    return
                                }
    
                                dragDidMove = true
    
                                let position =
                                    value.location.x / tabWidth - 0.5
    
                                dragPosition = min(
                                    max(position, 0),
                                    count - 1
                                )
                            }
                            .onEnded { value in
                                if dragDidMove {
                                    let destination = min(
                                        max(
                                            Int(value.location.x / tabWidth),
                                            0
                                        ),
                                        AppTab.allCases.count - 1
                                    )
    
                                    select(AppTab.allCases[destination])
                                } else {
                                    dragPosition = nil
                                }
    
                                dragDidMove = false
                            }
                        )
                        .accessibilityElement()
                        .accessibilityLabel(tab.rawValue)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityAddTraits(
                            selectedTab == tab ? .isSelected : []
                        )
                    }
                }
            }
            .frame(height: 64)
            .contentShape(Capsule())
            .coordinateSpace(name: "flowTabBar")
            .shadow(
                color: .black.opacity(0.25),
                radius: 18,
                y: 7
            )
        }
        .frame(height: 64)
    }
    

    private func select(_ tab: AppTab) {
        if animationsEnabled {
            withAnimation(
                .spring(response: 0.30, dampingFraction: 0.78)
            ) {
                selectedTab = tab
                dragPosition = nil
            }
        } else {
            selectedTab = tab
            dragPosition = nil
        }
    
        dragDidMove = false
    }

}
