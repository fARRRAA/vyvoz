package com.trieco.project_gbo.network.http

import kotlinx.serialization.Serializable

@Serializable
data class AddressSuggest(val address: String)

@Serializable
data class TotalAddressSuggest(val request: String, val results: List<AddressSuggest>)
