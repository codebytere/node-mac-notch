const notch = require('bindings')('notch.node')

module.exports = {
  getAllDisplays: notch.getAllDisplays,
  getDisplayById: notch.getDisplayById,
  safeAreaInsets: notch.safeAreaInsets,
  auxiliaryTopLeftArea: notch.auxiliaryTopLeftArea,
  auxiliaryTopRightArea: notch.auxiliaryTopRightArea,
}
