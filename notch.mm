#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#include <napi.h>

/***** HELPERS *****/

// Converts a simple C array to a Napi::Array.
template <typename T> Napi::Array CArrayToNapiArray(Napi::Env env, T *c_arr) {
  Napi::Array arr = Napi::Array::New(env, sizeof c_arr);

  for (size_t i = 0; i < sizeof c_arr; i++) {
    arr[i] = static_cast<int>(c_arr[i]);
  }

  return arr;
}

// Converts an NSColorSpace to an object containing information about the
// colorSpace.
Napi::Object NSColorSpaceToObject(Napi::Env env, NSColorSpace *color_space) {
  Napi::Object obj = Napi::Object::New(env);

  obj.Set("name", std::string([[color_space localizedName] UTF8String]));
  obj.Set("componentCount", [color_space numberOfColorComponents]);

  return obj;
}

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

// Converts an NSRect to an object representing bounds.
Napi::Object NSRectToBoundsObject(Napi::Env env, const NSRect &rect) {
  Napi::Object obj = Napi::Object::New(env);

  CGFloat primary_display_height =
      NSMaxY([[[NSScreen screens] firstObject] frame]);

  obj.Set("x", rect.origin.x);
  obj.Set("y", primary_display_height - rect.origin.y - rect.size.height);
  obj.Set("width", rect.size.width);
  obj.Set("height", rect.size.height);

  return obj;
}

// Returns the NSScreen correspondent to a specified display id.
NSScreen *ScreenForID(uint32_t display_id) {
  NSArray<NSScreen *> *screens = [NSScreen screens];

  size_t num_displays = [screens count];
  for (size_t i = 0; i < num_displays; i++) {
    NSScreen *screen = [screens objectAtIndex:i];
    CGDirectDisplayID s_id = [[[screen deviceDescription]
        objectForKey:@"NSScreenNumber"] unsignedIntValue];
    if (s_id == display_id)
      return screen;
  }

  return nullptr;
}

// Creates an object containing all properties of an display.
Napi::Object BuildDisplay(Napi::Env env, NSScreen *nsscreen) {
  Napi::Object display = Napi::Object::New(env);

  CGDirectDisplayID display_id = [[[nsscreen deviceDescription]
      objectForKey:@"NSScreenNumber"] unsignedIntValue];
  display.Set("id", display_id);

  if (@available(macOS 10.15, *)) {
    display.Set("name", std::string([[nsscreen localizedName] UTF8String]));
  }

  CGDisplayModeRef display_mode = CGDisplayCopyDisplayMode(display_id);
  display.Set("refreshRate", CGDisplayModeGetRefreshRate(display_mode));

  display.Set("supportedWindowDepths",
              CArrayToNapiArray(env, [nsscreen supportedWindowDepths]));
  display.Set("isAsleep", CGDisplayIsAsleep(display_id) ? true : false);
  display.Set("isMonochrome", GetIsMonochrome());
  display.Set("colorSpace", NSColorSpaceToObject(env, [nsscreen colorSpace]));
  display.Set("depth", static_cast<int>([nsscreen depth]));
  display.Set("scaleFactor", [nsscreen backingScaleFactor]);
  display.Set("bounds", NSRectToBoundsObject(env, [nsscreen frame]));
  display.Set("workArea", NSRectToBoundsObject(env, [nsscreen visibleFrame]));
  display.Set("rotation", static_cast<int>(CGDisplayRotation(display_id)));
  display.Set("internal", CGDisplayIsBuiltin(display_id) ? true : false);

  return display;
}

/***** EXPORTED FUNCTIONS *****/

// Returns an array of all system displays.
Napi::Array GetAllDisplays(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  NSArray<NSScreen *> *nsscreens = [NSScreen screens];
  size_t num_displays = [nsscreens count];

  Napi::Array displays = Napi::Array::New(env, num_displays);
  for (size_t i = 0; i < num_displays; i++) {
    displays[i] = BuildDisplay(env, [nsscreens objectAtIndex:i]);
  }

  return displays;
}

// Returns the display object with the specified display id.
Napi::Object GetDisplayByID(const Napi::CallbackInfo &info) {
  uint32_t display_id = info[0].As<Napi::Number>().Uint32Value();

  NSScreen *screen = GetDisplayFromID(display_id);
  if (!screen) {
    std::string msg = "Invalid screen ID - no screen with ID " + screen_id;
    Napi::Error::New(info.Env(), msg).ThrowAsJavaScriptException();
    return Napi::Object::New(info.Env());
  }

  return BuildDisplay(screen);
}

// Returns the safe area insets for a given NSScreen.
Napi::Object SafeAreaInsets(const Napi::CallbackInfo &info) {
  Napi::Object insets = Napi::Object::New(info.Env());

  int screen_id = info[0].As<Napi::Number>().Uint32Value();

  if (@available(macOS 12.0, *)) {
    NSScreen *screen = ScreenForID(screen_id);
    if (!screen) {
      std::string msg = "Invalid screen ID - no screen with ID " + screen_id;
      Napi::Error::New(info.Env(), msg).ThrowAsJavaScriptException();
      return Napi::Object::New(info.Env());
    }

    NSEdgeInsets safe_area_insets = [screen safeAreaInsets];
    insets.Set("bottom", safe_area_insets.bottom);
    insets.Set("left", safe_area_insets.left);
    insets.Set("right", safe_area_insets.right);
    insets.Set("top", safe_area_insets.top);
  }

  return insets;
}

Napi::Object AuxiliaryTopLeftArea(const Napi::CallbackInfo &info) {
  int screen_id = info[0].As<Napi::Number>().Uint32Value();

  NSScreen *screen = ScreenForID(screen_id);
  if (!screen) {
    std::string msg = "Invalid screen ID - no screen with ID " + screen_id;
    Napi::Error::New(info.Env(), msg).ThrowAsJavaScriptException();
    return Napi::Object::New(info.Env());
  }

  if (@available(macOS 12.0, *)) {
    NSRect rect = [screen auxiliaryTopLeftArea];
    return GetObjectForNSRect(info.Env(), rect);
  }

  return GetObjectForNSRect(info.Env(), [screen visibleFrame]);
}

Napi::Object AuxiliaryTopRightArea(const Napi::CallbackInfo &info) {
  int screen_id = info[0].As<Napi::Number>().Uint32Value();

  NSScreen *screen = ScreenForID(screen_id);
  if (!screen) {
    std::string msg = "Invalid screen ID - no screen with ID " + screen_id;
    Napi::Error::New(info.Env(), msg).ThrowAsJavaScriptException();
    return Napi::Object::New(info.Env());
  }

  if (@available(macOS 12.0, *)) {
    NSRect rect = [screen auxiliaryTopRightArea];
    return GetObjectForNSRect(info.Env(), rect);
  }

  return GetObjectForNSRect(info.Env(), [screen visibleFrame]);
}

// Initializes all functions exposed to JS.
Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "getAllDisplays"),
              Napi::Function::New(env, GetAllDisplays));
  exports.Set(Napi::String::New(env, "getDisplayByID"),
              Napi::Function::New(env, GetDisplayByID));
  exports.Set(Napi::String::New(env, "safeAreaInsets"),
              Napi::Function::New(env, SafeAreaInsets));
  exports.Set(Napi::String::New(env, "auxiliaryTopLeftArea"),
              Napi::Function::New(env, AuxiliaryTopLeftArea));
  exports.Set(Napi::String::New(env, "auxiliaryTopRightArea"),
              Napi::Function::New(env, AuxiliaryTopRightArea));

  return exports;
}

NODE_API_MODULE(notch, Init)
