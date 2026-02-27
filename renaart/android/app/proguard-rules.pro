# Flutter keeps all classes needed at runtime
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Hive
-keep class com.hivedb.** { *; }
-keepclassmembers class * extends com.hive.HiveObject { *; }

# Dio / OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class com.squareup.okhttp3.** { *; }

# Keep Met Museum API model classes
-keep class com.renaart.app.models.** { *; }
