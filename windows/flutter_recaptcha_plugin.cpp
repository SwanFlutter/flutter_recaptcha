#include "flutter_recaptcha_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
#include <chrono>
#include <ctime>
#include <functional>

namespace flutter_recaptcha {

// static
    void FlutterRecaptchaPlugin::RegisterWithRegistrar(
            flutter::PluginRegistrarWindows *registrar) {
        auto channel =
                std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                        registrar->messenger(), "flutter_recaptcha",
                                &flutter::StandardMethodCodec::GetInstance());

        auto plugin = std::make_unique<FlutterRecaptchaPlugin>();

        channel->SetMethodCallHandler(
                [plugin_pointer = plugin.get()](const auto &call, auto result) {
                    plugin_pointer->HandleMethodCall(call, std::move(result));
                });

        registrar->AddPlugin(std::move(plugin));
    }

    FlutterRecaptchaPlugin::FlutterRecaptchaPlugin() {}

    FlutterRecaptchaPlugin::~FlutterRecaptchaPlugin() {}

    void FlutterRecaptchaPlugin::HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue> &method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

        const std::string& method_name = method_call.method_name();

        if (method_name == "getPlatformVersion") {
            std::ostringstream version_stream;
            version_stream << "Windows ";
            if (IsWindows10OrGreater()) {
                version_stream << "10+";
            } else if (IsWindows8OrGreater()) {
                version_stream << "8";
            } else if (IsWindows7OrGreater()) {
                version_stream << "7";
            }
            result->Success(flutter::EncodableValue(version_stream.str()));
        }
        else if (method_name == "initialize") {
            // Store configuration
            config_ = std::get<flutter::EncodableMap>(*method_call.arguments());
            result->Success(flutter::EncodableValue(true));
        }
        else if (method_name == "verify") {
            HandleVerify(method_call, std::move(result));
        }
        else if (method_name == "isBiometricAvailable") {
            // Windows Hello is available but we'll keep it simple for now
            // In a real implementation, you would check for Windows Hello availability
            result->Success(flutter::EncodableValue(false)); // Return false to use pattern challenges
        }
        else if (method_name == "authenticateWithBiometric") {
            HandleBiometricAuth(std::move(result));
        }
        else if (method_name == "startBehavioralAnalysis") {
            behavioral_start_time_ = std::chrono::steady_clock::now();
            behavioral_data_.clear();
            result->Success();
        }
        else if (method_name == "stopBehavioralAnalysis") {
            HandleStopBehavioralAnalysis(std::move(result));
        }
        else if (method_name == "getDeviceFingerprint") {
            result->Success(flutter::EncodableValue(GetDeviceFingerprint()));
        }
        else if (method_name == "reset") {
            config_.clear();
            behavioral_data_.clear();
            result->Success();
        }
        else {
            result->NotImplemented();
        }
    }

    void FlutterRecaptchaPlugin::HandleVerify(
            const flutter::MethodCall<flutter::EncodableValue> &method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

        // Simulate verification process
        double score = 0.7 + (rand() % 30) / 100.0; // Random score between 0.7-1.0
        bool success = score > 0.8;

        flutter::EncodableMap result_map;
        result_map[flutter::EncodableValue("success")] = flutter::EncodableValue(success);
        if (success) {
            result_map[flutter::EncodableValue("token")] = flutter::EncodableValue("windows_token_" + std::to_string(std::time(nullptr)));
        }
        result_map[flutter::EncodableValue("score")] = flutter::EncodableValue(score);
        result_map[flutter::EncodableValue("challengeType")] = flutter::EncodableValue("traditional");

        flutter::EncodableMap metadata;
        metadata[flutter::EncodableValue("platform")] = flutter::EncodableValue("windows");
        metadata[flutter::EncodableValue("timestamp")] = flutter::EncodableValue(static_cast<int64_t>(std::time(nullptr) * 1000));
        result_map[flutter::EncodableValue("metadata")] = flutter::EncodableValue(metadata);

        result->Success(flutter::EncodableValue(result_map));
    }

    void FlutterRecaptchaPlugin::HandleBiometricAuth(
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

        flutter::EncodableMap result_map;
        result_map[flutter::EncodableValue("success")] = flutter::EncodableValue(false);
        result_map[flutter::EncodableValue("errorMessage")] = flutter::EncodableValue("Biometric authentication not available on Windows");

        result->Success(flutter::EncodableValue(result_map));
    }

    void FlutterRecaptchaPlugin::HandleStopBehavioralAnalysis(
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

        auto now = std::chrono::steady_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(now - behavioral_start_time_).count();

        // Simple behavioral scoring
        double score = 0.5;
        if (duration > 1000) score += 0.2; // More than 1 second
        if (duration < 10000) score += 0.2; // Less than 10 seconds
        if (behavioral_data_.size() > 5) score += 0.1; // Some interaction data

        bool success = score > 0.6;

        flutter::EncodableMap result_map;
        result_map[flutter::EncodableValue("success")] = flutter::EncodableValue(success);
        if (success) {
            result_map[flutter::EncodableValue("token")] = flutter::EncodableValue("behavioral_token_" + std::to_string(std::time(nullptr)));
        }
        result_map[flutter::EncodableValue("score")] = flutter::EncodableValue(score);
        result_map[flutter::EncodableValue("challengeType")] = flutter::EncodableValue("behavioral");

        flutter::EncodableMap metadata;
        metadata[flutter::EncodableValue("platform")] = flutter::EncodableValue("windows");
        metadata[flutter::EncodableValue("duration")] = flutter::EncodableValue(static_cast<int64_t>(duration));
        metadata[flutter::EncodableValue("dataPoints")] = flutter::EncodableValue(static_cast<int32_t>(behavioral_data_.size()));
        metadata[flutter::EncodableValue("timestamp")] = flutter::EncodableValue(static_cast<int64_t>(std::time(nullptr) * 1000));
        result_map[flutter::EncodableValue("metadata")] = flutter::EncodableValue(metadata);

        result->Success(flutter::EncodableValue(result_map));
    }

    std::string FlutterRecaptchaPlugin::GetDeviceFingerprint() {
        // Simple device fingerprinting for Windows
        std::string device_info = "Windows";

        // Add computer name
        char computer_name[256];
        DWORD size = sizeof(computer_name);
        if (GetComputerNameA(computer_name, &size)) {
            device_info += computer_name;
        }

        // Add OS version info
        OSVERSIONINFOA version_info;
        ZeroMemory(&version_info, sizeof(OSVERSIONINFOA));
        version_info.dwOSVersionInfoSize = sizeof(OSVERSIONINFOA);

        // Simple hash (in real implementation, use proper hashing)
        std::hash<std::string> hasher;
        size_t hash = hasher(device_info);

        std::ostringstream hash_stream;
        hash_stream << std::hex << hash;
        return hash_stream.str();
    }

}  // namespace flutter_recaptcha
