package com.trieco.project_gbo.network.http

import kotlinx.serialization.Serializable

@Serializable
data class SendPositionCommand(
    val command_type: String,
    val sewer_id: Int,
    val user_id: Int,
    val latitude: Float,
    val longitude: Float
)
