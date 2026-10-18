
import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue,
                    Color.purple,
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48))

                Text("Liquid Glass")
                    .font(.largeTitle.bold())

                Text("La mia app di prova")
                    .font(.headline)

                Button {
                    print("Pulsante Liquid Glass premuto")
                } label: {
                    Label("Prova l'effetto", systemImage: "hand.tap")
                        .padding()
                }
                .glassEffect(.regular.interactive())

                Text("Effetto originale di SwiftUI")
                    .font(.caption)
            }
            .foregroundStyle(.white)
            .padding(32)
            .glassEffect()
        }
    }
}
