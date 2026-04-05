import SwiftUI
import Shared

struct ContentView: View {
    @State private var didPrint = false

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

            let report = ConsoleReportBuilder().build()
            let person = Person(name: "SwiftUI", age: 1)

            print("----- Kotlin Swift Export Report -----")
            print(report)
            print("----- Direct Swift Calls -----")
            print("Person -> \(person.label())")
            print("Object -> \(BuildMetadata.shared.banner())")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
