package com.example.zyvora

import android.os.Bundle
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.android.TransparencyMode

class MainActivity : FlutterFragmentActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)

		if (supportFragmentManager.findFragmentByTag("flutter_fragment") == null) {
			val flutterFragment = FlutterFragment.withNewEngine()
				.renderMode(RenderMode.texture)
				.transparencyMode(TransparencyMode.transparent)
				.build<FlutterFragment>()

			supportFragmentManager
				.beginTransaction()
				.add(android.R.id.content, flutterFragment, "flutter_fragment")
				.commit()
		}
	}
}
