package com.trieco.project_gbo.models

import kotlinx.serialization.Serializable

@Serializable
data class TreatmentPlant(
    val id: Int,
    val adress: String,
    val latitude: Float,
    val longitude: Float,
    val dailyLimit: Int,
    val name: String = "",
    val tariff: Float = 200f
)
