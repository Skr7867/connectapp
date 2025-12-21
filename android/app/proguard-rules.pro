# ===============================
# STRIPE ANDROID SDK (REQUIRED)
# ===============================
-keep class com.stripe.android.** { *; }
-keepclassmembers class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# Kotlin metadata (Stripe uses Kotlin reflection)
-keep class kotlin.Metadata { *; }
