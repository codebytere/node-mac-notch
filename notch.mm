#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#include <napi.h>

/***** HELPERS *****/

Napi::Object GetObjectForNSRect(Napi::Env env, NSRect rect) {
  Napi::Object area = Napi::Object::New(env);

  Napi::Object origin = Napi::Object::New(env);
  origin.Set("x", rect.origin.x);
  origin.Set("y", rect.origin.y);
  area.Set("origin", origin);

  Napi::Object size = Napi::Object::New(env);
  size.Set("width", rect.size.width);
  size.Set("height", rect.size.height);
  area.Set("size", size);

  return area;
}

/***** EXPORTED FUNCTIONS *****/

Napi::Object SafeAreaInsets(const Napi::CallbackInfo &info) {
  Napi::Object insets = Napi::Object::New(info.Env());

  if (@available(macOS 12.0, *)) {
    NSEdgeInsets safe_area_insets = [[NSScreen mainScreen] safeAreaInsets];
    insets.Set("bottom", safe_area_insets.bottom);
    insets.Set("left", safe_area_insets.left);
    insets.Set("right", safe_area_insets.right);
    insets.Set("top", safe_area_insets.top);
  }

  return insets;
}

Napi::Object AuxiliaryTopLeftArea(const Napi::CallbackInfo &info) {
  NSScreen *screen = [NSScreen mainScreen];
  if (@available(macOS 12.0, *)) {
    NSRect rect = [screen auxiliaryTopLeftArea];
    return GetObjectForNSRect(info.Env(), rect);
  }

  return GetObjectForNSRect(info.Env(), [screen visibleFrame]);
}

Napi::Object AuxiliaryTopRightArea(const Napi::CallbackInfo &info) {
  NSScreen *screen = [NSScreen mainScreen];
  if (@available(macOS 12.0, *)) {
    NSRect rect = [screen auxiliaryTopRightArea];
    return GetObjectForNSRect(info.Env(), rect);
  }

  return GetObjectForNSRect(info.Env(), [screen visibleFrame]);
}

// Initializes all functions exposed to JS.
Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "safeAreaInsets"),
              Napi::Function::New(env, SafeAreaInsets));
  exports.Set(Napi::String::New(env, "auxiliaryTopLeftArea"),
              Napi::Function::New(env, AuxiliaryTopLeftArea));
  exports.Set(Napi::String::New(env, "auxiliaryTopRightArea"),
            Napi::Function::New(env, AuxiliaryTopRightArea));

  return exports;
}

NODE_API_MODULE(notch, Init)
