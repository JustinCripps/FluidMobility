package com.example.ttlock_fluid_app

import com.ttlock.ttlock_flutter.TtlockFlutterPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String?>?, grantResults: IntArray?) {
        val ttlockflutterpluginPlugin = getFlutterEngine().getPlugins().get(TtlockFlutterPlugin::class.java) as TtlockFlutterPlugin
        ttlockflutterpluginPlugin?.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
}
