#import "SchemeShortcuts.h"
#import "ShortcutsFile.h"
#import "SchemeDestinationPair.h"
#import <objc/runtime.h>

@interface SchemeShortcuts (Stubs)
- (NSArray *)workspaceWindowControllers;
- (id)representingFilePath;
- (id)workspacePath;
- (NSString *)pathString;

- (id)runContextManager;
- (id)activeRunContext;
- (NSArray *)runContexts;

- (id)activeRunDestination;
- (NSArray *)availableRunDestinations;

//- (id)_bestDestinationForScheme:(id)scheme previousDestination:(id)destination;
- (void)setActiveRunContext:(id)content andRunDestination:(id)destination;

- (NSString *)name;
- (NSString *)fullDisplayName;
@end


@interface SchemeShortcuts ()
@property (strong, nonatomic) id keyPressMonitor;
@end

@implementation SchemeShortcuts
@synthesize keyPressMonitor = _keyPressMonitor;

+ (void)pluginDidLoad:(NSBundle *)plugin {
	static id sharedPlugin = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		sharedPlugin = [[self alloc] init];
	});
}

- (id)init {
	if (self = [super init]) {
		[self _observeKeyPresses];
	}
	return self;
}

- (void)dealloc {
    [NSEvent removeMonitor:self.keyPressMonitor];
    [_keyPressMonitor release];
	[super dealloc];
}

- (void)_observeKeyPresses {
    self.keyPressMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^ NSEvent* (NSEvent *event) {
        if (event.modifierFlags & NSCommandKeyMask) {
            id workspace = self._currentWorkspace;
            if (workspace && [self _handleKeyPress:event.charactersIgnoringModifiers workspace:workspace])
                return nil;
        }
        return event;
    }];
}

- (BOOL)_handleKeyPress:(NSString *)key workspace:(id)workspace {
    ShortcutsFile *file = [self shortcutsFileForWorkspace:workspace];
    SchemeDestinationPair *pair = [file pairForShortcut:key];

    if (pair) {
        [self _chooseSchemeAndDestinationForWorkspace:workspace matching:pair];
        [NSApp sendAction:@selector(runActiveRunContext:) to:nil from:nil];
        return YES;
    }
    return NO;
}

- (id)_currentWorkspace {
    id workspaceController = [[NSApp keyWindow] windowController];
    if ([workspaceController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        return [workspaceController valueForKeyPath:@"_workspace"];
    }
    return nil;
}

- (ShortcutsFile *)shortcutsFileForWorkspace:(id)workspace {
    static void *WorkspaceShortcutsFileKey;
    ShortcutsFile *file = objc_getAssociatedObject(workspace, &WorkspaceShortcutsFileKey);

    if (!file) {
        NSString *workspacePath = [[workspace representingFilePath] pathString];
        NSLog(@"Workspace path - %@", workspacePath);

        NSString *filePath = [workspacePath stringByAppendingPathComponent:@"SchemeShortcuts"];
        file = [[[ShortcutsFile alloc] initWithFilePath:filePath] autorelease];
        objc_setAssociatedObject(workspace, &WorkspaceShortcutsFileKey, file, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return file;
}

- (void)_chooseSchemeAndDestinationForWorkspace:(id)workspace matching:(SchemeDestinationPair *)pair {
    id runContextManager = [workspace runContextManager];
    id matchingScheme = nil, matchingDestination = nil;

    for (id scheme in [runContextManager runContexts]) {
        if ([[scheme name] isEqualToString:pair.schemeName]) {
            matchingScheme = scheme;
        }

        for (id destination in [scheme availableRunDestinations]) {
            if ([[destination fullDisplayName] isEqualToString:pair.destinationName]) {
                matchingDestination = destination;
            }
        }
    }

    NSLog(@"Switching to %@ - %@", [matchingScheme name], [matchingDestination fullDisplayName]);
    [runContextManager setActiveRunContext:matchingScheme andRunDestination:matchingDestination];
}

#pragma mark - Debugging

- (void)_listWorkspaces {
    NSArray *workspaceWindowControllers = [NSClassFromString(@"IDEWorkspaceWindowController") workspaceWindowControllers];
    for (NSWindowController *workspaceWindowController in workspaceWindowControllers) {
        id workspace = [workspaceWindowController valueForKey:@"_workspace"];
        NSLog(@"workspace = %@", workspace);
        [self _listSchemesForWorkspace:workspace];
    }
}

- (void)_listSchemesForWorkspace:(id)workspace {
    id runContextManager = [workspace runContextManager];
    id activeScheme = [runContextManager activeRunContext]; // SchemeShortcuts
    id activeDestination = [runContextManager activeRunDestination]; // My Mac 64-bit

    NSLog(@"Schemes:");

    for (id scheme in [runContextManager runContexts]) {
        NSLog(@"\t%@:", [scheme name]);

        for (id destination in [scheme availableRunDestinations]) {
            NSLog(@"\t\t%@", [destination fullDisplayName]);
        }
    }

    NSLog(@"Active: %@ - %@", [activeScheme name], [activeDestination fullDisplayName]);
}
@end
