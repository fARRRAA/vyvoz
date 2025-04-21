package com.trieco.project_gbo.models

import kotlinx.datetime.LocalDateTime

data class OrderCreationData(
    val address: String,
    val volume: Int,
    val date: LocalDateTime,
    val latitude: Float,
    val longitude: Float,
    val id: Int,
    val municipalityName: String
)
