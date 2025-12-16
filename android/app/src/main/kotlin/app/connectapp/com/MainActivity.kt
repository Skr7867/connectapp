package app.connectapp.com

import android.content.Intent
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "notification_tap_channel"
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)

        intent?.let { handleIntent(it) }  // 🚀 Instant, no UI delay
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)  // 🚀 Instant
    }

    private fun bundleToMap(bundle: Bundle?): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>()
        if (bundle == null) return result

        for (key in bundle.keySet()) {
            val value = bundle.get(key)
            result[key] = when (value) {
                is Bundle -> bundleToMap(value)
                else -> value
            }
        }
        return result
    }

    private fun handleIntent(intent: Intent) {
        val extras = intent.extras ?: return
        val data = bundleToMap(extras)

        channel?.invokeMethod("notificationTap", data)
    }
}
