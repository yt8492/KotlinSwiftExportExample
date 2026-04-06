import SwiftUI
import Shared

struct ContentView: View {
    @State private var didPrint = false
    typealias SharedMappings = mappings

    var body: some View {
        VStack(spacing: 16) {
            Text("Kotlin Swift Export Example")
                .font(.headline)
            Text("Build and open the Xcode debug console to see Kotlin output.")
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
        .task {
            guard !didPrint else { return }
            didPrint = true

            let reportBuilder = SharedMappings.ConsoleReportBuilder()
            let report = reportBuilder.build()
            let person = SharedMappings.Person(name: "SwiftUI", age: 1)
            let metadata = SharedMappings.BuildMetadata.shared
            let coroutineMappings = SharedMappings.CoroutineMappings()
            let suspendLikeResult = await callSuspendDemo(coroutineMappings)

            print("----- Kotlin Swift Export Report -----")
            print(report)
            print("----- Direct Swift Calls -----")
            print("Person -> \(person.label())")
            print("Object -> \(metadata.banner())")
            print("Suspend wrapper -> \(suspendLikeResult)")
        }
    }

    private func callSuspendDemo(_ coroutineMappings: SharedMappings.CoroutineMappings) async -> String {
        await Task.detached(priority: .userInitiated) {
            coroutineMappings.blockingGreeting(name: "Swift async caller")
        }.value
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
