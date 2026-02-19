package com.example.assistant

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.assistant/screen_time"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasPermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "openUsageSettings" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(true)
                }
                "getUsageStats" -> {
                    val date = call.argument<String>("date")
                    if (!hasUsageStatsPermission()) {
                        result.error("PERMISSION_DENIED", "Usage stats permission not granted", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val stats = getUsageStats(date)
                        result.success(stats)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun getUsageStats(date: String?): List<Map<String, Any>> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val calendar = Calendar.getInstance()
        if (date != null) {
            val parts = date.split("-")
            calendar.set(parts[0].toInt(), parts[1].toInt() - 1, parts[2].toInt())
        }
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startTime = calendar.timeInMillis

        calendar.set(Calendar.HOUR_OF_DAY, 23)
        calendar.set(Calendar.MINUTE, 59)
        calendar.set(Calendar.SECOND, 59)
        val endTime = calendar.timeInMillis

        val usageStatsList = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY, startTime, endTime
        )

        val pm = packageManager
        val result = mutableListOf<Map<String, Any>>()

        for (stat in usageStatsList) {
            val totalTime = stat.totalTimeInForeground
            if (totalTime <= 0) continue

            val appName = try {
                val appInfo = pm.getApplicationInfo(stat.packageName, 0)
                pm.getApplicationLabel(appInfo).toString()
            } catch (e: PackageManager.NameNotFoundException) {
                stat.packageName
            }

            val category = try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val appInfo = pm.getApplicationInfo(stat.packageName, 0)
                    getCategoryName(appInfo.category)
                } else {
                    "other"
                }
            } catch (e: Exception) {
                "other"
            }

            result.add(
                mapOf(
                    "appName" to appName,
                    "packageName" to stat.packageName,
                    "totalTimeInForeground" to (totalTime / 60000), // Convert ms to minutes
                    "category" to category
                )
            )
        }

        // Sort by usage time descending
        return result.sortedByDescending { it["totalTimeInForeground"] as Long }
    }

    private fun getCategoryName(category: Int): String {
        return when (category) {
            0 -> "game" // CATEGORY_GAME
            1 -> "audio" // CATEGORY_AUDIO
            2 -> "video" // CATEGORY_VIDEO
            3 -> "image" // CATEGORY_IMAGE
            4 -> "social" // CATEGORY_SOCIAL
            5 -> "news" // CATEGORY_NEWS
            6 -> "maps" // CATEGORY_MAPS
            7 -> "productivity" // CATEGORY_PRODUCTIVITY
            else -> "other"
        }
    }
}
