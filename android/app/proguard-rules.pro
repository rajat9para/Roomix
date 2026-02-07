# ProGuard rules for Roomix Flutter app

#############################################
# Flutter wrapper
#############################################
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-dontwarn io.flutter.embedding.**

#############################################
# Firebase
#############################################
-keep class com.google.firebase.** { *; }
-keep class com.google.firebase.auth.** { *; }
-dontwarn com.google.firebase.**

#############################################
# Dio HTTP Library (uses OkHttp3 on Android)
#############################################
-keep class io.flutter.plugins.** { *; }

#############################################
# Google Sign-In
#############################################
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.**

#############################################
# Image handling (Image Picker, Cached Network Image)
#############################################
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**

#############################################
# Location and Geocoding
#############################################
-keep class io.flutter.plugins.geolocator.** { *; }
-keep class io.flutter.plugins.geocoding.** { *; }
-keep class com.google.android.gms.location.** { *; }
-dontwarn io.flutter.plugins.geolocator.**
-dontwarn io.flutter.plugins.geocoding.**

#############################################
# Cloudinary
#############################################
-keep class com.cloudinary.** { *; }
-dontwarn com.cloudinary.**

#############################################
# SharedPreferences and Secure Storage
#############################################
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class com.tencent.mmkv.** { *; }

#############################################
# JSON serialization (Gson, Retrofit, etc.)
#############################################
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class com.google.gson.stream.** { *; }

#############################################
# Multidex
#############################################
-keep class androidx.multidex.** { *; }
-keep class androidx.appcompat.** { *; }

#############################################
# AndroidX Libraries
#############################################
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**

#############################################
# Date & Time (Intl and related)
#############################################
-keep class java.time.** { *; }

#############################################
# OkHttp3 and okio (Dio uses these)
#############################################
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

#############################################
# Retrofit
#############################################
-keep class retrofit2.** { *; }
-keep interface retrofit2.** { *; }
-dontwarn retrofit2.**

#############################################
# Keep native methods
#############################################
-keepclasseswithmembernames class * {
    native <methods>;
}

#############################################
# Keep Parcelables
#############################################
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

#############################################
# Keep Serializable classes
#############################################
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

#############################################
# Keep custom application classes
#############################################
-keep class com.roomix.** { *; }
-keep interface com.roomix.** { *; }

#############################################
# Preserve line numbers for exceptions
#############################################
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
