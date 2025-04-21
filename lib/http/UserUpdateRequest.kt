package com.trieco.project_gbo.network.http

import kotlinx.serialization.Serializable

@Serializable
data class UserUpdateRequest(
    val id: Int,
    val firstName: String,
    val lastName: String,
    val patronymic: String,
    val email: String,
    val phoneNumber: String,
    val adress: String,
)
