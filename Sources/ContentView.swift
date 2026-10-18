
import SwiftUI
import Combine

enum AppTab: String, CaseIterable {
    case tasks = "Attività"
    case notes = "Note"
    case focus = "Focus"
    case summary = "Riepilogo"

    var symbol: String {
        switch self {
        case .tasks: return "checkmark.circle.fill"
        case .notes: return "note.text"
        case .focus: return "timer"
        case .summary: return "chart.bar.fill"
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

    @State private var selectedTab: AppTab = .tasks
    @State private var newTask = ""

    @State private var remainingSeconds = 25 * 60
    @State private var timerRunning = false

    @State private var dragOffset: CGFloat = 0

    private let clock = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    private var tasks: [TodoItem] {
        guard let data = tasksJSON.data(using: .utf8),
              let result = try? JSONDecoder().decode(
                [TodoItem].self,
                from: data
              ) else {
            return []
        }
        return result
    }

    private var selectedIndex: Int {
        AppTab.allCases.firstIndex(of: selectedTab) ?? 0
    }

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                Group {
                    switch selectedTab {
                    case .tasks:
                        tasksView
                    case .notes:
                        notesView
                    case .focus:
                        focusView
                    case .summary:
                        summaryView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .id(selectedTab)
                .transition(.opacity)
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 5)
                .background {
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.black.opacity(0.12)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .bottom)
                }
        }
        .preferredColorScheme(.dark)
        .onReceive(clock) { _ in
            guard timerRunning else { return }

            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                timerRunning = false
            }
        }
    }

    // MARK: Background

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.12, blue: 0.35),
                    Color(red: 0.28, green: 0.10, blue: 0.52),
                    Color(red: 0.07, green: 0.06, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.blue.opacity(0.30))
                .frame(width: 240, height: 240)
                .blur(radius: 80)
                .offset(x: -130, y: -250)

            Circle()
                .fill(.purple.opacity(0.30))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(x: 140, y: 180)
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("FLOW")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(4)
                    .foregroundStyle(.white.opacity(0.55))

                Text(selectedTab.rawValue)
                    .font(.system(size: 32, weight: .bold))
                    .contentTransition(.numericText())
            }

            Spacer()

            Image(systemName: selectedTab.symbol)
                .font(.system(size: 22, weight: .semibold))
                .frame(width: 52, height: 52)
                .glassEffect(.regular, in: Circle())
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 18)
    }

    // MARK: Tasks

    private var tasksView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    statCard(
                        title: "Da fare",
                        value: "\(tasks.filter { !$0.completed }.count)",
                        icon: "circle"
                    )

                    statCard(
                        title: "Completate",
                        value: "\(tasks.filter { $0.completed }.count)",
                        icon: "checkmark.circle"
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
                                .font(.system(size: 18, weight: .bold))
                                .frame(width: 50, height: 50)
                                .glassEffect(
                                    .regular.interactive(),
                                    in: Circle()
                                )
                        }
                        .disabled(newTask.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("La tua lista")
                        .font(.headline)

                    if tasks.isEmpty {
                        emptyState(
                            icon: "checkmark.circle",
                            title: "Tutto da organizzare",
                            subtitle: "Aggiungi la tua prima attività."
                        )
                    } else {
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
                                        task.completed
                                        ? .green
                                        : .white.opacity(0.65)
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
                                    deleteTask(task)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(16)
                            .background(
                                .white.opacity(0.065),
                                in: RoundedRectangle(cornerRadius: 20)
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 20)
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

    private func deleteTask(_ task: TodoItem) {
        saveTasks(tasks.filter { $0.id != task.id })
    }

    private func saveTasks(_ items: [TodoItem]) {
        guard let data = try? JSONEncoder().encode(items),
              let string = String(data: data, encoding: .utf8) else {
            return
        }

        tasksJSON = string
    }

    // MARK: Notes

    private var notesView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Il tuo spazio personale")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.65))

            TextEditor(text: $notes)
                .scrollContentBackground(.hidden)
                .font(.system(size: 17))
                .foregroundStyle(.white)
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    .white.opacity(0.07),
                    in: RoundedRectangle(cornerRadius: 26)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 26)
                        .strokeBorder(.white.opacity(0.10))
                        .allowsHitTesting(false)
                }

            HStack {
                Image(systemName: "checkmark.icloud")
                Text("Gli appunti vengono salvati automaticamente")
            }
            .font(.caption)
            .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 18)
    }

    // MARK: Focus timer

    private var focusView: some View {
        ScrollView {
            VStack(spacing: 28) {
                Text("Prenditi un momento per concentrarti.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)

                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.09), lineWidth: 12)

                    Circle()
                        .trim(
                            from: 0,
                            to: max(
                                0,
                                min(1, Double(remainingSeconds) / 1500)
                            )
                        )
                        .stroke(
                            AngularGradient(
                                colors: [.cyan, .purple, .pink],
                                center: .center
                            ),
                            style: StrokeStyle(
                                lineWidth: 12,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 8) {
                        Text(timeString)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .monospacedDigit()

                        Text(timerRunning ? "CONCENTRAZIONE" : "TEMPO DI FOCUS")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .frame(width: 255, height: 255)
                .padding(.vertical, 12)

                HStack(spacing: 14) {
                    Button {
                        timerRunning.toggle()
                    } label: {
                        Label(
                            timerRunning ? "Pausa" : "Inizia",
                            systemImage: timerRunning ? "pause.fill" : "play.fill"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(17)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(
                        .regular.interactive(),
                        in: Capsule()
                    )

                    Button {
                        timerRunning = false
                        remainingSeconds = 25 * 60
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.headline)
                            .frame(width: 58, height: 58)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular, in: Circle())
                }

                Text("25 minuti di lavoro, poi prenditi una pausa.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(.white)
            .padding(24)
            .padding(.bottom, 18)
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

    // MARK: Summary

    private var summaryView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Ecco come procede la tua giornata.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))

                statCard(
                    title: "Attività totali",
                    value: "\(tasks.count)",
                    icon: "list.bullet"
                )

                statCard(
                    title: "Completate",
                    value: "\(tasks.filter { $0.completed }.count)",
                    icon: "checkmark.circle.fill"
                )

                statCard(
                    title: "Ancora da fare",
                    value: "\(tasks.filter { !$0.completed }.count)",
                    icon: "hourglass"
                )

                if tasks.contains(where: { $0.completed }) {
                    Button {
                        saveTasks(tasks.filter { !$0.completed })
                    } label: {
                        Label(
                            "Elimina le attività completate",
                            systemImage: "trash"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(17)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(
                        .regular.interactive(),
                        in: Capsule()
                    )
                }

                if tasks.isEmpty {
                    emptyState(
                        icon: "chart.bar",
                        title: "Ancora nessun dato",
                        subtitle: "Le tue statistiche appariranno qui."
                    )
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: Reusable components

    private func statCard(
        title: String,
        value: String,
        icon: String
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 23))
                .frame(width: 48, height: 48)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))

                Text(value)
                    .font(.system(size: 27, weight: .bold))
            }

            Spacer()
        }
        .foregroundStyle(.white)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            .white.opacity(0.055),
            in: RoundedRectangle(cornerRadius: 24)
        )
    }

    private func emptyState(
        icon: String,
        title: String,
        subtitle: String
    ) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.7))

            Text(title)
                .font(.headline)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .padding(.horizontal, 16)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 26))
    }

    // MARK: Draggable Liquid Glass navigation

    private var bottomBar: some View {
        GeometryReader { geometry in
            let count = CGFloat(AppTab.allCases.count)
            let tabWidth = geometry.size.width / count

            let visualIndex = min(
                max(
                    CGFloat(selectedIndex) + dragOffset / tabWidth,
                    0
                ),
                count - 1
            )

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                .white.opacity(0.16),
                                lineWidth: 1
                            )
                    }
                    .glassEffect(.regular, in: Capsule())

                Capsule()
                    .fill(.clear)
                    .frame(width: tabWidth - 6, height: 58)
                    .glassEffect(
                        .regular.interactive(),
                        in: Capsule()
                    )
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                .white.opacity(0.22),
                                lineWidth: 1
                            )
                    }
                    .offset(x: visualIndex * tabWidth + 3)
                    .allowsHitTesting(false)

                HStack(spacing: 0) {
                    ForEach(AppTab.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(
                                .spring(
                                    response: 0.32,
                                    dampingFraction: 0.78
                                )
                            ) {
                                selectedTab = tab
                                dragOffset = 0
                            }
                        } label: {
                            VStack(spacing: 5) {
                                Image(systemName: tab.symbol)
                                    .font(.system(size: 19, weight: .semibold))

                                Text(tab.rawValue)
                                    .font(.system(size: 10, weight: .semibold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                            }
                            .foregroundStyle(.white)
                            .frame(width: tabWidth, height: 64)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(height: 64)
            .contentShape(Capsule())
            .gesture(
                DragGesture(minimumDistance: 8)
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let destination = min(
                            max(
                                CGFloat(selectedIndex)
                                + value.translation.width / tabWidth,
                                0
                            ),
                            count - 1
                        )

                        let newIndex = Int(destination.rounded())
                        let newTab = AppTab.allCases[newIndex]

                        withAnimation(
                            .spring(
                                response: 0.32,
                                dampingFraction: 0.78
                            )
                        ) {
                            selectedTab = newTab
                            dragOffset = 0
                        }
                    }
            )
            .shadow(
                color: .black.opacity(0.25),
                radius: 18,
                y: 7
            )
        }
        .frame(height: 64)
    }
}
