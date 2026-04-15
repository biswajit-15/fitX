# Flutter core
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Sign-In
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.gms.auth.api.signin.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Google Sign-In plugin
-keep class io.flutter.plugins.googlesignin.** { *; }

# Keep annotations & metadata
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Optional warnings suppression
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**