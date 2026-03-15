package com.nanofuxion.tamerdisplaybrowser

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.browser.customtabs.CustomTabsIntent
import com.lynx.jsbridge.LynxMethod
import com.lynx.jsbridge.LynxModule
import com.lynx.react.bridge.Callback
import org.json.JSONObject

class DisplayBrowserModule(context: Context) : LynxModule(context) {

    companion object {
        private const val TAG = "DisplayBrowserModule"
    }

    @LynxMethod
    fun openBrowserAsync(url: String, optionsJson: String, callback: Callback) {
        val ctx = mContext ?: run {
            callback.invoke(JSONObject().put("type", "cancel").put("error", "no context").toString())
            return
        }
        try {
            val intent = CustomTabsIntent.Builder().build()
            intent.intent.data = Uri.parse(url)
            intent.launchUrl(ctx, Uri.parse(url))
            callback.invoke(JSONObject().put("type", "opened").toString())
        } catch (e: Exception) {
            Log.e(TAG, "openBrowserAsync error: ${e.message}")
            callback.invoke(JSONObject().put("type", "cancel").put("error", e.message).toString())
        }
    }

    @LynxMethod
    fun dismissBrowser(callback: Callback) {
        callback.invoke(JSONObject().put("type", "dismiss").toString())
    }
}
