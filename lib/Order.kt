package com.trieco.project_gbo.models

import com.trieco.project_gbo.R
import kotlinx.datetime.toKotlinLocalDateTime
import kotlinx.serialization.Serializable
import java.time.LocalDateTime

@Serializable
data class Order(
    val id: Int = 0,
    var orderStatusId: Int = 1,
    val comment: String? = "",
    val wasteVolume: Int = 0,
    val latitude: Float? = 0f,
    val longitude: Float? = 0f,
    val userId: Int? = 4,
    var sewerId: Int? = 1,
    val timeOfPublication: kotlinx.datetime.LocalDateTime? = LocalDateTime.now()
        .toKotlinLocalDateTime(),
    val adress: String = "",
    val arrivalStartDate: kotlinx.datetime.LocalDateTime? = LocalDateTime.now()
        .toKotlinLocalDateTime(),
    val arrivalEndDate: kotlinx.datetime.LocalDateTime? = LocalDateTime.now()
        .toKotlinLocalDateTime(),
    val userFirstName: String = "",
    val userLastName: String = "",
    val userPatronymic: String = "",
    val sewerFirstName: String? = "",
    val sewerLastName: String? = "",
    val sewerPatronymic: String? = "",
    val userPhone: String = "",
    val firstName: String? = null,
    val lastName: String? = null,
    val patronymic: String? = null,
    val phoneNumber: String? = null,
    val completionDate: kotlinx.datetime.LocalDateTime? = null,
    val municipalityId: Int = 1,
    var updatedAt: kotlinx.datetime.LocalDateTime? = LocalDateTime.now().toKotlinLocalDateTime(),
    var selfCreated: Boolean = false,
    var isPayed: Boolean = true,
    val confirmCode: String = ""
) {
    companion object {
        val stageToString: Map<Int, String> = mapOf(
            1 to "Новый",
            2 to "Транспортировка",
            3 to "Утилизация",
            4 to "Выполнена",
            5 to "Отменена",
            6 to "Принятый",
        )

        val stageToColorId: Map<Int, Int> = mapOf(
            1 to R.color.orderNew,
            2 to R.color.orderTransport,
            3 to R.color.orderUtilization,
            4 to R.color.orderDone,
            5 to R.color.orderCanceled,
            6 to R.color.orderAccepted
        )
    }

    fun getPeriod(): String {
        return "${arrivalStartDate!!.hour}:${if (arrivalStartDate.minute >= 10) arrivalStartDate.minute else "0" + arrivalStartDate.minute.toString()}-${arrivalEndDate!!.hour}:${if (arrivalEndDate.minute >= 10) arrivalEndDate.minute else "0" + arrivalEndDate.minute.toString()}"
    }
}

enum class OrderStatus(val id: Int) {
    New(1), Attached(6), Transport(2), Utilization(3), Done(4), Canceled(5)
}