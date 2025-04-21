package com.trieco.project_gbo.network.http

import kotlinx.serialization.Serializable

@Serializable
data class TokenPair(
    val jwtToken: String,
    val refreshToken: String
)
