package com.example.flutter_recaptcha

import android.app.Activity
import android.content.Context
import android.os.Build
import android.provider.Settings
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.security.MessageDigest
import java.util.concurrent.Executor

/** FlutterRecaptchaPlugin */
class FlutterRecaptchaPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel : MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null
    private var config: Map<String, Any>? = null
    private var behavioralStartTime: Long = 0
    private var behavioralData: MutableList<Map<String, Any>> = mutableListOf()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_recaptcha")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "initialize" -> {
                initialize(call.arguments as Map<String, Any>, result)
            }
            "verify" -> {
                verify(call.arguments as? Map<String, Any>, result)
            }
            "isBiometricAvailable" -> {
                result.success(isBiometricAvailable())
            }
            "authenticateWithBiometric" -> {
                authenticateWithBiometric(result)
            }
            "startBehavioralAnalysis" -> {
                startBehavioralAnalysis(result)
            }
            "stopBehavioralAnalysis" -> {
                stopBehavioralAnalysis(result)
            }
            "getDeviceFingerprint" -> {
                result.success(getDeviceFingerprint())
            }
            "reset" -> {
                reset(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initialize(arguments: Map<String, Any>, result: Result) {
        config = arguments
        result.success(true)
    }

    private fun verify(arguments: Map<String, Any>?, result: Result) {
        val action = arguments?.get("action") as? String

        // Simulate verification process
        val score = kotlin.random.Random.nextDouble(0.7, 1.0)
        val success = score > 0.8

        val resultMap = mapOf(
            "success" to success,
            "token" to if (success) "android_token_${System.currentTimeMillis()}" else null,
            "score" to score,
            "challengeType" to "traditional",
            "metadata" to mapOf(
                "platform" to "android",
                "action" to action,
                "timestamp" to System.currentTimeMillis()
            )
        )

        result.success(resultMap)
    }

    private fun isBiometricAvailable(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val biometricManager = androidx.biometric.BiometricManager.from(context!!)
            when (biometricManager.canAuthenticate(androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_WEAK)) {
                androidx.biometric.BiometricManager.BIOMETRIC_SUCCESS -> true
                else -> false
            }
        } else {
            false
        }
    }

    private fun authenticateWithBiometric(result: Result) {
        if (!isBiometricAvailable() || activity == null) {
            result.success(mapOf(
                "success" to false,
                "errorMessage" to "Biometric authentication not available"
            ))
            return
        }

        val executor: Executor = ContextCompat.getMainExecutor(context!!)
        val biometricPrompt = BiometricPrompt(activity as FragmentActivity, executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)
                    result.success(mapOf(
                        "success" to false,
                        "errorMessage" to errString.toString()
                    ))
                }

                override fun onAuthenticationSucceeded(authResult: BiometricPrompt.AuthenticationResult) {
                    super.onAuthenticationSucceeded(authResult)
                    result.success(mapOf(
                        "success" to true,
                        "token" to "biometric_token_${System.currentTimeMillis()}",
                        "score" to 1.0,
                        "challengeType" to "biometric",
                        "metadata" to mapOf(
                            "platform" to "android",
                            "biometricType" to "fingerprint_or_face",
                            "timestamp" to System.currentTimeMillis()
                        )
                    ))
                }

                override fun onAuthenticationFailed() {
                    super.onAuthenticationFailed()
                    result.success(mapOf(
                        "success" to false,
                        "errorMessage" to "Authentication failed"
                    ))
                }
            })

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("reCAPTCHA Biometric Authentication")
            .setSubtitle("Use your biometric credential to verify")
            .setNegativeButtonText("Cancel")
            .build()

        biometricPrompt.authenticate(promptInfo)
    }

    private fun startBehavioralAnalysis(result: Result) {
        behavioralStartTime = System.currentTimeMillis()
        behavioralData.clear()
        result.success(null)
    }

    private fun stopBehavioralAnalysis(result: Result) {
        val duration = System.currentTimeMillis() - behavioralStartTime
        val score = calculateBehavioralScore(duration)

        val resultMap = mapOf(
            "success" to (score > 0.6),
            "token" to if (score > 0.6) "behavioral_token_${System.currentTimeMillis()}" else null,
            "score" to score,
            "challengeType" to "behavioral",
            "metadata" to mapOf(
                "platform" to "android",
                "duration" to duration,
                "dataPoints" to behavioralData.size,
                "timestamp" to System.currentTimeMillis()
            )
        )

        result.success(resultMap)
    }

    private fun calculateBehavioralScore(duration: Long): Double {
        // Simple behavioral scoring algorithm
        var score = 0.5

        if (duration > 1000) score += 0.2 // More than 1 second
        if (duration < 10000) score += 0.2 // Less than 10 seconds (not too slow)
        if (behavioralData.size > 5) score += 0.1 // Some interaction data

        return score.coerceIn(0.0, 1.0)
    }

    private fun getDeviceFingerprint(): String {
        val deviceInfo = StringBuilder()

        deviceInfo.append(Build.MANUFACTURER)
        deviceInfo.append(Build.MODEL)
        deviceInfo.append(Build.VERSION.RELEASE)
        deviceInfo.append(Build.VERSION.SDK_INT)

        context?.let {
            val androidId = Settings.Secure.getString(it.contentResolver, Settings.Secure.ANDROID_ID)
            deviceInfo.append(androidId)
        }

        return hashString(deviceInfo.toString())
    }

    private fun hashString(input: String): String {
        val bytes = MessageDigest.getInstance("SHA-256").digest(input.toByteArray())
        return bytes.joinToString("") { "%02x".format(it) }
    }

    private fun reset(result: Result) {
        config = null
        behavioralData.clear()
        behavioralStartTime = 0
        result.success(null)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
