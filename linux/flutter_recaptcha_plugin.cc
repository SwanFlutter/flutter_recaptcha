#include "include/flutter_recaptcha/flutter_recaptcha_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>
#include <unistd.h>
#include <time.h>

#include <cstring>

#include "flutter_recaptcha_plugin_private.h"

#define FLUTTER_RECAPTCHA_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_recaptcha_plugin_get_type(), \
                              FlutterRecaptchaPlugin))

struct _FlutterRecaptchaPlugin {
    GObject parent_instance;
};

G_DEFINE_TYPE(FlutterRecaptchaPlugin, flutter_recaptcha_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void flutter_recaptcha_plugin_handle_method_call(
        FlutterRecaptchaPlugin* self,
        FlMethodCall* method_call) {
    g_autoptr(FlMethodResponse) response = nullptr;

    const gchar* method = fl_method_call_get_name(method_call);

    if (strcmp(method, "getPlatformVersion") == 0) {
        response = get_platform_version();
    } else if (strcmp(method, "initialize") == 0) {
        response = handle_initialize(method_call);
    } else if (strcmp(method, "verify") == 0) {
        response = handle_verify(method_call);
    } else if (strcmp(method, "isBiometricAvailable") == 0) {
        response = handle_biometric_available();
    } else if (strcmp(method, "authenticateWithBiometric") == 0) {
        response = handle_biometric_auth();
    } else if (strcmp(method, "startBehavioralAnalysis") == 0) {
        response = handle_start_behavioral();
    } else if (strcmp(method, "stopBehavioralAnalysis") == 0) {
        response = handle_stop_behavioral();
    } else if (strcmp(method, "getDeviceFingerprint") == 0) {
        response = handle_device_fingerprint();
    } else if (strcmp(method, "reset") == 0) {
        response = handle_reset();
    } else {
        response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    }

    fl_method_call_respond(method_call, response, nullptr);
}

FlMethodResponse* get_platform_version() {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result = fl_value_new_string(version);
    return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

static void flutter_recaptcha_plugin_dispose(GObject* object) {
    G_OBJECT_CLASS(flutter_recaptcha_plugin_parent_class)->dispose(object);
}

static void flutter_recaptcha_plugin_class_init(FlutterRecaptchaPluginClass* klass) {
    G_OBJECT_CLASS(klass)->dispose = flutter_recaptcha_plugin_dispose;
}

static void flutter_recaptcha_plugin_init(FlutterRecaptchaPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
    FlutterRecaptchaPlugin* plugin = FLUTTER_RECAPTCHA_PLUGIN(user_data);
    flutter_recaptcha_plugin_handle_method_call(plugin, method_call);
}

// Helper functions for method implementations
static FlMethodResponse* handle_initialize(FlMethodCall* method_call) {
    g_autoptr(FlValue) result = fl_value_new_bool(TRUE);
    return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

static FlMethodResponse* handle_verify(FlMethodCall* method_call) {
    // Simulate verification process
    double score = 0.7 + (g_random_double() * 0.3); // Random score between 0.7-1.0
    gboolean success = score > 0.8;

    g_autoptr(FlValue) result_map = fl_value_new_map();
    fl_value_set_string_take(result_map, "success", fl_value_new_bool(success));

    if (success) {
        gchar* token = g_strdup_printf("linux_token_%ld", time(NULL));
        fl_value_set_string_take(result_map, "token", fl_value_new_string(token));
        g_free(token);
    }

    fl_value_set_string_take(result_map, "score", fl_value_new_float(score));
    fl_value_set_string_take(result_map, "challengeType", fl_value_new_string("traditional"));

    g_autoptr(FlValue) metadata = fl_value_new_map();
    fl_value_set_string_take(metadata, "platform", fl_value_new_string("linux"));
    fl_value_set_string_take(metadata, "timestamp", fl_value_new_int(time(NULL) * 1000));
    fl_value_set_string_take(result_map, "metadata", metadata);

    return FL_METHOD_RESPONSE(fl_method_success_response_new(result_map));
}

static FlMethodResponse* handle_biometric_available() {
    // Linux typically doesn't have built-in biometric authentication
    // Return false to ensure pattern challenges are used
    g_autoptr(FlValue) result = fl_value_new_bool(FALSE);
    return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

static FlMethodResponse* handle_biometric_auth() {
    g_autoptr(FlValue) result_map = fl_value_new_map();
    fl_value_set_string_take(result_map, "success", fl_value_new_bool(FALSE));
    fl_value_set_string_take(result_map, "errorMessage", fl_value_new_string("Biometric authentication not available on Linux"));

    return FL_METHOD_RESPONSE(fl_method_success_response_new(result_map));
}

static FlMethodResponse* handle_start_behavioral() {
    // Store start time (simplified implementation)
    return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
}

static FlMethodResponse* handle_stop_behavioral() {
    // Simple behavioral scoring
    double score = 0.7 + (g_random_double() * 0.2); // Random score between 0.7-0.9
    gboolean success = score > 0.6;

    g_autoptr(FlValue) result_map = fl_value_new_map();
    fl_value_set_string_take(result_map, "success", fl_value_new_bool(success));

    if (success) {
        gchar* token = g_strdup_printf("behavioral_token_%ld", time(NULL));
        fl_value_set_string_take(result_map, "token", fl_value_new_string(token));
        g_free(token);
    }

    fl_value_set_string_take(result_map, "score", fl_value_new_float(score));
    fl_value_set_string_take(result_map, "challengeType", fl_value_new_string("behavioral"));

    g_autoptr(FlValue) metadata = fl_value_new_map();
    fl_value_set_string_take(metadata, "platform", fl_value_new_string("linux"));
    fl_value_set_string_take(metadata, "timestamp", fl_value_new_int(time(NULL) * 1000));
    fl_value_set_string_take(result_map, "metadata", metadata);

    return FL_METHOD_RESPONSE(fl_method_success_response_new(result_map));
}

static FlMethodResponse* handle_device_fingerprint() {
    // Simple device fingerprinting for Linux
    gchar* hostname = g_malloc(256);
    if (gethostname(hostname, 256) == 0) {
        gchar* fingerprint = g_strdup_printf("linux_%s_%ld", hostname, time(NULL));
        g_autoptr(FlValue) result = fl_value_new_string(fingerprint);
        g_free(hostname);
        g_free(fingerprint);
        return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    }

    g_free(hostname);
    g_autoptr(FlValue) result = fl_value_new_string("linux_unknown");
    return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

static FlMethodResponse* handle_reset() {
    return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
}

void flutter_recaptcha_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
    FlutterRecaptchaPlugin* plugin = FLUTTER_RECAPTCHA_PLUGIN(
            g_object_new(flutter_recaptcha_plugin_get_type(), nullptr));

    g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
    g_autoptr(FlMethodChannel) channel =
                                       fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                                                             "flutter_recaptcha",
                                                             FL_METHOD_CODEC(codec));
    fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                              g_object_ref(plugin),
                                              g_object_unref);

    g_object_unref(plugin);
}
