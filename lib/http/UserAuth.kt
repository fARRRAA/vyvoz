package com.trieco.project_gbo.network.http

import com.trieco.project_gbo.models.User
import kotlinx.serialization.Serializable

@Serializable
data class UserAuth(
    val id: Int = 0,
    val login: String = "",
    var firstName: String = "",
    var lastName: String = "",
    var patronymic: String = "",
    var email: String = "",
    var phoneNumber: String = "",
    var adress: String = "",
    val roleId: Int = 0,
    val jwtToken: String,
    val refreshToken: String
) {
    fun toUser(): User {
        return User(id, login, firstName, lastName, patronymic, email, phoneNumber, adress, roleId)
    }
}
