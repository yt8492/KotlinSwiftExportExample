import SwiftUI
import Shared
import SharedObjc

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
        let stringList = SharedMappings.makeStringList()
        let scoreMap = SharedMappings.makeScoreMap()
        let tagSet = SharedMappings.makeTagSet()
        let asyncGreeting = await callBlockingGreeting(coroutineMappings)
        let objcCoroutineMappings = SharedObjc.CoroutineMappings()
        let objcApiResult = SharedObjc.MappingsKt.sampleApiResult(success: true)
        let objcDeviceState = SharedObjc.MappingsKt.sampleDeviceState(state: 1)
        let objcSuspendGreeting = try await callObjcSuspendDemo(objcCoroutineMappings)
        let objcStringList = SharedObjc.MappingsKt.makeStringList()
        objcStringList
        let objcScoreMap = SharedObjc.MappingsKt.makeScoreMap()
        let objcTagSet = SharedObjc.MappingsKt.makeTagSet()

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

        let collectionEntries = [
            DemoEntry(title: "makeStringList()", value: describeSwiftList(stringList)),
            DemoEntry(title: "summarizeList([\"delta\", \"echo\"])", value: SharedMappings.summarizeList(values: ["delta", "echo"])),
            DemoEntry(title: "makeScoreMap()", value: describeSwiftMap(scoreMap)),
            DemoEntry(title: "summarizeMap([\"kiwi\": 4, \"melon\": 5])", value: SharedMappings.summarizeMap(values: ["kiwi": 4, "melon": 5])),
            DemoEntry(title: "makeTagSet()", value: describeSwiftSet(tagSet)),
            DemoEntry(title: "summarizeSet([\"ios\", \"kmp\"])", value: SharedMappings.summarizeSet(values: Set(["ios", "kmp"]))),
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

        let objcEntries = [
            DemoEntry(title: "PackageMappingsKt.callMeMaybe()", value: SharedObjc.PackageMappingsKt.callMeMaybe()),
            DemoEntry(title: "PackageMappingsKt.callMeMaybe_()", value: SharedObjc.PackageMappingsKt.callMeMaybe_()),
            DemoEntry(title: "MappingsKt.exportedMessage", value: SharedObjc.MappingsKt.exportedMessage),
            DemoEntry(title: "BuildMetadata.shared.banner()", value: SharedObjc.BuildMetadata.shared.banner()),
            DemoEntry(title: "Person(name:age:).label()", value: SharedObjc.Person(name: "SwiftUI", age: 1).label()),
            DemoEntry(title: "makeStringList()", value: describeObjcList(objcStringList)),
            DemoEntry(title: "makeScoreMap()", value: describeObjcMap(objcScoreMap)),
            DemoEntry(title: "makeTagSet()", value: describeObjcSet(objcTagSet)),
            DemoEntry(title: "if color === .green", value: describeObjcColor(SharedObjc.SampleColor.green)),
            DemoEntry(title: "switch ApiResult by type", value: describeObjcApiResult(objcApiResult)),
            DemoEntry(title: "switch DeviceState by type", value: describeObjcDeviceState(objcDeviceState)),
            DemoEntry(title: "suspend via completionHandler", value: objcSuspendGreeting),
            DemoEntry(title: "blockingGreeting(name:)", value: objcCoroutineMappings.blockingGreeting(name: "Objective-C caller")),
        ]
        SharedMappings.Foo()
        

        return [
            DemoSection(title: "Basic", entries: basicEntries),
            DemoSection(title: "Classes and Functions", entries: classEntries),
            DemoSection(title: "Primitive Mappings", entries: primitiveEntries),
            DemoSection(title: "Collections", entries: collectionEntries),
            DemoSection(title: "Sealed Types", entries: sealedEntries),
            DemoSection(title: "Coroutines", entries: coroutineEntries),
            DemoSection(title: "Objective-C Interop", entries: objcEntries),
        ]
    }

    private func callBlockingGreeting(_ coroutineMappings: SharedMappings.CoroutineMappings) async -> String {
        await Task.detached(priority: .userInitiated) {
            coroutineMappings.blockingGreeting(name: "Swift async caller")
        }.value
    }

    private func callObjcSuspendDemo(_ coroutineMappings: SharedObjc.CoroutineMappings) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            coroutineMappings.delayedGreeting(name: "Objective-C suspend caller") { value, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: value ?? "nil")
            }
        }
    }

    private func describeColorWithSwitch(_ color: SharedMappings.SampleColor) -> String {
        switch color {
        case .RED:
            return "RED -> \(color.rgb)"
        case .GREEN:
            return "GREEN -> \(color.rgb)"
        case .BLUE:
            return "BLUE -> \(color.rgb)"
//        @unknown default:
//            return "unknown enum case"
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

    private func describeSwiftList(_ values: [String]) -> String {
        "Array(count: \(values.count), values: \(values.joined(separator: ", ")))"
    }

    private func describeSwiftMap(_ values: [String: Int32]) -> String {
        let pairs = values.keys.sorted().map { "\($0)=\(values[$0]!)" }.joined(separator: ", ")
        return "Dictionary(count: \(values.count), values: \(pairs))"
    }

    private func describeSwiftSet(_ values: Set<String>) -> String {
        "Set(count: \(values.count), values: \(values.sorted().joined(separator: ", ")))"
    }

    private func describeObjcList(_ values: Any) -> String {
        String(describing: values)
    }

    private func describeObjcMap(_ values: Any) -> String {
        String(describing: values)
    }

    private func describeObjcSet(_ values: Any) -> String {
        String(describing: values)
    }

    private func describeObjcColor(_ color: SharedObjc.SampleColor) -> String {
        if color === SharedObjc.SampleColor.red {
            return "red -> \(color.rgb)"
        }

        if color === SharedObjc.SampleColor.green {
            return "green -> \(color.rgb)"
        }

        if color === SharedObjc.SampleColor.blue {
            return "blue -> \(color.rgb)"
        }

        return "unknown color instance"
    }

    private func describeObjcApiResult(_ result: SharedObjc.ApiResult) -> String {
        switch result {
        case let success as SharedObjc.ApiResult.Success:
            return "Success(message: \(success.message))"
        case let failure as SharedObjc.ApiResult.Failure:
            return "Failure(code: \(failure.code), reason: \(failure.reason))"
        case is SharedObjc.ApiResult.Loading:
            return "Loading"
        default:
            return "Unknown ApiResult subtype"
        }
    }

    private func describeObjcDeviceState(_ state: any SharedObjc.DeviceState) -> String {
        switch state {
        case let online as SharedObjc.DeviceStateOnline:
            return "Online(deviceName: \(online.deviceName))"
        case let offline as SharedObjc.DeviceStateOffline:
            return "Offline(lastSeenMinutesAgo: \(offline.lastSeenMinutesAgo))"
        case is SharedObjc.DeviceStateUnknown:
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
