package com.trieco.project_gbo.network.http

import kotlinx.serialization.Serializable

@Serializable
data class MobileLog(val message: String, val userId: Int, val version: Int)
