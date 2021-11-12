const notch = require('bindings')('notch.node')

module.exports = {
  getAllDisplays: notch.getAllDisplays,
  getDisplayByID: notch.getDisplayByID,
  safeAreaInsets: notch.safeAreaInsets,
  auxiliaryTopLeftArea: notch.auxiliaryTopLeftArea,
  auxiliaryTopRightArea: notch.auxiliaryTopRightArea,
}
