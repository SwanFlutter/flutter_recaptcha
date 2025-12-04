#ifndef FLUTTER_PLUGIN_FLUTTER_RECAPTCHA_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_RECAPTCHA_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <chrono>
#include <vector>
#include <map>
#include <string>

namespace flutter_recaptcha {

    class FlutterRecaptchaPlugin : public flutter::Plugin {
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

        FlutterRecaptchaPlugin();

        virtual ~FlutterRecaptchaPlugin();

        // Disallow copy and assign.
        FlutterRecaptchaPlugin(const FlutterRecaptchaPlugin&) = delete;
        FlutterRecaptchaPlugin& operator=(const FlutterRecaptchaPlugin&) = delete;

        // Called when a method is called on this plugin's channel from Dart.
        void HandleMethodCall(
                const flutter::MethodCall<flutter::EncodableValue> &method_call,
                std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

    private:
        void HandleVerify(
                const flutter::MethodCall<flutter::EncodableValue> &method_call,
                std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

        void HandleBiometricAuth(
                std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

        void HandleStopBehavioralAnalysis(
                std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

        std::string GetDeviceFingerprint();

        flutter::EncodableMap config_;
        std::chrono::steady_clock::time_point behavioral_start_time_;
        std::vector<flutter::EncodableMap> behavioral_data_;
    };

}  // namespace flutter_recaptcha

#endif  // FLUTTER_PLUGIN_FLUTTER_RECAPTCHA_PLUGIN_H_
