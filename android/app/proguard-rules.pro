# Keep Google ML Kit Text Recognition classes to prevent release compilation optimization (R8) errors
-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn com.google.mlkit.vision.text.**
