package com.example.shared.mappings

typealias ExportedInt = Int

const val exportedConst: Int = 7

val exportedMessage: String = "Hello from Kotlin"

var exportedCounter: Int = 0

enum class SampleColor(val rgb: Int) {
    RED(0xFF0000),
    GREEN(0x00FF00),
    BLUE(0x0000FF),
}

object BuildMetadata {
    val version: String = "1.0.0"
    val owner: String = "shared"

    fun banner(): String = "BuildMetadata(version=$version, owner=$owner)"
}

sealed class ApiResult {
    data class Success(val message: String) : ApiResult()

    data class Failure(val code: Int, val reason: String) : ApiResult()

    data object Loading : ApiResult()
}

sealed interface DeviceState {
    val label: String

    data class Online(val deviceName: String) : DeviceState {
        override val label: String = "online:$deviceName"
    }

    data class Offline(val lastSeenMinutesAgo: Int) : DeviceState {
        override val label: String = "offline:${lastSeenMinutesAgo}m"
    }

    data object Unknown : DeviceState {
        override val label: String = "unknown"
    }
}

class PrimitiveMappings(
    val booleanValue: Boolean,
    val charValue: Char,
    val byteValue: Byte,
    val shortValue: Short,
    val intValue: Int,
    val longValue: Long,
    val uByteValue: UByte,
    val uShortValue: UShort,
    val uIntValue: UInt,
    val uLongValue: ULong,
    val floatValue: Float,
    val doubleValue: Double,
    val optionalBoolean: Boolean?,
    val optionalInt: Int?,
    val optionalLong: Long?,
) {
    fun summary(): String =
        buildString {
            appendLine("Boolean -> $booleanValue")
            appendLine("Char -> ${charValue.code}")
            appendLine("Byte -> $byteValue")
            appendLine("Short -> $shortValue")
            appendLine("Int -> $intValue")
            appendLine("Long -> $longValue")
            appendLine("UByte -> $uByteValue")
            appendLine("UShort -> $uShortValue")
            appendLine("UInt -> $uIntValue")
            appendLine("ULong -> $uLongValue")
            appendLine("Float -> $floatValue")
            appendLine("Double -> $doubleValue")
            appendLine("Boolean? -> $optionalBoolean")
            appendLine("Int? -> $optionalInt")
            append("Long? -> $optionalLong")
        }
}

class Person(val name: String, var age: Int) {
    val nickname: String = name.uppercase()

    fun label(): String = "$name($age)"
}

fun makePrimitiveMappings(): PrimitiveMappings =
    PrimitiveMappings(
        booleanValue = true,
        charValue = 'K',
        byteValue = 1,
        shortValue = 2,
        intValue = 3,
        longValue = 4L,
        uByteValue = 5u,
        uShortValue = 6u,
        uIntValue = 7u,
        uLongValue = 8uL,
        floatValue = 9.5f,
        doubleValue = 10.25,
        optionalBoolean = false,
        optionalInt = 11,
        optionalLong = null,
    )

fun addNumbers(a: Short, b: Byte): Long = a.toLong() + b.toLong()

fun describe(value: Int): String = "Int($value)"

fun describe(value: String): String = "String($value)"

fun logMessages(vararg messages: String): String = messages.joinToString(separator = " | ")

fun Int.annotate(prefix: String): String = "$prefix:$this"

fun mutateCounter(increment: Int): Int {
    exportedCounter += increment
    return exportedCounter
}

fun acceptAny(value: Any): String = "${value::class.simpleName}:$value"

fun identityAny(value: Any): Any = value

fun makeStringList(): List<String> = listOf("alpha", "beta", "gamma")

fun summarizeList(values: List<String>): String =
    "List(size=${values.size}, values=${values.joinToString(separator = ", ")})"

fun makeScoreMap(): Map<String, Int> = linkedMapOf("apple" to 1, "banana" to 2, "citrus" to 3)

fun summarizeMap(values: Map<String, Int>): String =
    values.entries.joinToString(prefix = "Map(", postfix = ")") { "${it.key}=${it.value}" }

fun makeTagSet(): Set<String> = linkedSetOf("kotlin", "swift", "interop")

fun summarizeSet(values: Set<String>): String =
    "Set(size=${values.size}, values=${values.sorted().joinToString(separator = ", ")})"

fun returnsUnit(message: String) {
    exportedCounter += message.length
}

fun sampleApiResult(success: Boolean): ApiResult =
    if (success) {
        ApiResult.Success(message = "export ok")
    } else {
        ApiResult.Failure(code = 500, reason = "sample failure")
    }

fun sampleDeviceState(state: Int): DeviceState =
    when (state) {
        0 -> DeviceState.Unknown
        1 -> DeviceState.Online(deviceName = "iPhone")
        else -> DeviceState.Offline(lastSeenMinutesAgo = 15)
    }

fun describeApiResult(result: ApiResult): String =
    when (result) {
        is ApiResult.Success -> "Success(message=${result.message})"
        is ApiResult.Failure -> "Failure(code=${result.code}, reason=${result.reason})"
        ApiResult.Loading -> "Loading"
    }

fun describeDeviceState(state: DeviceState): String =
    when (state) {
        is DeviceState.Online -> "Online(deviceName=${state.deviceName})"
        is DeviceState.Offline -> "Offline(lastSeenMinutesAgo=${state.lastSeenMinutesAgo})"
        DeviceState.Unknown -> "Unknown"
    }

fun alwaysFails(): Nothing = error("Nothing mapping sample")

fun impossibleInput(input: Nothing) {
    error("Unreachable: $input")
}

open class Foog
