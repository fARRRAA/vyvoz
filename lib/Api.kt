package com.trieco.project_gbo.network

import android.annotation.SuppressLint
import android.content.SharedPreferences
import android.util.Log
import com.trieco.project_gbo.models.Order
import com.trieco.project_gbo.models.OrderStatus
import com.trieco.project_gbo.models.Sewer
import com.trieco.project_gbo.models.TreatmentPlant
import com.trieco.project_gbo.models.User
import com.trieco.project_gbo.network.http.AddressSuggest
import com.trieco.project_gbo.network.http.MobileLog
import com.trieco.project_gbo.network.http.TokenPair
import com.trieco.project_gbo.network.http.TotalAddressSuggest
import com.trieco.project_gbo.network.http.UserAuth
import com.trieco.project_gbo.ui.lastOrder
import com.trieco.project_gbo.ui.refreshOrders
import io.ktor.client.HttpClient
import io.ktor.client.engine.android.Android
import io.ktor.client.request.bearerAuth
import io.ktor.client.request.get
import io.ktor.client.request.post
import io.ktor.client.request.put
import io.ktor.client.request.setBody
import io.ktor.client.statement.bodyAsText
import io.ktor.http.ContentType
import io.ktor.http.HttpStatusCode
import io.ktor.http.contentType
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.json.JSONObject
import java.security.SecureRandom
import java.security.cert.X509Certificate
import java.time.LocalDateTime
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter
import javax.net.ssl.HostnameVerifier
import javax.net.ssl.SSLContext
import javax.net.ssl.X509TrustManager

@SuppressLint("CustomX509TrustManager")
class AllCertsTrustManager : X509TrustManager {

    @SuppressLint("TrustAllX509TrustManager")
    override fun checkClientTrusted(
        chain: Array<out X509Certificate>?,
        authType: String?
    ) {
    }

    @SuppressLint("TrustAllX509TrustManager")
    override fun checkServerTrusted(
        chain: Array<out X509Certificate>?,
        authType: String?
    ) {
    }

    override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()

}

object Api {
    lateinit var preferences: SharedPreferences
    val Parser = Json { coerceInputValues = true; ignoreUnknownKeys = true; }
    var AttachedOrders = mutableListOf<Order>()
    val httpClient = HttpClient(Android) {
        engine {
            sslManager = { httpsURLConnection ->
                httpsURLConnection.hostnameVerifier = HostnameVerifier { _, _ -> true }
                httpsURLConnection.sslSocketFactory = SSLContext.getInstance("TLS")
                    .apply {
                        init(null, arrayOf(AllCertsTrustManager()), SecureRandom())
                    }.socketFactory
            }
        }
    }


    var onReauth: () -> Unit = {}

    val Route: List<Order> get() = AttachedOrders.filter { it.orderStatusId == OrderStatus.Utilization.id }

    const val NOTIFICATION_PATH = "wss://triapi.ru/socket/notifications"
    const val REST_API_PATH = "https://triapi.ru/api/"
    var NotificationsChanel: NotificationSockets? = null
    var FreeOrders = mutableListOf<Order>()
    var User: User = User()
    var TreatmentPlants = listOf<TreatmentPlant>()
    lateinit var Sewer: Sewer

    private const val REFRESH = "refresh"
    private const val TOKEN_START = "start"
//    private const val JWT_LIFETIME = 60

    private const val JWT_LIFETIME = 60 * 60

    //    private const val REFRESH_LIFETIME = 90
    private const val REFRESH_LIFETIME = 60 * 60 * 24 * 30

    private var currentJWT: String = ""

    val currentWasteVolume: Int
        get() = AttachedOrders.filter { it.orderStatusId == OrderStatus.Transport.id || it.orderStatusId == OrderStatus.Utilization.id }
            .sumOf { it.wasteVolume }

    private fun saveAuthorization(jwt: String, refresh: String) {
        val editor = preferences.edit()

        currentJWT = jwt

        editor.putString(REFRESH, refresh)
        editor.putLong(TOKEN_START, LocalDateTime.now().toEpochSecond(ZoneOffset.ofHours(3)))
        editor.apply()
    }

    fun isReloginRequested(): Boolean {
        var start = preferences.getLong(TOKEN_START, 0)
        val now = LocalDateTime.now().toEpochSecond(ZoneOffset.ofHours(3))

        return start + REFRESH_LIFETIME < now
    }

    private suspend fun tryUpdateAuth() {
        val now = LocalDateTime.now().toEpochSecond(ZoneOffset.ofHours(3))
        val tokensStart = preferences.getLong(TOKEN_START, 0)

        if (tokensStart + JWT_LIFETIME > now && currentJWT != "")
            return

        if (tokensStart + REFRESH_LIFETIME < now)
            onReauth()
        val refresh = preferences.getString(REFRESH, "")
        val nextPair =
            httpClient.get("${REST_API_PATH}Users/RefreshAuthorization?refreshToken=${refresh}")
        val text = nextPair.bodyAsText()
        try {
            val tokens = Parser.decodeFromString<TokenPair>(text)
            saveAuthorization(tokens.jwtToken, tokens.refreshToken)
        } catch (e: Exception) {
            println(e.message)
        }
    }

    suspend fun fetchSewerCollection() {
        tryUpdateAuth()
        val url = "${REST_API_PATH}Order/collection?SewerId=${Sewer.id}"
        val response =
            httpClient.get(url) {
                bearerAuth(currentJWT)
            }

        if (response.status == HttpStatusCode.OK) {
            val stringed = response.bodyAsText()
            try {
                val collection = Parser.decodeFromString<List<Order>>(stringed)
                AttachedOrders =
                    collection.filter { it.sewerId == Sewer.id && it.orderStatusId != OrderStatus.Canceled.id } as MutableList<Order>
                FreeOrders =
                    collection.filter { it.orderStatusId == OrderStatus.New.id } as MutableList<Order>
            } catch (je: Exception) {
                throw JsonParseException(stringed, url, je.message!!)
            }
        } else {
            throw ApiException(response.bodyAsText(), url, response.status.toString())
        }
    }

    suspend fun authorize(login: String, password: String): User {
        val url = "${REST_API_PATH}Users/Authorization?Username=$login&Password=$password"

        val response =
            httpClient.get(url)
        if (response.status == HttpStatusCode.OK) {
            val stringed = response.bodyAsText()
            try {
                val auth = Parser.decodeFromString<UserAuth>(stringed)
                saveAuthorization(auth.jwtToken, auth.refreshToken)
                User = auth.toUser()
            } catch (je: Exception) {
                throw JsonParseException(stringed, url, je.message!!)
            }
        } else {
            throw ApiException(response.bodyAsText(), url, response.status.toString())
        }
        return User
    }

    suspend fun fetchUserData(id: Int) {
        tryUpdateAuth()
        val url = "${REST_API_PATH}Users/GetUserById?Id=$id"
        val response =
            httpClient.get(url) {
                bearerAuth(currentJWT)
            }
        val text = response.bodyAsText()
        if (response.status != HttpStatusCode.OK)
            throw ApiException(text, url, response.status.toString())
        try {
            User =
                Parser.decodeFromString<User>(text)
        } catch (je: Exception) {
            throw JsonParseException(text, url, je.message!!)
        }


    }

    suspend fun getSewerById(): Sewer {
        tryUpdateAuth()
        Sewer = getSewerById(User.id)
        return Sewer
    }

    suspend fun getSewerById(id: Int): Sewer {
        tryUpdateAuth()
        val url = "${REST_API_PATH}Sewers/GetSeverByUserId?UserId=$id"
        val response =
            httpClient.get(url) {
                bearerAuth(currentJWT)
            }
        val text = response.bodyAsText()
        if (response.status != HttpStatusCode.OK)
            throw ApiException(text, url, response.status.toString())
        try {
            return Parser.decodeFromString<Sewer>(
                text
            )
        } catch (je: Exception) {
            throw JsonParseException(text, url, je.message!!)
        }

    }

    suspend fun getOrderById(id: Int): Order {
        tryUpdateAuth()
        val url = "${REST_API_PATH}Order/OrdersById?Id=$id"
        val response = httpClient.get(url) {
            bearerAuth(currentJWT)
        }
        val str = response.bodyAsText()
        if (response.status != HttpStatusCode.OK)
            throw ApiException(str, url, response.status.toString())
        try {
            return Parser.decodeFromString<Order>(
                str
            )
        } catch (je: Exception) {
            throw JsonParseException(str, url, je.message!!)
        }
    }

    suspend fun setOrderStatus(orderId: Int, statusId: Int) {
        tryUpdateAuth()
        val url = "${REST_API_PATH}Order/ChangeOrderStatus?OrderId=${orderId}"
        val response =
            httpClient.put(url) {
                contentType(
                    ContentType.Application.Json
                )
                setBody("{ \"orderId\": $orderId, \"orderStatusId\": $statusId }")
                bearerAuth(currentJWT)

            }
        if (response.status != HttpStatusCode.OK)
            throw ApiException(response.bodyAsText(), url, response.status.toString())
        Log.i("api", "SetOrderStatus: ${response.status}")
    }

    suspend fun attachOrder(orderId: Int, sewerId: Int, companyId: Int) {
        tryUpdateAuth()
        var url = "${REST_API_PATH}Order/AttachSewer?OrderId=${orderId}"
        var response = httpClient.put(url) {
            contentType(ContentType.Application.Json)
            bearerAuth(currentJWT)
            setBody("{\"sewerId\": ${sewerId}}")
        }
        if (response.status != HttpStatusCode.OK)
            throw ApiException(response.bodyAsText(), url, response.status.toString())
        Log.i(
            "api",
            "AttachOrder: order $orderId attached to sewer $sewerId with code ${response.status}"
        )
        url = "${REST_API_PATH}Order/AttachCompany?OrderId=${orderId}"
        response = httpClient.put(url) {
            contentType(ContentType.Application.Json)
            bearerAuth(currentJWT)
            setBody("{\"companyId\": ${companyId}}")
        }
        if (response.status != HttpStatusCode.OK)
            throw ApiException(response.bodyAsText(), url, response.status.toString())
        Log.i(
            "api",
            "AttachOrder: order $orderId attached to company $sewerId with code ${response.status}"
        )
    }

    suspend fun confirmOrder(code: String): HttpStatusCode {
        tryUpdateAuth()
        val url = "${REST_API_PATH}Order/confirm?Code=$code&OrderStatusId=3"
        val response = httpClient.post(url) {
            bearerAuth(currentJWT)
        }
        return response.status
    }

    suspend fun updateUser(): HttpStatusCode {
        tryUpdateAuth()
        val msg = User.toUpdate()
        val url = "${REST_API_PATH}Users/UpdateUser?id=${User.id}"
        val response = httpClient.put(url) {
            contentType(ContentType.Application.Json)
            setBody(Json.encodeToString(msg))
            bearerAuth(currentJWT)
        }
        return response.status
    }

    suspend fun getPlants(municipalityId: Int): List<TreatmentPlant> {
        tryUpdateAuth()
        val url = "${REST_API_PATH}Plants/municipality?MunicipalityId=$municipalityId"
        val response =
            httpClient.get(url) {
                bearerAuth(currentJWT)
            }
        val responseText = response.bodyAsText()
        if (response.status != HttpStatusCode.OK)
            throw ApiException(responseText, url, response.status.toString())
        try {
            TreatmentPlants = Parser.decodeFromString<List<TreatmentPlant>>(responseText)
        } catch (je: Exception) {
            throw JsonParseException(responseText, url, je.message!!)
        }
        return TreatmentPlants
    }

    suspend fun createOrder(
        municipalityName: String,
        wasteVolume: Int,
        address: String,
        comment: String,
        timestamp: LocalDateTime,
        longitude: Float,
        latitude: Float
    ) {
        tryUpdateAuth()
        val body = """
            {
              "comment": "$comment",
              "wasteVolume": $wasteVolume,
              "adress": "$address",
              "sewerId": ${User.id},
              "arrivalStartDate": "${
            timestamp.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)
        }",
              "latitude": $latitude,
              "longitude": $longitude,
              "municipalityName": "$municipalityName"
            }
        """.trimIndent()
        val url = "${REST_API_PATH}Order/self"
        val response = httpClient.post(url) {
            contentType(ContentType.Application.Json)
            setBody(body)
            bearerAuth(currentJWT)

        }

        if (response.status != HttpStatusCode.OK)
            throw ApiException(response.bodyAsText(), url, response.status.toString())
        val responseText = response.bodyAsText()
        val orderId = JSONObject(responseText).getInt("id")

        val order = getOrderById(orderId)
        lastOrder = order
        FreeOrders.remove(order)
        AttachedOrders.add(order)
        AttachedOrders = AttachedOrders.distinct().toMutableList()
        refreshOrders()
    }

    suspend fun getPlantsForSewer(): List<TreatmentPlant> {
        tryUpdateAuth()
        val url = "${REST_API_PATH}Plants/sewers?SewerId=${Sewer.id}"
        val response = httpClient.get(url) {
            bearerAuth(currentJWT)
        }
        val responseText = response.bodyAsText()
        if (response.status != HttpStatusCode.OK)
            throw ApiException(response.bodyAsText(), url, response.status.toString())

        try {
            val result = Parser.decodeFromString<List<TreatmentPlant>>(responseText)
            return result
        } catch (je: Exception) {
            throw JsonParseException(responseText, url, je.message!!)
        }
    }

    fun x() {
        return
    }
    
    suspend fun getPaymentLink(summ: Float, orderName: String): String {
        tryUpdateAuth()
        val url = "${REST_API_PATH}Billing/invoice/link"
        val body = """
            {
              "userId": ${User.id},
              "payAmount": $summ,
              "orderName": "$orderName",
              "serviceName": "Оплата Триэко"
            }
        """.trimIndent()
        val response = httpClient.post(url) {
            contentType(ContentType.Application.Json)
            setBody(body)
            bearerAuth(currentJWT)

        }
        val responseText = response.bodyAsText()
        if (response.status != HttpStatusCode.OK)
            throw ApiException(response.bodyAsText(), url, response.status.toString())

        try {
            val result = JSONObject(responseText).getString("link")
            return result
        } catch (je: Exception) {
            throw JsonParseException(responseText, url, je.message!!)
        }
    }

    suspend fun getInvoiceStatus(invoiceId: String): String {
        tryUpdateAuth()
        val url = "${REST_API_PATH}Billing/invoice/status?InvoiceId=$invoiceId"
        val response = httpClient.get(url) {
            bearerAuth(currentJWT)
        }
        val responseText = response.bodyAsText()
        if (response.status != HttpStatusCode.OK)
            throw ApiException(response.bodyAsText(), url, response.status.toString())

        try {
            val result = JSONObject(responseText).getString("status")
            return result
        } catch (je: Exception) {
            throw JsonParseException(responseText, url, je.message!!)
        }
    }

    suspend fun setOrderPaid(orderId: Int) {
        tryUpdateAuth()
        val url = "${REST_API_PATH}Order/paid?OrderId=$orderId"
        httpClient.post(url) {
            contentType(ContentType.Application.Json)
            bearerAuth(currentJWT)

            setBody(
                """
                {
                  "orderId": $orderId
                }
            """.trimIndent()
            )
        }
    }

    suspend fun getAddresses(promt: String): List<AddressSuggest> {
        try {

            val url =
                "https://maps.vk.com/api/suggest?api_key=RSe0266ce5cca3990591009afbbecaf35c12e6ec656e4a7682eae76b617f3745&q=${
                    if (!promt.lowercase().contains("россия")) "Россия " else ""
                }$promt&lang=ru&fields=address"
            val results = httpClient.get(url).bodyAsText()

            val parsed = Parser.decodeFromString<TotalAddressSuggest>(results)

            return parsed.results
        } catch (ex: Exception) {
            return listOf()
        }
    }

    suspend fun sendLog(log: MobileLog) {
        if (currentJWT == "")
            return
        tryUpdateAuth()
        val url = "${REST_API_PATH}Logging"
        val body = Parser.encodeToString(log)
        httpClient.post(url) {
            contentType(ContentType.Application.Json)
            setBody(body)
            bearerAuth(currentJWT)
        }
    }
}

class ApiException(message: String, val url: String, val code: String) : Exception(message) {

    override fun toString(): String {
        return "Error code ($code) in api by request $url\nMessage: $message"
    }
}

class JsonParseException(val text: String, val url: String, message: String) : Exception(message) {

    override fun toString(): String {
        return "Parse error of $text in api by request $url"
    }
}