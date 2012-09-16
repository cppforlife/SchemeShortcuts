#import <Cocoa/Cocoa.h>

@class ShortcutsFile;

@interface SchemeShortcuts : NSObject {
    id _keyPressMonitor;
}

+ (void)pluginDidLoad:(NSBundle *)plugin;

- (ShortcutsFile *)shortcutsFileForWorkspace:(id)workspace;
@end
