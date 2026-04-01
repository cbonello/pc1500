import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var flutterViewController: FlutterViewController!
  private var toolbarChannel: FlutterMethodChannel!

  override func awakeFromNib() {
    flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    // Lock aspect ratio to match the PC-1500 skin (1506 x 628).
    self.contentAspectRatio = NSSize(width: 1506, height: 628)
    self.contentMinSize = NSSize(width: 753, height: 314)
    self.setContentSize(NSSize(width: 1054, height: 440))

    // Method channel for file dialogs (screenshot, save/restore state).
    toolbarChannel = FlutterMethodChannel(
      name: "pc1500/toolbar",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    toolbarChannel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "requestScreenshot":
        self?.showScreenshotPanel()
        result(nil)
      case "requestSaveState":
        self?.showSaveStatePanel()
        result(nil)
      case "requestRestoreState":
        self?.showRestoreStatePanel()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  // MARK: - File Dialogs

  private func showScreenshotPanel() {
    let panel = NSSavePanel()
    panel.allowedFileTypes = ["png"]
    panel.nameFieldStringValue = "pc1500_screenshot.png"
    panel.beginSheetModal(for: self) { response in
      if response == .OK, let url = panel.url {
        self.toolbarChannel.invokeMethod("screenshot", arguments: url.path)
      }
    }
  }

  private func showSaveStatePanel() {
    let panel = NSSavePanel()
    panel.allowedFileTypes = ["json"]
    panel.nameFieldStringValue = "pc1500_state.json"
    panel.beginSheetModal(for: self) { response in
      if response == .OK, let url = panel.url {
        self.toolbarChannel.invokeMethod("saveStateTo", arguments: url.path)
      }
    }
  }

  private func showRestoreStatePanel() {
    let panel = NSOpenPanel()
    panel.allowedFileTypes = ["json"]
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = false
    panel.beginSheetModal(for: self) { response in
      if response == .OK, let url = panel.url {
        self.toolbarChannel.invokeMethod("restoreStateFrom", arguments: url.path)
      }
    }
  }
}
