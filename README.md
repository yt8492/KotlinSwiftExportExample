# Kotlin Swift Export Example

`shared` モジュールに Kotlin 実装を置き、Swift export で Swift から直接利用するためのサンプルです。Swift 側は `iosApp` の最小 SwiftUI アプリで、起動時に Kotlin API を呼んで Xcode のデバッグコンソールへ `print` します。

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

Coroutines 系の API も `CoroutineMappings` に含めています。

- `suspend fun delayedGreeting(name: String): String`
- `fun countdownFlow(start: Int): Flow<Int>`
- `fun tickerFlow(prefix: String, count: Int): Flow<String>`

Swift 側のサンプルでは追いやすさを優先して、上記の生 API に加えて `runBlocking` ベースの同期ラッパーも利用しています。

## 実行方法

1. Xcode で [iosApp/iosApp.xcodeproj](/Users/yt8492/IdeaProjects/KotlinSwiftExportExample/iosApp/iosApp.xcodeproj) を開きます。
2. `iosApp` ターゲットを選びます。
3. Build Phase の Run Script では、すでに `./gradlew :shared:embedSwiftExportForXcode` を実行する設定にしています。
4. ビルドして起動します。
5. Xcode の Debug Console に Kotlin 側の結果が出力されます。

## 制限メモ

2026-04-02 時点の公式ドキュメントでは、Swift export は Experimental で、`suspend` / `inline` / `operator` のサポートはまだ限定的です。そのためこのサンプルでは生の coroutine API を残しつつ、Swift から確実に追えるよう同期ラッパーも併設しています。

### 参考

- [Interoperability with Swift using Swift export](https://kotlinlang.org/docs/native-swift-export.html)
- [Kotlin/swift-export-sample](https://github.com/Kotlin/swift-export-sample)
