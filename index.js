const notch = require('bindings')('notch.node')

module.exports = {
  safeAreaInsets: notch.safeAreaInsets,
  auxiliaryTopLeftArea: notch.auxiliaryTopLeftArea,
  auxiliaryTopRightArea: notch.auxiliaryTopRightArea,
}
