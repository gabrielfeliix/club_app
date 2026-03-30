# Supabase / PostgREST
-keep class io.supabase.** { *; }
-keep class io.github.jan.supabase.** { *; }
-keep class io.github.jan.supabase.postgrest.** { *; }

# GetIt
-keep class com.getit.** { *; }
-keep class * implements de.jonasroussel.get_it.GetIt { *; }

# Bloc / Equatable
-keep class com.felangel.bloc.** { *; }
-keep class com.google.gson.** { *; }

# Flutter
-keep class io.flutter.** { *; }

# Handle common issues with obfuscation
-keepattributes Signature, *Annotation*, EnclosingMethod

# Ignore Play Core warnings (often caused by Flutter engine's deferred component support)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
