package com.trieco.project_gbo.network.http

import kotlinx.serialization.Serializable

@Serializable
data class WebsocketMessage(
    val guid: String,
    val path: String,
    val data: String,
    val timestamp: Long
)
