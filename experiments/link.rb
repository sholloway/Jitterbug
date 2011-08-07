#attempt to link to the macos_jitterbug.bundle
#call with macruby...
framework 'Cocoa'
framework 'OpenGL'
framework 'AppKit'
require File.join(File.expand_path(File.dirname(__FILE__)),"./../native/osx/macos_jitterbug")

class AppDelegate
  def applicationDidFinishLaunching(notification)    
  end

  def windowWillClose(notification)    
    exit
  end
end

app = NSApplication.sharedApplication
app.delegate = AppDelegate.new
size = [0, 0, 1280, 768]

window = NSWindow.alloc.initWithContentRect(size,
    styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask,
    backing:NSBackingStoreBuffered,
    defer:false)
window.title      = 'OS X: Jitterbug OpenGL Window'
window.level      = NSModalPanelWindowLevel
window.delegate   = app.delegate

glview = GLView.alloc.initWithFrame(size)

window.contentView.addSubview(glview)

window.display
window.orderFrontRegardless
app.run