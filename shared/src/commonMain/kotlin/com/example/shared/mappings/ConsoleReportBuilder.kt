package com.example.shared.mappings

import com.example.shared.alpha.callMeMaybe
import com.example.shared.beta.callMeMaybe as callMeMaybeBeta

class ConsoleReportBuilder {
    fun build(): String {
        val aliasValue: ExportedInt = 42
        val person = Person(name = "Swift", age = 12)
        val primitives = makePrimitiveMappings()
        val coroutines = CoroutineMappings()

        returnsUnit("unit-call")
        val anyValue = identityAny(person)

        return buildString {
            appendLine("== Declarations ==")
            appendLine("class -> ${person.label()} / nickname=${person.nickname}")
            appendLine("object -> ${BuildMetadata.banner()}")
            appendLine("enum -> ${SampleColor.GREEN} rgb=${SampleColor.GREEN.rgb}")
            appendLine("typealias -> $aliasValue")
            appendLine("function -> addNumbers=${addNumbers(a = 4, b = 3)}")
            appendLine("overload(Int) -> ${describe(10)}")
            appendLine("overload(String) -> ${describe("swift-export")}")
            appendLine("extension -> ${7.annotate(prefix = "sample")}")
            appendLine("vararg -> ${logMessages("one", "two", "three")}")
            appendLine("property const -> $exportedConst")
            appendLine("property val -> $exportedMessage")
            appendLine("property var -> ${mutateCounter(5)}")
            appendLine("constructor -> ${Person(name = "Constructor", age = 5).label()}")
            appendLine("package alpha -> ${callMeMaybe()}")
            appendLine("package beta -> ${callMeMaybeBeta()}")
            appendLine("Any -> ${acceptAny(anyValue)}")
            appendLine("Unit -> counter=$exportedCounter")
            appendLine("Nothing -> alwaysFails() is declared but intentionally not invoked")
            appendLine()
            appendLine("== Primitive Mappings ==")
            appendLine(primitives.summary())
            appendLine()
            appendLine("== Coroutines ==")
            appendLine("suspend -> ${coroutines.blockingGreeting("Swift")}")
            appendLine("Flow<Int> -> ${coroutines.blockingCountdown(3)}")
            appendLine("Flow<String> -> ${coroutines.blockingTicker("tick", 3)}")
            appendLine(coroutines.describeCoroutineUsage())
        }
    }
}
