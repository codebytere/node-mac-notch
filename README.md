# node-mac-notch

A native Node.js module to fetch information about the new camera notch at the top of some MacBook Pros.

## API

### `Display` Object

The `Display` object represents a physical display connected to the system. A
fake `Display` may exist on a headless system, or a `Display` may correspond to
a remote, virtual display.

Display objects take the following format:

* `id` Number - The display's unique identifier.
* `name` String - The human-readable name of the display.
* `supportedWindowDepths` Number[] - The window depths supported by the display.
* `rotation` Number - The screen rotation in clockwise degrees.
* `scaleFactor` Number - Output device's pixel scale factor.
* `isMonochrome` Boolean - Whether or not the display is a monochrome display.
* `colorSpace` Object - Representation of a custom color space.
  * `name` String - The localized name of the color space.
  * `componentCount` Number - The number of components, excluding alpha, the color space supports.
* `depth` Number - The number of bits per pixel.
* `bounds` Object
  * `x` Number - The x coordinate of the origin of the rectangle.
  * `y` Number - The y coordinate of the origin of the rectangle.
  * `width` Number - The width of the rectangle.
  * `height` Number - The height of the rectangle.
* `workArea` Object
  * `x` Number - The x coordinate of the origin of the rectangle.
  * `y` Number - The y coordinate of the origin of the rectangle.
  * `width` Number - The width of the rectangle.
  * `height` Number - The height of the rectangle.
* `internal` Boolean - `true` for an internal display and `false` for an external display.
* `isAsleep` Boolean -  Whether or not the display is sleeping.
* `refreshRate` Number - Returns the refresh rate of the specified display.

### `notch.getAllDisplays()`

Returns `Array<Object>` - An array of display objects.

Example:

```js
const notch = require('node-mac-notch')

const displays = notch.getAllDisplays()

console.log(displays[0])
/* Prints:
[
  {
    id: 69734406,
    name: 'Built-in Retina Display',
    refreshRate: 0,
    supportedWindowDepths: [
      264, 516, 520, 528,
      544,   0,   0,   0
    ],
    isAsleep: false,
    isMonochrome: false,
    colorSpace: { name: 'Color LCD', componentCount: 3 },
    depth: 520,
    scaleFactor: 2,
    bounds: { x: 0, y: 0, width: 1680, height: 1050 },
    workArea: { x: 0, y: 23, width: 1680, height: 932 },
    rotation: 0,
    internal: true
  }
]
*/
```

See [Apple Documentation](https://developer.apple.com/documentation/appkit/nsscreen?language=objc) for more information.

### `notch.getDisplayByID(displayID)`

* `displayID` Number - The display's unique identifier.

Returns `Object` - the display with the specified `displayID`.

Example:

```js
const notch = require('node-mac-notch')

const display = displays.getDisplayByID(2077749241)

console.log(display)
/* Prints:
{
  id: 69734406,
  name: 'Built-in Retina Display',
  refreshRate: 0,
  supportedWindowDepths: [
    264, 516, 520, 528,
    544,   0,   0,   0
  ],
  isAsleep: false,
  isMonochrome: false,
  colorSpace: { name: 'Color LCD', componentCount: 3 },
  depth: 520,
  scaleFactor: 2,
  bounds: { x: 0, y: 0, width: 1680, height: 1050 },
  workArea: { x: 0, y: 23, width: 1680, height: 932 },
  rotation: 0,
  internal: true
}
*/
```

See [Apple Documentation](https://developer.apple.com/documentation/appkit/nsscreen?language=objc) for more information.

### `notch.safeAreaInsets([displayID])`

* `displayID` Number (optional) - the unique identifier corresponding to a specific display. If no `displayID` is passed, this function will choose the main display your computer has in focus.

Returns `Object` - an object containing the distances from the display's edges at which content isn’t obscured.

  * `bottom` - The distance from the bottom of the source rectangle to the bottom of the result rectangle.
  * `left` - The distance from the left side of the source rectangle to the left side of the result rectangle.
  * `right` - The distance from the right side of the source rectangle to the right side of the result rectangle.
  * `top` - The distance from the top of the source rectangle to the top of the result rectangle.

If the display corresponding to `displayID` (or the primary display) does not have a camera housing notch, this function will return `{ bottom: 0, left: 0, top: 0, right: 0 }`.

Example:

```js
const notch = require('node-mac-notch')

const insets = notch.safeAreaInsets()

console.log(insets)
/* Prints:
{
  bottom: TODO,
  left: TODO,
  top: TODO,
  right: TODO
}
*/
```

See [Apple Documentation](https://developer.apple.com/documentation/appkit/nsscreen/3882821-safeareainsets?language=objc) for more information.

### `notch.auxiliaryTopLeftArea([displayID])`

* `displayID` Number (optional) - the unique identifier corresponding to a specific display. If no `displayID` is passed, this function will choose the main display your computer has in focus.

Returns `Object` - An object representing the unobscured portion of the top-left corner of the screen.

  * `size` Object - An object that specifies the height and width of the rectangle.
    * `width` Number - The width of the safe display area.
    * `height` Number - The height of the safe display area.
  * `origin` Object - A point that specifies the coordinates of the rectangle’s origin.
    * `x` Number - The x-coordinate of the point, from the bottom left of the display.
    * `y` Number - The y-coordinate of the point,  from the bottom left of the display.

If this is a notched display, the return value for this method represents the visible top-left portion of the screen. If this is not a notched display, the `width` and `height` properties of `size` will be 0.

Example:

```js
const notch = require('node-mac-notch')

const area = notch.auxiliaryTopLeftArea()

console.log(area)
/* Prints:
{
  size: {
    width: 1234
    height: 4321
  },
  origin: {
    x: 0,
    y: 0,
  }
}
*/
```

See [Apple Documentation](https://developer.apple.com/documentation/appkit/nsscreen/3882915-auxiliarytopleftarea) for more information.

### `notch.auxiliaryTopRightArea([displayID])`

* `displayID` Number (optional) - the unique identifier corresponding to a specific display. If no `displayID` is passed, this function will choose the main display your computer has in focus.

Returns `Object` - An object representing the unobscured portion of the top-right corner of the screen.

  * `size` Object - An object that specifies the height and width of the rectangle.
    * `width` Number - The width of the safe display area.
    * `height` Number - The height of the safe display area.
  * `origin` Object - A point that specifies the coordinates of the rectangle’s origin.
    * `x` Number - The x-coordinate of the point, from the bottom left of the display.
    * `y` Number - The y-coordinate of the point,  from the bottom left of the display.

If this is a notched display, the return value for this method represents the visible top-right portion of the screen. If this is not a notched display, the `width` and `height` properties of `size` will be 0.

Example:

```js
const notch = require('node-mac-notch')

const area = notch.auxiliaryTopLeftArea()

console.log(area)
/* Prints:
{
  size: {
    width: 1234
    height: 4321
  },
  origin: {
    x: 0,
    y: 0,
  }
}
*/
```

See [Apple Documentation](https://developer.apple.com/documentation/appkit/nsscreen/3882915-auxiliarytoprightarea) for more information.
