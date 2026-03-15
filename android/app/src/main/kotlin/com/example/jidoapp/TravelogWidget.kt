package com.example.jidoapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.app.PendingIntent
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import java.io.File

class TravelogWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val packageName = context.packageName
        val layoutId = context.resources.getIdentifier("widget_layout", "layout", packageName)
        val views = RemoteViews(packageName, layoutId)

        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val imagePath = prefs.getString("filename", null)

        val widgetImageId = context.resources.getIdentifier("widget_image", "id", packageName)
        val widgetLogoId = context.resources.getIdentifier("widget_logo", "id", packageName)
        val widgetContainerId = context.resources.getIdentifier("widget_container", "id", packageName)
        val widgetRefreshBtnId = context.resources.getIdentifier("widget_refresh_btn", "id", packageName)

        if (imagePath != null) {
            val file = File(imagePath)
            if (file.exists()) {
                val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                views.setImageViewBitmap(widgetImageId, bitmap)
                views.setViewVisibility(widgetImageId, View.VISIBLE)
                views.setViewVisibility(widgetLogoId, View.GONE)
            }
        }

        // 전체 위젯 클릭 → 앱 열기
        val launchIntent = context.packageManager.getLaunchIntentForPackage(packageName)
        val launchPendingIntent = PendingIntent.getActivity(
            context, 0, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(widgetContainerId, launchPendingIntent)

        // 새로고침 버튼 클릭 → 앱 열기
        val refreshPendingIntent = PendingIntent.getActivity(
            context, 1, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(widgetRefreshBtnId, refreshPendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}