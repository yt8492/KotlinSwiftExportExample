import SwiftUI
import Shared

private struct DemoEntry: Identifiable {
    let id = UUID()
    let title: String
    let value: String
}

private struct DemoSection: Identifiable {
    let id = UUID()
    let title: String
    let entries: [DemoEntry]
}

struct ContentView: View {
    @State private var sections: [DemoSection] = []
    @State private var loadError: String?
    @State private var hasLoaded = false

    typealias SharedMappings = mappings

    var body: some View {
        NavigationView {
            List {
                if let loadError {
                    Section("Load Error") {
                        Text(loadError)
                            .foregroundStyle(.red)
                    }
                }

                ForEach(sections) { section in
                    Section(section.title) {
                        ForEach(section.entries) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.title)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(entry.value)
                                    .font(.body.monospaced())
                                    .textSelection(.enabled)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Swift Export Demo")
            .overlay {
                if sections.isEmpty && loadError == nil {
                    ProgressView()
                }
            }
        }
        .task {
            guard !hasLoaded else { return }
            hasLoaded = true

            do {
                sections = try await buildSections()
            } catch {
                loadError = String(describing: error)
            }
        }
    }

    private func buildSections() async throws -> [DemoSection] {
        let person = SharedMappings.Person(name: "SwiftUI", age: 1)
        let primitiveMappings = SharedMappings.makePrimitiveMappings()
        let coroutineMappings = SharedMappings.CoroutineMappings()
        let apiResult = SharedMappings.sampleApiResult(success: true)
        let deviceState = SharedMappings.sampleDeviceState(state: 1)
        let asyncGreeting = await callBlockingGreeting(coroutineMappings)

        SharedMappings.returnsUnit(message: "swiftui")

        let basicEntries = [
            DemoEntry(title: "alpha.callMeMaybe()", value: alpha.callMeMaybe()),
            DemoEntry(title: "beta.callMeMaybe()", value: beta.callMeMaybe()),
            DemoEntry(title: "exportedConst", value: String(SharedMappings.exportedConst)),
            DemoEntry(title: "exportedMessage", value: SharedMappings.exportedMessage),
            DemoEntry(title: "exportedCounter (before mutate)", value: String(SharedMappings.exportedCounter)),
            DemoEntry(title: "mutateCounter(3)", value: String(SharedMappings.mutateCounter(increment: 3))),
            DemoEntry(title: "exportedCounter (after mutate)", value: String(SharedMappings.exportedCounter)),
            DemoEntry(title: "BuildMetadata.shared.banner()", value: SharedMappings.BuildMetadata.shared.banner()),
            DemoEntry(title: "SampleColor.GREEN.rgb", value: String(SharedMappings.SampleColor.GREEN.rgb)),
        ]

        let classEntries = [
            DemoEntry(title: "Person.label()", value: person.label()),
            DemoEntry(title: "Person.nickname", value: person.nickname),
            DemoEntry(title: "describe(42)", value: SharedMappings.describe(value: 42)),
            DemoEntry(title: "describe(\"hello\")", value: SharedMappings.describe(value: "hello")),
            DemoEntry(title: "addNumbers(2, 3)", value: String(SharedMappings.addNumbers(a: 2, b: 3))),
            DemoEntry(title: "annotate(42, prefix: \"swift\")", value: SharedMappings.annotate(42, prefix: "swift")),
            DemoEntry(title: "logMessages(...)", value: SharedMappings.logMessages(messages: "one", "two", "three")),
            DemoEntry(title: "acceptAny(Person)", value: SharedMappings.acceptAny(value: person)),
        ]

        let primitiveEntries = [
            DemoEntry(title: "PrimitiveMappings.summary()", value: primitiveMappings.summary()),
            DemoEntry(title: "PrimitiveMappings.booleanValue", value: String(primitiveMappings.booleanValue)),
            DemoEntry(title: "PrimitiveMappings.charValue", value: String(primitiveMappings.charValue)),
            DemoEntry(title: "PrimitiveMappings.uLongValue", value: String(primitiveMappings.uLongValue)),
            DemoEntry(title: "PrimitiveMappings.optionalLong", value: String(describing: primitiveMappings.optionalLong)),
        ]

        let sealedEntries = [
            DemoEntry(title: "describeApiResult(sampleApiResult(true))", value: SharedMappings.describeApiResult(result: apiResult)),
            DemoEntry(title: "describeDeviceState(sampleDeviceState(1))", value: SharedMappings.describeDeviceState(state: deviceState)),
            DemoEntry(title: "switch SampleColor.GREEN", value: describeColorWithSwitch(.GREEN)),
            DemoEntry(title: "switch ApiResult by type", value: describeApiResultWithTypeSwitch(apiResult)),
            DemoEntry(title: "switch DeviceState by type", value: describeDeviceStateWithTypeSwitch(deviceState)),
        ]

        let coroutineEntries = [
            DemoEntry(title: "describeCoroutineUsage()", value: coroutineMappings.describeCoroutineUsage()),
            DemoEntry(title: "blockingGreeting(\"Swift caller\")", value: coroutineMappings.blockingGreeting(name: "Swift caller")),
            DemoEntry(title: "blockingCountdown(3)", value: coroutineMappings.blockingCountdown(start: 3)),
            DemoEntry(title: "blockingTicker(\"tick\", 3)", value: coroutineMappings.blockingTicker(prefix: "tick", count: 3)),
            DemoEntry(title: "Task.detached + blockingGreeting(...)", value: asyncGreeting),
        ]

        return [
            DemoSection(title: "Basic", entries: basicEntries),
            DemoSection(title: "Classes and Functions", entries: classEntries),
            DemoSection(title: "Primitive Mappings", entries: primitiveEntries),
            DemoSection(title: "Sealed Types", entries: sealedEntries),
            DemoSection(title: "Coroutines", entries: coroutineEntries),
        ]
    }

    private func callBlockingGreeting(_ coroutineMappings: SharedMappings.CoroutineMappings) async -> String {
        await Task.detached(priority: .userInitiated) {
            coroutineMappings.blockingGreeting(name: "Swift async caller")
        }.value
    }

    private func describeColorWithSwitch(_ color: SharedMappings.SampleColor) -> String {
        switch color {
        case .RED:
            return "RED -> \(color.rgb)"
        case .GREEN:
            return "GREEN -> \(color.rgb)"
        case .BLUE:
            return "BLUE -> \(color.rgb)"
        @unknown default:
            return "unknown enum case"
        }
    }

    private func describeApiResultWithTypeSwitch(_ result: SharedMappings.ApiResult) -> String {
        switch result {
        case let success as SharedMappings.ApiResult.Success:
            return "Success(message: \(success.message))"
        case let failure as SharedMappings.ApiResult.Failure:
            return "Failure(code: \(failure.code), reason: \(failure.reason))"
        case is SharedMappings.ApiResult.Loading:
            return "Loading"
        default:
            return "Unknown ApiResult subtype"
        }
    }

    private func describeDeviceStateWithTypeSwitch(_ state: any SharedMappings.DeviceState) -> String {
        switch state {
        case let online as Shared._ExportedKotlinPackages_com_example_shared_mappings_DeviceState_Online:
            return "Online(deviceName: \(online.deviceName))"
        case let offline as Shared._ExportedKotlinPackages_com_example_shared_mappings_DeviceState_Offline:
            return "Offline(lastSeenMinutesAgo: \(offline.lastSeenMinutesAgo))"
        case is Shared._ExportedKotlinPackages_com_example_shared_mappings_DeviceState_Unknown:
            return "Unknown"
        default:
            return "Unknown DeviceState subtype"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
