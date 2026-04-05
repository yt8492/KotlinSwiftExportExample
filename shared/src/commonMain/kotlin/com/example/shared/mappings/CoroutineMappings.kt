package com.example.shared.mappings

import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.runBlocking

class CoroutineMappings {
    suspend fun delayedGreeting(name: String): String {
        delay(50)
        return "Hello, $name"
    }

    fun countdownFlow(start: Int): Flow<Int> = flow {
        for (value in start downTo 1) {
            delay(10)
            emit(value)
        }
    }

    fun tickerFlow(prefix: String, count: Int): Flow<String> = flow {
        repeat(count) { index ->
            delay(10)
            emit("$prefix-${index + 1}")
        }
    }

    fun blockingGreeting(name: String): String = runBlocking {
        delayedGreeting(name)
    }

    fun blockingCountdown(start: Int): String = runBlocking {
        countdownFlow(start).toList().joinToString(prefix = "[", postfix = "]")
    }

    fun blockingTicker(prefix: String, count: Int): String = runBlocking {
        tickerFlow(prefix, count).toList().joinToString(prefix = "[", postfix = "]")
    }
}
