package com.trieco.project_gbo.models

import com.trieco.project_gbo.R
import kotlinx.serialization.Serializable

@Serializable
data class LicenseStatus(val id: Int, var title: String) {
    companion object {
        val Colors = mapOf(
            1 to R.color.licenseNone,
            2 to R.color.licenseLoaded,
            3 to R.color.licenseApproved,
            4 to R.color.licenseOverdue,
            1 to R.color.licenseRejected,
            0 to R.color.greyDark
        )
    }
}

