package com.example.retail_test_task.payment

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext

internal sealed interface PaymentProcessingEvent {
    val reference: String

    data class Progress(
        override val reference: String,
        val percentage: Int,
    ) : PaymentProcessingEvent

    data class Result(
        override val reference: String,
        val outcome: String,
    ) : PaymentProcessingEvent

    data class Failure(
        override val reference: String,
        val message: String,
    ) : PaymentProcessingEvent
}

internal object PaymentProcessingCoordinator {
    private val mutex = Mutex()

    private var activeReference: String? = null
    private var listener: ((PaymentProcessingEvent) -> Unit)? = null

    suspend fun reserve(reference: String): Boolean = mutex.withLock {
        if (activeReference != null) {
            false
        } else {
            activeReference = reference
            true
        }
    }

    suspend fun isReservedFor(reference: String): Boolean = mutex.withLock {
        activeReference == reference
    }

    suspend fun publishProgress(reference: String, percentage: Int) {
        dispatchIfActive(
            reference,
            PaymentProcessingEvent.Progress(reference, percentage),
        )
    }

    suspend fun complete(reference: String, isApproved: Boolean) {
        releaseAndDispatch(
            reference,
            PaymentProcessingEvent.Result(
                reference,
                if (isApproved) SUCCESS_OUTCOME else FAILURE_OUTCOME,
            ),
        )
    }

    suspend fun fail(reference: String, message: String) {
        releaseAndDispatch(
            reference,
            PaymentProcessingEvent.Failure(reference, message),
        )
    }

    suspend fun setListener(newListener: ((PaymentProcessingEvent) -> Unit)?) {
        mutex.withLock {
            listener = newListener
        }
    }

    suspend fun clearListener(expectedListener: (PaymentProcessingEvent) -> Unit) {
        mutex.withLock {
            if (listener === expectedListener) {
                listener = null
            }
        }
    }

    private suspend fun dispatchIfActive(
        reference: String,
        event: PaymentProcessingEvent,
    ) {
        val currentListener = mutex.withLock {
            listener.takeIf { activeReference == reference }
        }
        dispatch(currentListener, event)
    }

    private suspend fun releaseAndDispatch(
        reference: String,
        event: PaymentProcessingEvent,
    ) {
        val currentListener = mutex.withLock {
            if (activeReference != reference) {
                null
            } else {
                activeReference = null
                listener
            }
        }
        dispatch(currentListener, event)
    }

    private suspend fun dispatch(
        currentListener: ((PaymentProcessingEvent) -> Unit)?,
        event: PaymentProcessingEvent,
    ) {
        withContext(Dispatchers.Main.immediate) {
            currentListener?.invoke(event)
        }
    }

    private const val SUCCESS_OUTCOME = "success"
    private const val FAILURE_OUTCOME = "failure"
}
