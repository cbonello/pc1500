import Cocoa
import FlutterMacOS

private let screenshotToolbarItemID = NSToolbarItem.Identifier("screenshot")

class MainFlutterWindow: NSWindow, NSToolbarDelegate {
  private var flutterViewController: FlutterViewController!
  private var screenshotChannel: FlutterMethodChannel!

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

    // Method channel to notify Flutter of screenshot requests.
    screenshotChannel = FlutterMethodChannel(
      name: "pc1500/toolbar",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    // Add a toolbar with a screenshot button.
    let toolbar = NSToolbar(identifier: "MainToolbar")
    toolbar.delegate = self
    toolbar.displayMode = .iconOnly
    self.toolbar = toolbar
    self.titleVisibility = .hidden
  }

  // MARK: - NSToolbarDelegate

  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    [.flexibleSpace, screenshotToolbarItemID]
  }

  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    [.flexibleSpace, screenshotToolbarItemID]
  }

  func toolbar(
    _ toolbar: NSToolbar,
    itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
    willBeInsertedIntoToolbar flag: Bool
  ) -> NSToolbarItem? {
    if itemIdentifier == screenshotToolbarItemID {
      let item = NSToolbarItem(itemIdentifier: screenshotToolbarItemID)
      item.label = "Screenshot"
      item.toolTip = "Save screenshot"
      if #available(macOS 11.0, *) {
        item.image = NSImage(systemSymbolName: "camera", accessibilityDescription: "Screenshot")
      } else {
        item.image = NSImage(named: NSImage.quickLookTemplateName)
      }
      item.target = self
      item.action = #selector(screenshotTapped)
      return item
    }
    return nil
  }

  @objc private func screenshotTapped() {
    screenshotChannel.invokeMethod("screenshot", arguments: nil)
  }
}
