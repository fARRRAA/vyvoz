package com.trieco.project_gbo.models

import androidx.compose.ui.text.AnnotatedString
import com.trieco.project_gbo.network.http.UserUpdateRequest
import com.trieco.project_gbo.ui.MaskVisualTransformation
import com.trieco.project_gbo.ui.PhoneFormat
import kotlinx.serialization.Serializable

@Serializable

data class User(
    val id: Int = 0,
    val login: String = "",
    var firstName: String = "",
    var lastName: String = "",
    var patronymic: String = "",
    var email: String = "",
    var phoneNumber: String = "",
    var adress: String = "",
    val roleId: Int = 0
) {
    fun toUpdate(): UserUpdateRequest {
        return UserUpdateRequest(id, firstName, lastName, patronymic, email, phoneNumber, adress)
    }
}

val String.formatToRawPhone get() = this.removePrefix("+7").filter { it.isDigit() }
val String.encodeToPhoneFormat
    get() = MaskVisualTransformation(PhoneFormat).filter(
        AnnotatedString(
            this
        )
    ).text.text

val String.encodeToURL
    get() = this.replace("+", "%2B").replace(" ", "%20").replace("(", "%28").replace(")", "%29")