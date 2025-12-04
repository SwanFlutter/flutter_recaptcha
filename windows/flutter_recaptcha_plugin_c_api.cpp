#include "include/flutter_recaptcha/flutter_recaptcha_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_recaptcha_plugin.h"

void FlutterRecaptchaPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_recaptcha::FlutterRecaptchaPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
