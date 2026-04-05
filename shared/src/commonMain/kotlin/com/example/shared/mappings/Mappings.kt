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

fun returnsUnit(message: String) {
    exportedCounter += message.length
}

fun alwaysFails(): Nothing = error("Nothing mapping sample")

fun impossibleInput(input: Nothing) {
    error("Unreachable: $input")
}
