package com.trieco.project_gbo.models

import java.time.LocalDateTime


data class Notification(
    val orderId: Int,
    val getTime: LocalDateTime,
    var viewed: Boolean = false,
    val text: String = "Новая заявка"
)