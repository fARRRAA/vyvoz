package com.trieco.project_gbo.models

import kotlinx.serialization.Serializable

@Serializable
data class Sewer(
    val id: Int,
    val companyId: Int,
    val sewerNumberPlate: String,
    val sewerCarModel: String,
    val tankVolume: Int,
    val userId: Int
)
