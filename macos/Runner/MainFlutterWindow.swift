import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    // Lock aspect ratio to match the PC-1500 skin (1506 x 628).
    self.contentAspectRatio = NSSize(width: 1506, height: 628)
    self.contentMinSize = NSSize(width: 753, height: 314)
    self.setContentSize(NSSize(width: 1054, height: 440))
  }
}
