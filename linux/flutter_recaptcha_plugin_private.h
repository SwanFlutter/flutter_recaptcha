#include <flutter_linux/flutter_linux.h>

#include "include/flutter_recaptcha/flutter_recaptcha_plugin.h"

// This file exposes some plugin internals for unit testing. See
// https://github.com/flutter/flutter/issues/88724 for current limitations
// in the unit-testable API.

// Handles the getPlatformVersion method call.
FlMethodResponse *get_platform_version();

// Helper functions for method implementations
static FlMethodResponse* handle_initialize(FlMethodCall* method_call);
static FlMethodResponse* handle_verify(FlMethodCall* method_call);
static FlMethodResponse* handle_biometric_available();
static FlMethodResponse* handle_biometric_auth();
static FlMethodResponse* handle_start_behavioral();
static FlMethodResponse* handle_stop_behavioral();
static FlMethodResponse* handle_device_fingerprint();
static FlMethodResponse* handle_reset();
