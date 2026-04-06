# Kotlin Swift Export Example

`shared` モジュールに Kotlin 実装を置き、Swift export で Swift から直接利用するためのサンプルです。Swift 側は `iosApp` の最小 SwiftUI アプリで、Swift から直接触れる API だけを呼び出し、その結果を画面上に表示します。

## 構成

- `shared`: Swift export 対象の Kotlin Multiplatform モジュール
- `iosApp`: `embedSwiftExportForXcode` を使って `Shared` モジュールを取り込む最小 Xcode プロジェクト

## 公式 Mapping の対応

公式ドキュメントの Mapping 表をベースに、次の項目を `shared/src/commonMain/kotlin/com/example/shared/mappings` に配置しています。

| Kotlin の概念 | 実装 |
| --- | --- |
| `class` | `Person`, `PrimitiveMappings`, `CoroutineMappings`, `ConsoleReportBuilder` |
| `object` | `BuildMetadata` |
| `enum class` | `SampleColor` |
| `sealed class` | `ApiResult` |
| `sealed interface` | `DeviceState` |
| `typealias` | `ExportedInt` |
| Function | `addNumbers`, `describe`, `logMessages`, `annotate`, `acceptAny`, `identityAny`, `returnsUnit` |
| Property | `exportedConst`, `exportedMessage`, `exportedCounter`, 各クラスのプロパティ |
| Constructor | `Person(...)`, `PrimitiveMappings(...)` |
| Package | `alpha.callMeMaybe()`, `beta.callMeMaybe()` |
| `Boolean` | `PrimitiveMappings.booleanValue` |
| `Char` | `PrimitiveMappings.charValue` |
| `Byte` | `PrimitiveMappings.byteValue` |
| `Short` | `PrimitiveMappings.shortValue` |
| `Int` | `PrimitiveMappings.intValue` |
| `Long` | `PrimitiveMappings.longValue` |
| `UByte` | `PrimitiveMappings.uByteValue` |
| `UShort` | `PrimitiveMappings.uShortValue` |
| `UInt` | `PrimitiveMappings.uIntValue` |
| `ULong` | `PrimitiveMappings.uLongValue` |
| `Float` | `PrimitiveMappings.floatValue` |
| `Double` | `PrimitiveMappings.doubleValue` |
| `Any` | `acceptAny`, `identityAny` |
| `Unit` | `returnsUnit` |
| `Nothing` | `alwaysFails`, `impossibleInput` |

## Coroutines

Coroutines 系の実装も `CoroutineMappings` に含めています。

- public `suspend fun delayedGreeting(name: String): String`
- internal `fun countdownFlow(start: Int): Flow<Int>`
- internal `fun tickerFlow(prefix: String, count: Int): Flow<String>`
- public `blockingGreeting`, `blockingCountdown`, `blockingTicker`

`shared` モジュール内では `suspend` と `Flow` を実際に使っていますが、2026-04-06 時点では Swift export 側の coroutines / flows サポートがまだ不安定です。そこでこのサンプルでは、Swift から確実にビルド・実行できるよう `runBlocking` ベースの同期ラッパーも併設しています。

## 実行方法

1. Xcode で [iosApp/iosApp.xcodeproj](/Users/yt8492/IdeaProjects/KotlinSwiftExportExample/iosApp/iosApp.xcodeproj) を開きます。
2. `iosApp` ターゲットを選びます。
3. Build Phase の Run Script では、すでに `./gradlew :shared:embedSwiftExportForXcode` を実行する設定にしています。
4. ビルドして起動します。
5. SwiftUI のリスト上に、Swift から直接呼び出した結果が表示されます。

## Swift から直接呼べなかったもの

このサンプルでは、結果の組み立ては Swift 側に寄せています。Kotlin の `ConsoleReportBuilder` は export 自体はされていますが、これを使うと「どの API が Swift から直接触れているのか」が見えにくくなるため、`iosApp` では使っていません。

2026-04-06 時点で、生成された [Shared.swift](/Users/yt8492/IdeaProjects/KotlinSwiftExportExample/shared/build/SPMPackage/iosSimulatorArm64/Debug/Sources/Shared/Shared.swift) を確認した結果、次のものはそのまま SwiftUI サンプルの呼び出し対象にはしていません。

- `suspend fun delayedGreeting(name: String)`  
  Kotlin では public ですが、今回の生成物では Swift から直接 `await` する API として見えていません。そのため Swift 側では `blockingGreeting(...)` を利用しています。
- `Flow` を返す `countdownFlow(start: Int)` と `tickerFlow(prefix: String, count: Int)`  
  これらは internal であり、Swift export の公開 API にも出していません。Swift からは `blockingCountdown(...)` と `blockingTicker(...)` を使います。
- `Nothing` 系の `alwaysFails()` と `impossibleInput(input: Nothing)`  
  export はされますが、前者は呼ぶと必ず失敗し、後者は `Never` 入力が必要なので通常の SwiftUI サンプルでは実用的に呼べません。
- `identityAny(value: Any)`  
  export はされますが、戻り値が `any KotlinRuntimeSupport._KotlinBridgeable` になるため、画面サンプルでの説明価値が低く、UI では採用していません。

## switch / 型チェック

`enum class` は Swift では enum として export されるので、通常の `switch` が使えます。

```swift
switch mappings.SampleColor.GREEN {
case .RED:
    print("red")
case .GREEN:
    print("green")
case .BLUE:
    print("blue")
@unknown default:
    print("unknown")
}
```

`sealed class` と `sealed interface` は、Swift では「sealed なので網羅的に分岐できる型」としては扱われません。`switch` 自体は使えますが、実際には `as` を使った実行時型チェックになります。そのため `default` を残す形になります。

`sealed class ApiResult` の例:

```swift
func describe(_ result: mappings.ApiResult) -> String {
    switch result {
    case let success as mappings.ApiResult.Success:
        return "Success(message: \\(success.message))"
    case let failure as mappings.ApiResult.Failure:
        return "Failure(code: \\(failure.code), reason: \\(failure.reason))"
    case is mappings.ApiResult.Loading:
        return "Loading"
    default:
        return "Unknown ApiResult subtype"
    }
}
```

`sealed interface DeviceState` の例:

```swift
func describe(_ state: any mappings.DeviceState) -> String {
    switch state {
    case let online as Shared._ExportedKotlinPackages_com_example_shared_mappings_DeviceState_Online:
        return "Online(deviceName: \\(online.deviceName))"
    case let offline as Shared._ExportedKotlinPackages_com_example_shared_mappings_DeviceState_Offline:
        return "Offline(lastSeenMinutesAgo: \\(offline.lastSeenMinutesAgo))"
    case is Shared._ExportedKotlinPackages_com_example_shared_mappings_DeviceState_Unknown:
        return "Unknown"
    default:
        return "Unknown DeviceState subtype"
    }
}
```

`sealed interface` は今回の生成物では `mappings.DeviceState.Online` のような別名が `internal` 扱いになっており、そのままは参照できませんでした。そのため Swift 側では生成された具体クラス名で型チェックしています。

実際の呼び出し例は [ContentView.swift](/Users/yt8492/IdeaProjects/KotlinSwiftExportExample/iosApp/iosApp/ContentView.swift) の `Sealed Types` セクションに追加しています。

## 制限メモ

2026-04-06 時点の公式ドキュメントでは、Swift export は Experimental で、`suspend` のサポートは限定的で、coroutines / flows まわりは今後改善予定とされています。そのためこのサンプルでは、`shared` 内部実装に coroutines / `Flow` を含めつつ、Swift から使う exported API は安定側に寄せています。

### 参考

- [Interoperability with Swift using Swift export](https://kotlinlang.org/docs/native-swift-export.html)
- [Kotlin/swift-export-sample](https://github.com/Kotlin/swift-export-sample)
